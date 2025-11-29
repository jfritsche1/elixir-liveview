# Clone the protobuf library
cd /tmp
git clone https://github.com/elixir-protobuf/protobuf.git
cd protobuf

# Get dependencies and build the escript
mix deps.get
MIX_ENV=prod mix escript.build

# Copy to a location in PATH
mkdir -p /root/.mix/escripts
cp protoc-gen-elixir /root/.mix/escripts/
chmod +x /root/.mix/escripts/protoc-gen-elixir

# Add to PATH
export PATH="/root/.mix/escripts:$PATH"

# Verify it's available
which protoc-gen-elixir
protoc-gen-elixir --version