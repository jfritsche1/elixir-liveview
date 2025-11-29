// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/airgap_app_web.ex",
    "../lib/airgap_app_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        brand: "#3B82F6",
      }
    },
  },
  plugins: []
}
