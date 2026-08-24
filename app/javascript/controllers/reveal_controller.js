import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.element.classList.add("is-revealed")
      return
    }

    this.observer = new IntersectionObserver((entries) => {
      if (entries.some((entry) => entry.isIntersecting)) {
        this.element.classList.add("is-revealed")
        this.observer.disconnect()
      }
    }, { threshold: 0.08 })

    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
