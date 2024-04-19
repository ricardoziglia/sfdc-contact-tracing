public with sharing class CTLocationTracingController {
    public CTLocationTracingController() {

    }

    /**
     * Get all location visitors
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getVisitors(String locationId) {
        return [
            SELECT 
                Id, Name, Person__c, Location__c, Visit_Date__c 
            FROM Location_Tracing__c
            WHERE Id =:locationId
            ORDER BY Visit_Date__c DESC NULLS LAST
        ];
    }

    /**
     * Get location visitors from the last 10 days.
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationsByPersonIds(Set<Id> personIds) {
        return [
            SELECT 
                Id, Name, Person__c, Location__c, Visit_Date__c 
            FROM Location_Tracing__c
            WHERE Person__c IN :personIds
                AND Visit_Date__c = LAST_N_DAYS:10
            ORDER BY Visit_Date__c DESC NULLS LAST
        ];
    }

    /**
     * Get all location visitor with Green status from the last 10 days.
     * @param locationIds
     * @return List<Location_Tracing__c>
     */
    public static List<Location_Tracing__c> getLocationsByLocationIds(Set<Id> locationIds) {
        return [
            SELECT 
                Id, Location__c, Person__c 
            FROM Location_Tracing__c 
            WHERE Location__c IN :locationIds 
                AND Visit_Date__c = LAST_N_DAYS:10
                AND Person__r.Health_Status__c = 'Green'
        ];
    }

    /**
     * Check duplicate Location Tracing records
     * @param locationTraces - List of location traces to be checked.
     * @return List<Location_Tracing__c> duplicated records.
     */
    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> locationTraces) {
        List<Location_Tracing__c> duplicates = new List<Location_Tracing__c>();
        Map<Id, Set<Id>> mapOfExistingRecord = new Map<Id, Set<Id>>();
        Set<Id> locationIds = new Set<Id>();
        Set<Id> personIds = new Set<Id>();

        for (Location_Tracing__c trace : locationTraces) {
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        List<Location_Tracing__c> existingRecords = [
            SELECT Id, Location__c, Person__c 
            FROM Location_Tracing__c 
            WHERE Location__c IN :locationIds
            OR Person__c IN :personIds
        ];

        if (existingRecords != null && existingRecords.size() > 0) {
            for (Location_Tracing__c trace : existingRecords) {
                if (!mapOfExistingRecord.containsKey(trace.Location__c)) {
                    mapOfExistingRecord.put(trace.Location__c, new Set<Id>());
                }
                mapOfExistingRecord.get(trace.Location__c).add(trace.Person__c);
            }

            for (Location_Tracing__c trace : locationTraces) {
                // check if record is duplicate
                if ((mapOfExistingRecord.containsKey(trace.Location__c) && mapOfExistingRecord.get(trace.Location__c).contains(trace.Person__c))) {
                    duplicates.add(trace);
                }
            }
        }
        return duplicates;
    }


}