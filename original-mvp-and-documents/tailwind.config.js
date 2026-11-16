/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,jsx}", "./components/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        canvas: "#F5F4EE",
        card: "#FFFFFF",
        ink: "#1D2A21",
        sub: "#6B7468",
        line: "#E7E5DB",
        leaf: { DEFAULT: "#1E6B40", deep: "#14532D", soft: "#E8F2EB" },
        gold: { DEFAULT: "#E2A60C", deep: "#B9860A", soft: "#FBF3DC" },
        water: { DEFAULT: "#1B6E8C", soft: "#E4F1F5" },
        volt: { DEFAULT: "#7A5AF8", soft: "#EEEAFE" }
      },
      fontFamily: {
        display: ["var(--font-display)", "serif"],
        body: ["var(--font-body)", "sans-serif"]
      },
      boxShadow: { card: "0 1px 2px rgba(29,42,33,0.05)" }
    }
  },
  plugins: []
};
