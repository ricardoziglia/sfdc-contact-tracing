({
    doInit: function (component, event, helper) {
        component.set("v.columns", helper.getColumns(component.get("v.viewType")));
        helper.fetchRecentHealthChanges(component);
    },

    handleKeyUp: function (component, event, helper) {
        var isEnterKey = event.keyCode === 13;
        var queryTerm = component.find('enter-search').get('v.value');
        if (!queryTerm) {
            helper.searchHealthChanges(component, queryTerm);
        } else if (isEnterKey) {
            if (queryTerm) {
                helper.searchHealthChanges(component, queryTerm);
            } else {
                helper.fetchRecentHealthChanges(component);
            }
        }
    }
});
