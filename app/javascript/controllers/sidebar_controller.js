import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]

  open() {
    this.panelTarget.classList.add("is-open")
    this.backdropTarget.classList.add("is-open")
    document.body.classList.add("has-drawer")
  }

  close() {
    this.panelTarget.classList.remove("is-open")
    this.backdropTarget.classList.remove("is-open")
    document.body.classList.remove("has-drawer")
  }
}
