({
    fetchResult: function (component) {
        let action = component.get("v.viewType") === "person" ? component.get("c.getRecentPersonHealthChanges") : component.get("c.getRecentLocationHealthChanges");
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const resp = response.getReturnValue();
                component.set("v.data", resp);
            }
        });
        $A.enqueueAction(action);
    },
    getColumns: function (viewType) {
        if (viewType === "person") {
            return [
                { label: "Name", fieldName: "Name", type: "text" },
                { label: "Phone", fieldName: "Mobile__c", type: "phone" },
                { label: "Token", fieldName: "Token__c", type: "text" },
                { label: "Health Status", fieldName: "Health_Status__c", type: "text" },
                { label: "Status Update Date", fieldName: "Status_Update_Date__c", type: "date" }
                
            ];
        } else {
            return [
                { label: "Name", fieldName: "Name", type: "text" },
                { label: "Status", fieldName: "Status__c", type: "text" },
                { label: "Red Score", fieldName: "Red_Score__c", type: "number" },
                { label: "Pincode", fieldName: "Pincode__c", type: "text" },
                { label: "Address", fieldName: "Address__c", type: "text" },
                { label: "Status Update Date", fieldName: "Status_Update_Date__c", type: "date" }
            ];
        }
    }
});
