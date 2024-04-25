trigger CTLocationTrigger on Location__c (before insert, before update, before delete) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            CTLocationTriggerHandler.beforeInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            CTLocationTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

}