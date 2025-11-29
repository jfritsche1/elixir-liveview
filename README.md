# AirGap Map System

A Phoenix web application with NATS integration, Protocol Buffers, and H3 hexagonal geospatial indexing designed to run on air-gapped networks.

## Features

- **NATS Integration**: Real-time message handling with Protocol Buffers
- **H3 Geospatial Indexing**: Uber's hexagonal hierarchical spatial index
- **Offline Maps**: Local tile server for air-gapped deployment
- **Phoenix LiveView**: Real-time UI updates without additional dependencies
- **Tailwind CSS**: Modern utility-first CSS framework
- **Minimal Dependencies**: Optimized for air-gapped environments

## Prerequisites

- Elixir 1.14+
- Erlang/OTP 25+
- Node.js 18+ (for assets)
- NATS Server 2.10+
- Protocol Buffer Compiler (protoc) 3.21+

## Installation

1. **Install dependencies:**
```bash
mix deps.get
```

2. **Setup assets:**
```bash
mix assets.setup
```

3. **Generate Proto modules:**
```bash
protoc --elixir_out=./lib/airgap_app/proto priv/proto/messages.proto
```

4. **Download map tiles for offline use:**
```bash
# Run the tile download script
./scripts/download_tiles.sh
```

5. **Download Leaflet for offline use:**
```bash
cd assets/vendor
wget https://unpkg.com/leaflet@1.9.4/dist/leaflet.js
wget https://unpkg.com/leaflet@1.9.4/dist/leaflet.css
wget -r -np -k -E https://unpkg.com/leaflet@1.9.4/dist/images/
```

## Configuration

### NATS Configuration

Set environment variables:
```bash
export NATS_HOST=localhost
export NATS_PORT=4222
```

### For Air-Gapped Deployment

1. **Build release:**
```bash
MIX_ENV=prod mix do compile, assets.deploy, release
```

2. **Package for transfer:**
```bash
tar -czf airgap_app.tar.gz _build/prod/rel/airgap_app priv/static/tiles
```

3. **Deploy to air-gapped system:**
```bash
# On target system
tar -xzf airgap_app.tar.gz
./_build/prod/rel/airgap_app/bin/airgap_app start
```

## Running in Development

1. **Start NATS server:**
```bash
nats-server
```

2. **Start Phoenix server:**
```bash
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000)

## Testing

```bash
mix test
```

## Project Structure

```
airgap_app/
├── lib/
│   ├── airgap_app/
│   │   ├── application.ex      # Main application supervisor
│   │   ├── nats_client.ex      # NATS client for Proto messages
│   │   ├── h3_service.ex       # H3 geospatial operations
│   │   └── proto/              # Generated Proto modules
│   └── airgap_app_web/
│       ├── live/
│       │   └── map_live.ex     # Main map LiveView
│       ├── controllers/
│       │   └── tile_controller.ex  # Serve local map tiles
│       └── components/          # Phoenix components
├── assets/
│   ├── js/
│   │   └── app.js              # Main JavaScript entry
│   ├── css/
│   │   └── app.css             # Tailwind CSS entry
│   └── vendor/
│       └── leaflet/            # Offline Leaflet library
├── priv/
│   ├── proto/
│   │   └── messages.proto      # Protocol Buffer definitions
│   └── static/
│       └── tiles/              # Offline map tiles
└── config/
    ├── config.exs              # Base configuration
    ├── dev.exs                 # Development config
    ├── prod.exs                # Production config
    └── runtime.exs             # Runtime configuration
```

## Sending Test Messages

Use the included test script to send Proto messages:

```elixir
# In IEx console
AirgapApp.TestHelper.send_location_update(%{
  id: "vehicle_001",
  latitude: 40.7128,
  longitude: -74.0060,
  timestamp: System.system_time(:millisecond)
})
```

## License

MIT
