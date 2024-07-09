public with sharing class CTPeopleTracingController {
    public CTPeopleTracingController() {

    }

    /**
     * Get traces from a specific person
     * @param personId
     * @return List<People_Tracing__c>
     */
    public static List<People_Tracing__c> getTraces(String personId) {
        return [
            SELECT 
                Id, Contact_Date__c, 
                Person_1__c, Person_1__r.Token__c, Person_1__r.Health_Status__c, 
                Person_2__c, Person_2__r.Token__c, Person_2__r.Health_Status__c
            FROM People_Tracing__c
            WHERE Person_1__c =:personId
            OR Person_2__c =:personId
            ORDER BY Contact_Date__c DESC NULLS LAST
        ];
    }

    /**
     * Check duplicate People Tracing records
     * for multiple combinations
     * @param peopleTraces List of People_Tracing__c to be checked
     * @return boolean
     */
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> peopleTraces) {
        // unique records ids
        Set<Id> recordIds = new Set<Id>();
        for (People_Tracing__c trace : peopleTraces) {
            recordIds.add(trace.Person_1__c);
            recordIds.add(trace.Person_2__c);
        }
        //list of duplicate records
        List<People_Tracing__c> duplicates = new List<People_Tracing__c>();
        // map of existing records to match
        Map<Id, Set<Id>> mapOfExistingRecord = new Map<Id, Set<Id>>();

        List<People_Tracing__c> existingRecords = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c WHERE Person_1__c IN :recordIds OR Person_2__c IN :recordIds];

        if (existingRecords != null && existingRecords.size() > 0) {
            for (People_Tracing__c trace : existingRecords) {
                if (!mapOfExistingRecord.containsKey(trace.Person_1__c)) {
                    mapOfExistingRecord.put(trace.Person_1__c, new Set<Id>());
                }
                mapOfExistingRecord.get(trace.Person_1__c).add(trace.Person_2__c);

                if (!mapOfExistingRecord.containsKey(trace.Person_2__c)) {
                    mapOfExistingRecord.put(trace.Person_2__c, new Set<Id>());
                }
                mapOfExistingRecord.get(trace.Person_2__c).add(trace.Person_1__c);
            }

            for (People_Tracing__c trace : peopleTraces) {
                // check if record is duplicate
                if (
                    (mapOfExistingRecord.containsKey(trace.Person_1__c) && mapOfExistingRecord.get(trace.Person_1__c).contains(trace.Person_2__c)) ||
                    (mapOfExistingRecord.containsKey(trace.Person_2__c) && mapOfExistingRecord.get(trace.Person_2__c).contains(trace.Person_1__c))
                ) {
                    duplicates.add(trace);
                }
            }
        }
        return duplicates;
    }
}