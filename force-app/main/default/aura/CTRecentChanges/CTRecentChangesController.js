({
    doInit: function (component, event, helper) {
        component.set("v.columns", helper.getColumns(component.get("v.viewType")));
        helper.fetchResult(component);
    },

    onChangeViewType : function(component, event, helper) {
        helper.fetchResult(component);
    }
});
