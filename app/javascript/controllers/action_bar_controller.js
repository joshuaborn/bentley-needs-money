import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="action-bar"
export default class extends Controller {
    static targets = [ "enabledAdd", "disabledAdd", "enabledSettle", "disabledSettle" ]
    static values = [ "link" ]

    disableNewTransaction() {
        this.enabledAddTarget.style.display = "none"
        this.disabledAddTarget.style.display = ""
        this.enabledSettleTarget.style.display = ""
        this.disabledSettleTarget.style.display = "none"
    }
    
    enableNewTransaction() {
        this.enabledAddTarget.style.display = ""
        this.disabledAddTarget.style.display = "none"
    }

    disablePayback() {
        this.enabledSettleTarget.style.display = "none"
        this.disabledSettleTarget.style.display = ""
        this.enabledAddTarget.style.display = ""
        this.disabledAddTarget.style.display = "none"
    }

    enablePayback() {
        this.enabledSettleTarget.style.display = ""
        this.disabledSettleTarget.style.display = "none"
    }
}
