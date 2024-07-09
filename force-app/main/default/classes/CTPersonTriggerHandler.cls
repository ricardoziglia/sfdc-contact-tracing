public with sharing class CTPersonTriggerHandler {
    
    /**
     * @description Before Insert operation for Person__c object 
     * @param  newRecords newRecords Trigger.new
     */
    public static void beforeInsert(List<Person__c> newRecords) {
        for (Person__c person : newRecords) {
            person.Health_Status__c = 'Green';
            person.Token__c = CTPersonController.getToken(person.Mobile__c);
        }
    }

    /**
     * @description Before Update operation for Person__c object
     * @param  people    people Trigger.new
     * @param  oldValues oldValues Trigger.oldMap
     */
    public static void beforeUpdate(List<Person__c> people, Map<Id, Person__c> oldValues) {
        for (Person__c person : people) {
            if (person.Health_Status__c != oldValues.get(person.Id).Health_Status__c) {
                person.Status_Update_Date__c = Date.today();
            }
        }
    }

    /**
     * @description After Update operation for Person__c object
     * @param  people    people Trigger.new
     * @param  oldValues oldValues Trigger.oldMap
     */
    public static void afterUpdate(List<Person__c> people, Map<Id, Person__c> oldValues) {
        List<Person__c> personRecordToUpdate = new List<Person__c>();
        Set<Id> statusChanged = new Set<Id>();
        Set<Id> redStatus = new Set<Id>();

        for (Person__c person : people) {
            // check if the status changed in this transaction
            if (person.Health_Status__c != oldValues.get(person.Id).Health_Status__c) {
                statusChanged.add(person.Id);
            }
            // check if person health status is red
            // also check if the status changed in this transaction to avoid duplicate processing
            if (person.Health_Status__c == 'Red' && oldValues.get(person.Id).Health_Status__c != 'Red') {
                redStatus.add(person.Id);
            }
        }

        // Id of people to avoid duplicate processing
        Set<Id> processedRecords = new Set<Id>();
        processedRecords.addAll(redStatus);
        // list of people to update the status to Orange
        Set<Id> orangeStatus = new Set<Id>();
        // list of people to update the status to Yellow
        Set<Id> yellowStatus = new Set<Id>();

        orangeStatus.addAll(CTPersonController.getCohabitants(redStatus, processedRecords));
        Set<Id> primaryContacts = CTPersonController.getPrimaryContacts(redStatus, processedRecords);
        orangeStatus.addAll(primaryContacts);
        yellowStatus.addAll(CTPersonController.getNeighbours(redStatus, processedRecords));
        yellowStatus.addAll(CTPersonController.getSecondaryContacts(primaryContacts, processedRecords));

        for (Id personId : orangeStatus) {
            personRecordToUpdate.add(new Person__c(Id = personId, Health_Status__c = 'Orange'));
        }

        for (Id personId : yellowStatus) {
            personRecordToUpdate.add(new Person__c(Id = personId, Health_Status__c = 'Yellow'));
        }

        List<Location_Tracing__c> locations = CTLocationTracingController.getLocationsByPersonIds(statusChanged);
        if (locations != null && locations.size() > 0) {
            Set<Id> locationIds = new Set<Id>();
            for (Location_Tracing__c trace : locations) {
                locationIds.add(trace.Location__c);
            }
            CTLocationController.updateRedScore(locationIds);
        }

        if (personRecordToUpdate.size() > 0) {
            update personRecordToUpdate;
        }
    }
}