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

}