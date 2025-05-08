/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts}", // Analyse les fichiers HTML et TypeScript dans /src
  ],
  theme: {
    extend: {
      colors: {
        primary: "#6A1B9A",
        secondary: "#D4AF37",
        dark: "#1E0D2B",
        gold: {
          100: "#F9F3D6",
          200: "#F5E7B8",
          300: "#F0DB9A",
          400: "#EBD07C",
          500: "#D4AF37",
          600: "#B8972E",
          700: "#9C7F25",
          800: "#80671C",
          900: "#644F13"
        }
      },
      borderRadius: {
        none: "0px",
        sm: "4px",
        DEFAULT: "8px",
        md: "12px",
        lg: "16px",
        xl: "20px",
        "2xl": "24px",
        "3xl": "32px",
        full: "9999px",
        button: "8px"
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        display: ['Poppins', 'sans-serif']
      }
    }
  },
  plugins: []
};