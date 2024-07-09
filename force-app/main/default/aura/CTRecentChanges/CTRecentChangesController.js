({
    doInit: function (component, event, helper) {
        component.set("v.columns", helper.getColumns(component.get("v.viewType")));
        helper.fetchRecentHealthChanges(component);
    },

    handleKeyUp: function (component, event, helper) {
        const isEnterKey = event.keyCode === 13;
        var queryTerm = component.find('enter-search').get('v.value');

        if (isEnterKey) {
            if (queryTerm) {
                helper.searchHealthChanges(component, queryTerm);
            } else {
                helper.fetchRecentHealthChanges(component);
            }
        } else if (!queryTerm) {
            component.set("v.data", component.get("v.lastRecentHealthChangesResponse"));
        }
    },
    handleRowAction: function (component, event, helper) {
        const action = event.getParam("action");
        const row = event.getParam("row");
        const viewType = component.get("v.viewType");

        switch (action.name) {
            case "view_details":
                const appEvent = viewType === "person" ? $A.get("e.c:CTPersonSelectEvent") : $A.get("e.c:CTLocationSelectEvent");
                appEvent.setParams({
                    recordId: row.Id,
                    status: viewType === "person" ? row.Health_Status__c : row.Status__c
                });
                appEvent.fire();
                break;
        }
    }
});
