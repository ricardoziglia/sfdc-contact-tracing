({
    tabsetSelectHandler : function(component, event, helper) {
        const selectedTabId = event.getParam("id");
        component.set("v.viewType", selectedTabId);

        const healthHeaderComp = component.find("health-header");
        healthHeaderComp.fetchCount();
    }
})
