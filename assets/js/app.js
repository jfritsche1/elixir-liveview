// Import Phoenix and LiveView JavaScript
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Leaflet Map Hook
const LeafletMap = {
  mounted() {
    // Load Leaflet CSS if not already loaded
    if (!document.querySelector('link[href*="leaflet.css"]')) {
      const link = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = '/assets/vendor/leaflet/leaflet.css';
      document.head.appendChild(link);
    }

    // Initialize map after a short delay to ensure container is ready
    setTimeout(() => {
      this.initMap();
    }, 100);
  },

  initMap() {
    // Initialize the map
    this.map = L.map(this.el, {
      zoomControl: true,
      attributionControl: true,
      preferCanvas: true // Better performance for many markers
    }).setView([40.7128, -74.0060], 10);
    
    // Use local tiles for air-gapped deployment
    this.tileLayer = L.tileLayer('/tiles/{z}/{x}/{y}', {
      maxZoom: 18,
      minZoom: 2,
      attribution: '© AirGap Local Map Data',
      tileSize: 256,
      noWrap: true
    }).addTo(this.map);

    // Initialize layers
    this.markers = {};
    this.h3Cells = {};
    this.h3Layer = L.layerGroup().addTo(this.map);
    this.highlightLayer = L.layerGroup().addTo(this.map);
    
    // Custom marker icon
    const markerHtml = `
      <div style="
        width: 12px;
        height: 12px;
        background: #3B82F6;
        border: 2px solid white;
        border-radius: 50%;
        box-shadow: 0 2px 4px rgba(0,0,0,0.3);
      "></div>
    `;
    
    this.markerIcon = L.divIcon({
      html: markerHtml,
      className: 'custom-div-marker',
      iconSize: [12, 12],
      iconAnchor: [6, 6]
    });
    
    // Map event handlers
    this.map.on('click', (e) => {
      this.pushEvent("map_click", {
        lat: e.latlng.lat, 
        lng: e.latlng.lng
      });
    });
    
    this.map.on('zoomend', () => {
      this.pushEvent("zoom_changed", {
        zoom: this.map.getZoom()
      });
    });
    
    // LiveView event handlers
    this.handleEvent("add_marker", ({id, lat, lon, h3}) => {
      this.addOrUpdateMarker(id, lat, lon, h3);
    });
    
    this.handleEvent("add_h3_cell", ({h3, polygon}) => {
      this.addH3Cell(h3, polygon);
    });
    
    this.handleEvent("highlight_h3", ({polygon, neighbors}) => {
      this.highlightH3(polygon, neighbors);
    });
    
    this.handleEvent("clear_map", () => {
      this.clearAll();
    });
  },

  addOrUpdateMarker(id, lat, lon, h3) {
    if (this.markers[id]) {
      // Update existing marker
      this.markers[id].setLatLng([lat, lon]);
    } else {
      // Create new marker
      const marker = L.marker([lat, lon], {
        icon: this.markerIcon,
        title: `ID: ${id.substring(0, 8)}...`
      });
      
      // Add popup
      marker.bindPopup(`
        <div style="min-width: 150px;">
          <strong>ID:</strong> ${id.substring(0, 12)}...<br>
          <strong>Lat:</strong> ${lat.toFixed(4)}<br>
          <strong>Lon:</strong> ${lon.toFixed(4)}<br>
          <strong>H3:</strong> ${h3}
        </div>
      `);
      
      marker.addTo(this.map);
      this.markers[id] = marker;
    }
  },

  addH3Cell(h3, polygon) {
    if (!this.h3Cells[h3]) {
      const poly = L.polygon(polygon, {
        color: '#3B82F6',
        weight: 1,
        fillOpacity: 0.1,
        fillColor: '#3B82F6'
      });
      
      poly.addTo(this.h3Layer);
      this.h3Cells[h3] = poly;
    }
  },

  highlightH3(polygon, neighbors) {
    // Clear previous highlights
    this.highlightLayer.clearLayers();
    
    // Highlight main cell
    L.polygon(polygon, {
      color: '#EF4444',
      weight: 2,
      fillOpacity: 0.3,
      fillColor: '#EF4444'
    }).addTo(this.highlightLayer);
    
    // Highlight neighbors if provided
    if (neighbors && neighbors.length > 0) {
      neighbors.forEach(neighborPoly => {
        L.polygon(neighborPoly, {
          color: '#F59E0B',
          weight: 1,
          fillOpacity: 0.15,
          fillColor: '#F59E0B'
        }).addTo(this.highlightLayer);
      });
    }
  },

  clearAll() {
    // Clear all markers
    Object.values(this.markers).forEach(marker => marker.remove());
    this.markers = {};
    
    // Clear all H3 cells
    this.h3Layer.clearLayers();
    this.h3Cells = {};
    
    // Clear highlights
    this.highlightLayer.clearLayers();
  },

  destroyed() {
    if (this.map) {
      this.map.remove();
    }
  }
}

// Flash message hook
const Flash = {
  mounted() {
    setTimeout(() => {
      this.el.classList.add('fade-out');
      setTimeout(() => this.el.remove(), 300);
    }, 3000);
  }
}

// Initialize LiveSocket with hooks
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: {LeafletMap, Flash}
});

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"});
window.addEventListener("phx:page-loading-start", info => topbar.show(300));
window.addEventListener("phx:page-loading-stop", info => topbar.hide());

// Connect to LiveSocket
liveSocket.connect();

// Expose liveSocket for debugging
window.liveSocket = liveSocket;
