// import { Controller } from "@hotwired/stimulus";

// export default class extends Controller {
//   connect() {
//     console.log('erhjashdghjagdhasd')
//     document.addEventListener("turbo:submit-end", this.closeModal);
//   }

//   disconnect() {
//     console.log('erhjashdghjagdhasd')
//     document.removeEventListener("turbo:submit-end", this.closeModal);
//   }

//   closeModal(event) {
//     if (event.detail.success) {
//     console.log('erhjashdghjagdhasd')
//       const modalElement = event.target.closest(".modal");
//       if (modalElement) {
//         const modal = bootstrap.Modal.getInstance(modalElement);
//         modal.hide();
//       }
//     }
//   }
// }


import { Controller } from "@hotwired/stimulus";
import { Modal } from "bootstrap";

export default class extends Controller {
  connect() {
    console.log("Stimulus modal controller connected");
    this.element.addEventListener("turbo:submit-end", this.closeModal.bind(this));
  }

  disconnect() {
    console.log("Stimulus modal controller disconnected");
    this.element.removeEventListener("turbo:submit-end", this.closeModal.bind(this));
  }

  closeModal(event) {
    if (event.detail.success) {
      console.log("Form submitted successfully, closing modal");
      const modalElement = this.element.closest(".modal");
      if (modalElement) {
        const modal = Modal.getInstance(modalElement) || new Modal(modalElement);
        modal.hide();
      }
    } else {
      console.log("Form submission failed, keeping modal open");
    }
  }
}
