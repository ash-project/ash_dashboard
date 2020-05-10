/** LiveView Hook **/

import jQuery from "jquery"
import select2 from "select2"
import "select2/dist/css/select2.css"

const SelectPrimaryResource = {
  _initSelect2(id, opts={}) {
    console.log(`${id} mounted`)
    let $select = jQuery(this.el).find(id);
    return $select.select2(opts).on("select2:select", (e) => this.selected(this, e))
  },

  mounted() {
    this._initSelect2("#select-primary-resource");
  },

  selected(hook, event) {
    let id = event.params.data.id;
    console.log("SelectPrimaryResource selected", id)
    hook.pushEvent("primary_resource_selected", {primary_resource: id})
  }
}

export default SelectPrimaryResource
