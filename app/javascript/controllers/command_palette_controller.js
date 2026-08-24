import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "input", "results"]
  static values = { url: String }

  connect() {
    this.currentEntries = []
    this.selectedIndex = 0
    this.boundShortcut = this.shortcut.bind(this)
    window.addEventListener("keydown", this.boundShortcut)
  }

  disconnect() {
    window.removeEventListener("keydown", this.boundShortcut)
    clearTimeout(this.searchTimer)
    this.request?.abort()
  }

  shortcut(event) {
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
      event.preventDefault()
      this.dialogTarget.open ? this.close() : this.open()
    }
  }

  open() {
    this.dialogTarget.showModal()
    this.inputTarget.value = ""
    this.load("")
    requestAnimationFrame(() => this.inputTarget.focus())
  }

  close() {
    this.dialogTarget.close()
  }

  backdropClose(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  search() {
    clearTimeout(this.searchTimer)
    this.searchTimer = setTimeout(() => this.load(this.inputTarget.value.trim()), 100)
  }

  async load(query) {
    this.request?.abort()
    this.request = new AbortController()
    const url = new URL(this.urlValue, window.location.origin)
    if (query) url.searchParams.set("q", query)

    try {
      const response = await fetch(url, { headers: { Accept: "application/json" }, signal: this.request.signal })
      if (!response.ok) throw new Error(`Search returned ${response.status}`)
      this.render(await response.json())
    } catch (error) {
      if (error.name !== "AbortError") this.render([])
    }
  }

  render(entries) {
    this.currentEntries = entries
    this.selectedIndex = 0
    this.resultsTarget.replaceChildren()

    if (entries.length === 0) {
      const empty = document.createElement("p")
      empty.className = "command-palette__empty"
      empty.textContent = "No matching component or guide."
      this.resultsTarget.append(empty)
      return
    }

    entries.forEach((entry, index) => {
      const button = document.createElement("button")
      button.type = "button"
      button.className = `command-result${index === 0 ? " is-selected" : ""}`
      button.setAttribute("role", "option")
      button.addEventListener("mouseenter", () => this.select(index))
      button.addEventListener("click", () => this.visit(index))

      const mark = document.createElement("span")
      mark.className = "command-result__mark"
      mark.textContent = entry.meta === "Guide" ? "G" : "Z"
      const copy = document.createElement("span")
      const label = document.createElement("strong")
      label.textContent = entry.label
      const meta = document.createElement("small")
      meta.textContent = entry.meta
      copy.append(label, meta)
      const arrow = document.createElement("span")
      arrow.textContent = "↗"
      button.append(mark, copy, arrow)
      this.resultsTarget.append(button)
    })
  }

  navigate(event) {
    if (event.key === "Escape") return this.close()
    if (event.key === "Enter") {
      event.preventDefault()
      return this.visit(this.selectedIndex)
    }
    if (!["ArrowDown", "ArrowUp"].includes(event.key) || this.currentEntries.length === 0) return
    event.preventDefault()
    const direction = event.key === "ArrowDown" ? 1 : -1
    this.select((this.selectedIndex + direction + this.currentEntries.length) % this.currentEntries.length)
  }

  select(index) {
    this.selectedIndex = index
    this.resultsTarget.querySelectorAll(".command-result").forEach((result, resultIndex) => {
      result.classList.toggle("is-selected", resultIndex === index)
    })
  }

  visit(index) {
    const entry = this.currentEntries[index]
    if (entry) window.Turbo.visit(entry.path)
  }
}
