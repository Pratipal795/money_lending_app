import { Controller } from "@hotwired/stimulus"
// import * as bootstrap from "bootstrap"

// Connects to data-controller="turbo-modal"
export default class extends Controller {
  connect() {
    this.modal = new bootstrap.Modal(this.element, {
      keyboard: false
    })
    this.modal.show()
  }

  disconnect() {
    this.modal.hide()
  }

  submitEnd(event){
    this.modal.hide()
    console.log("check my sumit action")

  }
}
