/** LiveView Hook **/

import jQuery from "jquery"
import select2 from "select2"
import "select2/dist/css/select2.css"

const SelectResource = {

  initSelect2() {
    let hook = this,
        $select = jQuery(hook.el).find("select");
    
    $select.select2()
    .on("select2:select", (e) => hook.selected(hook, e))
    
    return $select;
  },

  mounted() {
    console.log("SelectInput mounted")
    this.initSelect2();
  },

  selected(hook, event) {
    console.log("SelectInput selected")
    console.log({event})
    console.log("SelectInput selected")
    let id = event.params.data.id;
    hook.pushEvent("resource_selected", {resource: id})
  }
}

export default SelectResource
