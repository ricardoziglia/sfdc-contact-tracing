({
    fetchHealthyStatusCount: function (component) {
        const viewType = component.get("v.viewType");

        let action = viewType === "person" ? component.get("c.getPersonHealthStatuscount") : component.get("c.getLocationHealthStatuscount");

        action.setCallback(this, function (response) {
            const state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.healthCounter", response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    }
})
