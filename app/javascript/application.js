// 🚫 Turbo完全停止
import "controllers"

document.addEventListener("turbo:load", () => {
  console.log("✅ Turbo load event fired")
})

document.addEventListener("DOMContentLoaded", () => {
  console.log("✅ DOM fully loaded (without Turbo)")
})
