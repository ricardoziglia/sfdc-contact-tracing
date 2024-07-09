public with sharing class CTLocationTriggerHandler {
    public static void beforeInsert(List<Location__c> newRecords) {
        for (Location__c location : newRecords) {
            location.Status__c = 'Green';
        }
    }

    public static void beforeUpdate(List<Location__c> updatedRecords, Map<Id, Location__c> oldRecordsMap) {
        for (Location__c location : updatedRecords) {
            if (location.Status__c != oldRecordsMap.get(location.Id).Status__c) {
                location.Status_Update_Date__c = Date.today();
            }
        }
    }

    public static void afterUpdate(List<Location__c> updatedRecords, Map<Id, Location__c> oldRecordsMap) {
        Set<Id> statusChangedLocationIds = new Set<Id>();
        for (Location__c location : updatedRecords) {
            if (location.Status__c != oldRecordsMap.get(location.Id).Status__c && location.Status__c == 'Red') {
                statusChangedLocationIds.add(location.Id);
            }
        }

        List<Location_Tracing__c> locationTraces = CTLocationTracingController.getLocationsByLocationIds(statusChangedLocationIds);
        Set<Id> personIds = new Set<Id>();
        for (Location_Tracing__c locationTrace : locationTraces) {
            personIds.add(locationTrace.Person__c);
        }

        List<Person__c> peopleToUpdate = new List<Person__c>();
        for (Id personId : personIds) {
            peopleToUpdate.add(new Person__c(Id=personId, Health_Status__c = 'Yellow'));
        }
        if (peopleToUpdate.size() > 0) {
            update peopleToUpdate;
        }
    }
}
