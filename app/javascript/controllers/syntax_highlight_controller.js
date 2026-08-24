import { Controller } from "@hotwired/stimulus"
import { highlightCode } from "lexxy"

export default class extends Controller {
  connect() {
    this.element.querySelectorAll("pre").forEach((pre) => {
      if (pre.dataset.language) return

      const code = pre.querySelector("code[class*='language-']")
      const languageClass = Array.from(code?.classList || []).find((name) => name.startsWith("language-"))

      if (languageClass) pre.dataset.language = languageClass.replace("language-", "")
    })

    highlightCode(this.element)
  }
}
