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

# Function to convert lat/lon to tile numbers
lat2tile() {
    lat=$1
    zoom=$2
    echo "(l($lat * 3.141592653589793 / 180 + 1.5707963267948966) / 0.6931471805599453) * 2^($zoom - 1)" | bc -l | cut -d. -f1
}

lon2tile() {
    lon=$1
    zoom=$2
    echo "($lon + 180) / 360 * 2^$zoom" | bc -l | cut -d. -f1
}

# Download tiles for each zoom level
for z in $(seq $MIN_ZOOM $MAX_ZOOM); do
    echo "Downloading zoom level $z..."
    
    # Calculate tile bounds based on center and radius
    # This is a simplified calculation
    lat_range=$(echo "scale=4; $RADIUS_KM / 111" | bc)
    lon_range=$(echo "scale=4; $RADIUS_KM / (111 * c($CENTER_LAT * 3.141592653589793 / 180))" | bc -l)
    
    min_lat=$(echo "$CENTER_LAT - $lat_range" | bc)
    max_lat=$(echo "$CENTER_LAT + $lat_range" | bc)
    min_lon=$(echo "$CENTER_LON - $lon_range" | bc)
    max_lon=$(echo "$CENTER_LON + $lon_range" | bc)
    
    # Convert to tile numbers
    min_x=$(lon2tile $min_lon $z)
    max_x=$(lon2tile $max_lon $z)
    min_y=$(lat2tile $max_lat $z)
    max_y=$(lat2tile $min_lat $z)
    
    # Download tiles
    for x in $(seq $min_x $max_x); do
        mkdir -p "$TILES_DIR/$z/$x"
        for y in $(seq $min_y $max_y); do
            tile_file="$TILES_DIR/$z/$x/$y.png"
            
            if [ ! -f "$tile_file" ]; then
                # Using a public tile server - replace with your own for production
                # Options: OpenStreetMap, Stamen, etc.
                url="https://tile.openstreetmap.org/$z/$x/$y.png"
                
                echo "Downloading tile: $z/$x/$y"
                curl -s -o "$tile_file" "$url" \
                     -H "User-Agent: AirGapApp/1.0"
                
                # Be nice to the tile server
                sleep 0.1
            fi
        done
    done
done

echo "Tile download complete!"
echo "Tiles stored in: $TILES_DIR"

# Create a placeholder for missing tiles
echo "Creating blank tile..."
convert -size 256x256 xc:lightgray "$TILES_DIR/blank.png" 2>/dev/null || {
    echo "ImageMagick not found. Skipping blank tile creation."
}
