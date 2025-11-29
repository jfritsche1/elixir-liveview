#!/bin/bash

# Script to download map tiles for offline use
# Usage: ./download_tiles.sh [min_zoom] [max_zoom] [lat] [lon] [radius_km]

MIN_ZOOM=${1:-1}
MAX_ZOOM=${2:-10}
CENTER_LAT=${3:-40.7128}
CENTER_LON=${4:--74.0060}
RADIUS_KM=${5:-50}

TILES_DIR="priv/static/tiles"

echo "Downloading tiles for offline use..."
echo "Zoom levels: $MIN_ZOOM to $MAX_ZOOM"
echo "Center: $CENTER_LAT, $CENTER_LON"
echo "Radius: ${RADIUS_KM}km"

# Create tiles directory
mkdir -p "$TILES_DIR"

# Python script for tile calculations (more portable than bc)
calculate_tiles() {
    python3 - <<EOF
import math

def lat2tile(lat, zoom):
    lat_rad = math.radians(lat)
    n = 2.0 ** zoom
    return int((1.0 - math.asinh(math.tan(lat_rad)) / math.pi) / 2.0 * n)

def lon2tile(lon, zoom):
    n = 2.0 ** zoom
    return int((lon + 180.0) / 360.0 * n)

# Calculate bounds
center_lat = $CENTER_LAT
center_lon = $CENTER_LON
radius_km = $RADIUS_KM
zoom = $1

# Approximate degrees per km
lat_range = radius_km / 111.0
lon_range = radius_km / (111.0 * math.cos(math.radians(center_lat)))

min_lat = center_lat - lat_range
max_lat = center_lat + lat_range
min_lon = center_lon - lon_range
max_lon = center_lon + lon_range

# Clamp values
min_lat = max(-85.0511, min_lat)
max_lat = min(85.0511, max_lat)
min_lon = max(-180, min_lon)
max_lon = min(180, max_lon)

# Convert to tiles
min_x = lon2tile(min_lon, zoom)
max_x = lon2tile(max_lon, zoom)
min_y = lat2tile(max_lat, zoom)
max_y = lat2tile(min_lat, zoom)

print(f"{min_x} {max_x} {min_y} {max_y}")
EOF
}

# Download tiles for each zoom level
total_tiles=0
downloaded_tiles=0

for z in $(seq $MIN_ZOOM $MAX_ZOOM); do
    echo "Processing zoom level $z..."
    
    # Get tile bounds
    read min_x max_x min_y max_y <<< $(calculate_tiles $z)
    
    echo "  Tile range: x=$min_x-$max_x, y=$min_y-$max_y"
    
    # Download tiles
    for x in $(seq $min_x $max_x); do
        mkdir -p "$TILES_DIR/$z/$x"
        
        for y in $(seq $min_y $max_y); do
            tile_file="$TILES_DIR/$z/$x/$y.png"
            ((total_tiles++))
            
            if [ ! -f "$tile_file" ]; then
                # Using OpenStreetMap tile server
                # IMPORTANT: For production, use your own tile server or cache
                url="https://tile.openstreetmap.org/$z/$x/$y.png"
                
                if curl -s -f -o "$tile_file" "$url" \
                     -H "User-Agent: AirGapApp/1.0" \
                     --connect-timeout 10 \
                     --max-time 30; then
                    ((downloaded_tiles++))
                    echo "  Downloaded: $z/$x/$y"
                else
                    echo "  Failed: $z/$x/$y"
                    rm -f "$tile_file"
                fi
                
                # Rate limiting - be nice to tile servers
                # OSM requires max 2 downloads per second
                sleep 0.5
            else
                echo "  Cached: $z/$x/$y"
            fi
        done
    done
done

echo ""
echo "============================================"
echo "Tile download complete!"
echo "Total tiles processed: $total_tiles"
echo "New tiles downloaded: $downloaded_tiles"
echo "Tiles stored in: $TILES_DIR"
echo "============================================"

# Create metadata file
cat > "$TILES_DIR/metadata.json" <<EOF
{
  "center": {
    "lat": $CENTER_LAT,
    "lon": $CENTER_LON
  },
  "radius_km": $RADIUS_KM,
  "zoom_levels": {
    "min": $MIN_ZOOM,
    "max": $MAX_ZOOM
  },
  "downloaded_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_tiles": $total_tiles,
  "tile_server": "OpenStreetMap"
}
EOF

echo "Metadata saved to: $TILES_DIR/metadata.json"
