// Leaflet placeholder - Run scripts/download_leaflet.sh to download the actual library
// This is just a minimal stub to prevent errors during development

window.L = {
  map: function(element, options) {
    console.warn("Leaflet not loaded. Run: ./scripts/download_leaflet.sh");
    return {
      setView: function() { return this; },
      on: function() { return this; },
      off: function() { return this; },
      remove: function() { return this; },
      addLayer: function() { return this; },
      removeLayer: function() { return this; },
      getZoom: function() { return 10; },
      getBounds: function() { 
        return {
          getNorth: function() { return 0; },
          getSouth: function() { return 0; },
          getEast: function() { return 0; },
          getWest: function() { return 0; }
        };
      }
    };
  },
  tileLayer: function() {
    return {
      addTo: function() { return this; }
    };
  },
  marker: function() {
    return {
      addTo: function() { return this; },
      setLatLng: function() { return this; },
      bindPopup: function() { return this; },
      remove: function() { return this; }
    };
  },
  polygon: function() {
    return {
      addTo: function() { return this; },
      remove: function() { return this; }
    };
  },
  layerGroup: function() {
    return {
      addTo: function() { return this; },
      clearLayers: function() { return this; }
    };
  },
  divIcon: function() { return {}; }
};
