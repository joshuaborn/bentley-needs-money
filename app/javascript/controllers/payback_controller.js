import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="payback"
export default class extends Controller {
    static targets = [ "selector" ]
    static values = [  ]

    changePerson() {
        var selectedInput = this.element.querySelector("#payback_amount_" + this.selectorTarget.value)
        this.element.querySelectorAll('.field.amount').forEach(function(el) {
            el.style.display = "none"
            el.querySelector("input").disabled = true
        })
        selectedInput.style.display = ""
        selectedInput.querySelector("input").disabled = false
    }
}
