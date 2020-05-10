/** LiveView Hook **/

import jQuery from "jquery"
import select2 from "select2"
import "select2/dist/css/select2.css"

const _initSelect2 = (hook, id, opts={}) => {
  let $select = jQuery(hook.el).find(id);
  $select.select2(opts).on("select2:select", (e) => hook.selected(hook, e));
  $select.select2(opts).on("select2:unselect", (e) => hook.unselect(hook, e));
}

const SelectPrimaryResource = {
  mounted() {
    _initSelect2(this, "#select-primary-resource");
  },

  selected(hook, event) {
    hook.pushEvent("primary_resource_selected", {primary_resource: event.params.data.id})
  }
}

const SelectRelationshipResource = {
  mounted() {
    _initSelect2(this, "#select-relationship-resource");
  },

  selected(hook, event) {
    hook.pushEvent("relationship_resource_selected", {relationship_resource: event.params.data.id})
  }
}

const SelectIncludedResources = {
  mounted() {
    _initSelect2(this, "#select-included-resources");
  },

  unselect(hook, event) {
    console.log("unselect", event)
    hook.pushEvent("included_resource_unselected", {resource: event.params.data.id})
  },

  selected(hook, event) {
    console.log("selected", event)
    hook.pushEvent("included_resource_selected", {resource: event.params.data.id})
  }
}

export { SelectPrimaryResource, SelectRelationshipResource, SelectIncludedResources }
