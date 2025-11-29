#!/bin/bash

# Download Leaflet for offline use
LEAFLET_VERSION="1.9.4"
VENDOR_DIR="assets/vendor/leaflet"

echo "Downloading Leaflet v${LEAFLET_VERSION}..."

mkdir -p "$VENDOR_DIR/images"

# Download Leaflet JS
curl -L "https://unpkg.com/leaflet@${LEAFLET_VERSION}/dist/leaflet.js" \
     -o "$VENDOR_DIR/leaflet.js"

# Download Leaflet CSS
curl -L "https://unpkg.com/leaflet@${LEAFLET_VERSION}/dist/leaflet.css" \
     -o "$VENDOR_DIR/leaflet.css"

# Download Leaflet images
for img in marker-icon.png marker-icon-2x.png marker-shadow.png layers.png layers-2x.png; do
    curl -L "https://unpkg.com/leaflet@${LEAFLET_VERSION}/dist/images/$img" \
         -o "$VENDOR_DIR/images/$img"
done

echo "Leaflet downloaded successfully to $VENDOR_DIR"

# Update CSS to use local images
sed -i 's|url(images/|url(/assets/vendor/leaflet/images/|g' "$VENDOR_DIR/leaflet.css"

echo "Updated CSS paths for local images"
