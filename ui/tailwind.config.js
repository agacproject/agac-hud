/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,js}",
    "./src/*.html",
    "./src/*.js",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
    "./src/**/*.png"
  ],
  theme: {
    extend: {
      fontFamily: {
        'inter': ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
  
}