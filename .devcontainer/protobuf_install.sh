# Set version
PROTOC_VERSION=25.1

# Download
curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip

# Install
unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d /usr/local

# Verify
protoc --version

# Cleanup
rm protoc-${PROTOC_VERSION}-linux-x86_64.zip

# Install the protoc-gen-elixir plugin
mix escript.install hex protoc_gen_elixir

# Add the escript directory to your PATH
export PATH="/root/.mix/escripts:$PATH"

# Verify it's installed
which protoc-gen-elixir