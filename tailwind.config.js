const colors = require('tailwindcss/colors')

export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: colors.indigo[500],
        secondary: colors.yellow,
        muted: colors.gray[500],
        danger: colors.red[500],
      },
    },
  },
  plugins: [],
}