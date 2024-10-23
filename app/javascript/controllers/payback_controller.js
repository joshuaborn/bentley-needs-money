import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payback"
export default class extends Controller {
    static targets = [ "selector" ]
    static values = [  ]

    changePerson() {
        this.element.querySelectorAll('.field.amount').forEach(function(el) {
            el.style.display = "none"
        })
        this.element.querySelector("#payback_amount_" + this.selectorTarget.value).style.display = ""
    }
}
