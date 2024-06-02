({
    doInit: function (component, event, helper) {
        const columns = [
            { label: "Name", fieldName: "Name", type: "text" },
            { label: "Phone", fieldName: "Mobile__c", type: "phone" },
            { label: "Token", fieldName: "Token__c", type: "text" },
            { label: "Status", fieldName: "Health_Status__c", type: "text" },
            { label: "Status Update Date", fieldName: "Status_Update_Date__c", type: "date" }
            
        ];
        component.set("v.columns", columns);

        // get previous results
        helper.fetchResult(component);
    },

    onResultHandler: function (component, event, helper) {
        // get previous results
        helper.fetchResult(component);
    }
});
