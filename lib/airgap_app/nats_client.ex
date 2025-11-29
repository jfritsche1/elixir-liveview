defmodule AirgapApp.NatsClient do
  use GenServer
  require Logger

  @reconnect_interval 5_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def publish(topic, message) do
    GenServer.call(__MODULE__, {:publish, topic, message})
  end

  def init(_opts) do
    send(self(), :connect)
    {:ok, %{gnat: nil, subscriptions: []}}
  end

  def handle_info(:connect, state) do
    settings = %{
      host: System.get_env("NATS_HOST", "localhost"),
      port: String.to_integer(System.get_env("NATS_PORT", "4222"))
    }
    
    case Gnat.start_link(settings) do
      {:ok, gnat} ->
        Logger.info("Connected to NATS at #{settings.host}:#{settings.port}")
        
        # Subscribe to topics
        subscriptions = [
          subscribe(gnat, "proto.messages"),
          subscribe(gnat, "location.updates"),
          subscribe(gnat, "h3.queries")
        ]
        
        {:noreply, %{gnat: gnat, subscriptions: subscriptions}}
      
      {:error, reason} ->
        Logger.error("Failed to connect to NATS: #{inspect(reason)}")
        Process.send_after(self(), :connect, @reconnect_interval)
        {:noreply, state}
    end
  end

  def handle_info({:msg, %{body: body, topic: topic, reply_to: reply_to}}, state) do
    Logger.debug("Received message on topic #{topic}")
    
    case decode_message(body, topic) do
      {:ok, decoded} ->
        # Broadcast to Phoenix PubSub
        Phoenix.PubSub.broadcast(
          AirgapApp.PubSub,
          "proto:updates",
          {:proto_message, decoded}
        )
        
        # Handle reply if needed
        if reply_to do
          handle_reply(state.gnat, reply_to, decoded)
        end
      
      {:error, reason} ->
        Logger.error("Failed to decode message: #{inspect(reason)}")
    end
    
    {:noreply, state}
  end

  def handle_info(:reconnect, state) do
    send(self(), :connect)
    {:noreply, %{state | gnat: nil, subscriptions: []}}
  end

  def handle_call({:publish, topic, message}, _from, %{gnat: gnat} = state) when not is_nil(gnat) do
    encoded = encode_message(message)
    result = Gnat.pub(gnat, topic, encoded)
    {:reply, result, state}
  end

  def handle_call({:publish, _topic, _message}, _from, state) do
    {:reply, {:error, :not_connected}, state}
  end

  def terminate(_reason, %{gnat: gnat, subscriptions: subs}) when not is_nil(gnat) do
    Enum.each(subs, &Gnat.unsub(gnat, &1))
    Gnat.stop(gnat)
  end

  def terminate(_reason, _state), do: :ok

  # Private functions

  defp subscribe(gnat, topic) do
    case Gnat.sub(gnat, self(), topic) do
      {:ok, sub} ->
        Logger.info("Subscribed to NATS topic: #{topic}")
        sub
      {:error, reason} ->
        Logger.error("Failed to subscribe to #{topic}: #{inspect(reason)}")
        nil
    end
  end

  defp decode_message(binary, "location.updates") do
    try do
      # Assuming we have generated Proto modules
      # You'll need to generate these with protoc
      decoded = AirgapApp.Proto.LocationUpdate.decode(binary)
      {:ok, decoded}
    rescue
      _ ->
        # Fallback to raw binary if Proto not available
        {:ok, %{raw: binary, topic: "location.updates"}}
    end
  end

  defp decode_message(binary, _topic) do
    {:ok, %{raw: binary}}
  end

  defp encode_message(%{} = message) do
    # Encode as Proto if it's a known message type
    # Otherwise encode as JSON
    Jason.encode!(message)
  end

  defp encode_message(message) when is_binary(message) do
    message
  end

  defp handle_reply(gnat, reply_to, _decoded) do
    response = Jason.encode!(%{status: "received", timestamp: System.system_time(:millisecond)})
    Gnat.pub(gnat, reply_to, response)
  end
end
