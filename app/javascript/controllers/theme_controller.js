import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    const stored = localStorage.getItem("zui-docs-theme")
    const preferred = window.matchMedia("(prefers-color-scheme: light)").matches ? "light" : "dark"
    this.apply(stored || preferred)
  }

  toggle() {
    this.apply(document.documentElement.dataset.theme === "dark" ? "light" : "dark")
  }

  apply(theme) {
    document.documentElement.dataset.theme = theme
    localStorage.setItem("zui-docs-theme", theme)
    if (this.hasIconTarget) this.iconTarget.textContent = theme === "dark" ? "☼" : "◐"
  }
}
