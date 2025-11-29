defmodule AirgapAppWeb.CoreComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Renders flash notices.
  """
  attr :flash, :map, required: true, doc: "the map of flash notices"

  def flash_group(assigns) do
    ~H"""
    <div class="fixed top-14 right-4 z-50 space-y-2">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end

  @doc """
  Renders a flash notice.
  """
  attr :id, :string, default: "flash", doc: "the DOM id of the flash"
  attr :flash, :map, required: true, doc: "the map of flash notices"
  attr :kind, :atom, required: true, doc: "the kind of flash"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> JS.remove_class("fade-in") |> JS.add_class("fade-out")}
      phx-hook="Flash"
      class={[
        "flex items-center gap-2 px-4 py-3 rounded-lg shadow-md fade-in cursor-pointer",
        @kind == :info && "bg-blue-50 text-blue-800 border border-blue-200",
        @kind == :error && "bg-red-50 text-red-800 border border-red-200"
      ]}
    >
      <div class="flex-shrink-0">
        <.icon :if={@kind == :info} name="information-circle" class="h-5 w-5" />
        <.icon :if={@kind == :error} name="exclamation-circle" class="h-5 w-5" />
      </div>
      <p class="text-sm font-medium"><%= msg %></p>
    </div>
    """
  end

  @doc """
  Renders a simple icon.
  """
  attr :name, :string, required: true
  attr :class, :string, default: "h-5 w-5"

  def icon(%{name: "information-circle"} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class={@class} viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
    </svg>
    """
  end

  def icon(%{name: "exclamation-circle"} = assigns) do
    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" class={@class} viewBox="0 0 20 20" fill="currentColor">
      <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
    </svg>
    """
  end

  def icon(assigns) do
    ~H"""
    <span class={@class}>?</span>
    """
  end
end
