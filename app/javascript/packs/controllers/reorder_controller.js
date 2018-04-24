import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    console.log("Reorder controller loaded")
  }

  dragstart(event) {
    event.dataTransfer.setData("application/drag-key", event.target.getAttribute("data-position"))
    event.dataTransfer.effectAllowed = "move"
  }

  dragover(event) {
    event.preventDefault()
    return true
  }

  dragenter(event) {
    event.preventDefault()
    return true
  }

  drop(event) {
    var data = event.dataTransfer.getData("application/drag-key")
    const dropTarget = this.getDroptarget(event.target)
    const draggedItem = this.element.querySelector(`[data-position='${data}']`)
    const positionComparison = dropTarget.compareDocumentPosition(draggedItem)

    if (positionComparison & 4) {
      dropTarget.insertAdjacentElement('beforebegin', draggedItem)
    } else if ( positionComparison & 2) {
      dropTarget.insertAdjacentElement('afterend', draggedItem)
    }

    event.preventDefault()
  }

  dragend(event) {
    let reorderItems = this.element.querySelectorAll('.reorder-item')
    let positions = []

    reorderItems.forEach(function(reorderItem, i) {
      reorderItem.setAttribute('data-position', i)

      positions.push([ reorderItem.getAttribute('data-id') ])
    })

    console.log(positions)
    this.save(positions)
  }

  save(positions) {
    var formData = new FormData()

    formData.append('positions', positions)

    fetch(
        this.data.get('url'), 
        this.formParams('POST', formData)
      )
      .then(response => {
        console.log(response.text())
      })
  }

  formParams(method, data) {
    return {
      method: method, 
      body: data,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.securityToken()
      },
      credentials: 'same-origin'
    }
  }

  securityToken() {
    return document.querySelector('meta[name=csrf-token]').content
  }

  getDroptarget(element) {
    if (element.classList.contains('reorder-item')) {
      return element
    } else {
      return this.getDroptarget(element.parentNode)
    }
  }
}