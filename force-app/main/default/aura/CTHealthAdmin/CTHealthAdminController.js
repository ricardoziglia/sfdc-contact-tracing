({
    tabsetSelectHandler : function(component, event, helper) {
        const selectedTabId = event.getParam("id");
        if (selectedTabId === "person_view") {
            component.set("v.headerTitle", "Person View");
        } else {
            component.set("v.headerTitle", "Location View");
        }
    }
})
