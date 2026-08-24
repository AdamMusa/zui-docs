import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "item", "category", "count", "empty", "label"]
  static values = { initialCategory: String }

  connect() {
    this.activeCategory = this.initialCategoryValue || "all"
    this.boundShortcut = this.shortcut.bind(this)
    window.addEventListener("keydown", this.boundShortcut)
    this.syncCategoryButtons()
    this.filter()
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundShortcut)
  }

  shortcut(event) {
    if (event.key === "/" && !["INPUT", "TEXTAREA", "LEXXY-EDITOR"].includes(document.activeElement?.tagName)) {
      event.preventDefault()
      this.queryTarget.focus()
    }
  }

  selectCategory(event) {
    this.activeCategory = event.currentTarget.dataset.category
    this.syncCategoryButtons()
    this.filter()
  }

  clear() {
    this.queryTarget.value = ""
    this.activeCategory = "all"
    this.syncCategoryButtons()
    this.filter()
    this.queryTarget.focus()
  }

  filter() {
    const query = this.queryTarget.value.trim().toLowerCase()
    let visible = 0

    this.itemTargets.forEach((item) => {
      const categoryMatch = this.activeCategory === "all" || item.dataset.catalogCategory === this.activeCategory
      const queryMatch = !query || item.dataset.catalogSearch.includes(query)
      item.hidden = !(categoryMatch && queryMatch)
      if (!item.hidden) visible += 1
    })

    this.countTarget.textContent = visible
    this.emptyTarget.hidden = visible !== 0
    const activeButton = this.categoryTargets.find((button) => button.dataset.category === this.activeCategory)
    this.labelTarget.textContent = activeButton?.childNodes[0]?.textContent.trim() || "All components"

    const url = new URL(window.location)
    this.activeCategory === "all" ? url.searchParams.delete("category") : url.searchParams.set("category", this.activeCategory)
    query ? url.searchParams.set("q", query) : url.searchParams.delete("q")
    history.replaceState({}, "", url)
  }

  syncCategoryButtons() {
    this.categoryTargets.forEach((button) => button.classList.toggle("is-active", button.dataset.category === this.activeCategory))
  }
}
