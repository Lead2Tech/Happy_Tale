// config/tailwind.config.js
module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          light: "#FCD581", // 柔らかい黄みアンバー
          DEFAULT: "#FBBF24", // メインヘッダー色
          dark: "#F59E0B", // ホバー・アクセント用
        },
        accent: {
          orange: "#FB923C", // 元気で明るい
          pink: "#F472B6",   // 優しさ
          mint: "#2DD4BF",   // 清潔感
          gray: "#374151",   // 落ち着き
        },
      },
      fontFamily: {
        sans: ['"Noto Sans JP"', "Inter", "sans-serif"],
      },
      boxShadow: {
        soft: "0 2px 6px rgba(0,0,0,0.1)",
      },
    },
  },
  plugins: [],
};
