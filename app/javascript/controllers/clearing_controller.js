import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="clearing"
export default class extends Controller {
    static targets = [ "container" ]

    clearChildren(event) {
        event.preventDefault()
        this.containerTarget.replaceChildren()
    }
}
