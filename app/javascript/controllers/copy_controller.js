import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = { value: String }

  async copy() {
    await navigator.clipboard.writeText(this.valueValue)
    const previous = this.buttonTarget.textContent
    this.buttonTarget.textContent = "Copied ✓"
    this.buttonTarget.classList.add("is-copied")
    window.setTimeout(() => {
      this.buttonTarget.textContent = previous
      this.buttonTarget.classList.remove("is-copied")
    }, 1400)
  }
}
