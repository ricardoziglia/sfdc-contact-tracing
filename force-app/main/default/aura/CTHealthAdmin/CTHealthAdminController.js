({
    tabsetSelectHandler : function(component, event, helper) {
        const selectedTabId = event.getParam("id");
        component.set("v.viewType", selectedTabId);

        // Calling it from CTHealthHeader component via onChangeViewType, letting the component handle it internally.
        // const healthHeaderComp = component.find("health-header");
        // healthHeaderComp.fetchCount();
    }
})
