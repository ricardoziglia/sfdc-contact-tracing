({
    onChangeViewType : function(component, event, helper) {
        if (event.getParam("value") === "person") {
            component.set("v.headerTitle", "Person View");
        } else {
            component.set("v.headerTitle", "Location View");
        }
        //Calling it from parent component via component method fetchCount
        //helper.fetchHealthyStatusCount(component);
    },
    createRecord : function (component, event, helper) {
        const entityApiName = component.get("v.viewType") === "person" ? "Person__c" : "Location__c";
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": entityApiName
        });
        createRecordEvent.fire();
    },
    doInit: function (component, event, helper) {
        helper.fetchHealthyStatusCount(component);
    }
})
