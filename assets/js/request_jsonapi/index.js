/** LiveView Hook **/

import jQuery from "jquery"
import select2 from "select2"
import "select2/dist/css/select2.css"

const SelectPrimaryResource = {
  initSelect2() {
    let hook = this;
    let $select = jQuery(hook.el).find("select");
    return $select.select2().on("select2:select", (e) => hook.selected(hook, e))
  },

  mounted() {
    console.log("SelectPrimaryResource mounted")
    this.initSelect2();
  },

  selected(hook, event) {
    let id = event.params.data.id;
    console.log("SelectPrimaryResource selected", id)
    hook.pushEvent("primary_resource_selected", {resource: id})
  }
}

export default SelectPrimaryResource
