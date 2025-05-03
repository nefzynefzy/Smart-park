module.exports = {
  content: [
    "./src/**/*.{html,ts}",
    "./src/app/**/*.{html,ts}",
    "./node_modules/remixicon/fonts/*.{woff,woff2,ttf}"
  ],
  theme: {
    extend: {
      colors: {
        primary: '#800665',
        'primary-dark': '#5E044B',
        secondary: '#4A5568'
      },
      boxShadow: {
        'soft': '0 8px 32px rgba(128, 6, 101, 0.08)'
      }
    }
  },
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms')
  ]
}