# # Make sure deps are installed
# mix deps.get

# # Install the generator
# mix escript.install hex protoc_gen_elixir

# # Add to PATH (use full path if needed)
# export PATH="/root/.mix/escripts:$PATH"

# # Generate
# protoc --elixir_out=./lib/airgap_app/proto priv/proto/messages.proto

mix protox.generate --output-path=./lib/airgap_app/proto --include-path=./priv/proto priv/proto/messages.proto