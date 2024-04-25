public with sharing class CTLocationController {

    /**
     * Get 100 contacts with recent health status change
     * @return List<Location__c>
     */
    public static List<Location__c> getRecentHealthChanges(){
        return [
            SELECT 
                Id, Name, Address__c, Pincode__c, 
                Red_Score__c, Status_Update_Date__c, Status__c 
            FROM Location__c
            ORDER BY Status_Update_Date__c DESC NULLS LAST 
            LIMIT 100
        ];
    }

    /**
     * Search a location by name, pin code or address
     * @param  searchString Search term
     * @return List<Location__c>
     */
    public static List<Location__c> searchLocations(String searchString){
        searchString = searchString + '%';
        return [
            SELECT 
                Id, Name, Address__c, Pincode__c, 
                Red_Score__c, Status_Update_Date__c, Status__c 
            FROM Location__c
            WHERE Name LIKE :searchString 
                OR Pincode__c LIKE :searchString 
                OR Address__c LIKE :searchString
            ORDER BY Status_Update_Date__c DESC NULLS LAST
        ];
    }

    /**
     * Search a location by id
     * @param  locationId The location id
     * @return Location__c
     */
    public static Location__c getLocationById(String locationId){
        List<Location__c> locations = [
            SELECT 
                Id, Name, Address__c, Pincode__c, 
                Red_Score__c, Status_Update_Date__c, Status__c 
            FROM Location__c
            WHERE Id = :locationId
        ];

        if (locations != null && locations.size() > 0) {
            return locations[0];
        }

        return null;
    }

    /**
     * @description Gets the count of each status.
     * @return   return
     */
    public static Map<String, Integer> getStatusCount() {
        AggregateResult[] statusCount = [
            SELECT 
                Status__c, COUNT(Id) statusTotal 
            FROM Location__c 
            GROUP BY Status__c
        ];

        if (statusCount != null && statusCount.size() > 0) {
            Map<String, Integer> statusCountMap = new Map<String, Integer>();
            for (AggregateResult ar : statusCount) {
                statusCountMap.put(
                    String.valueOf(ar.get('Status__c')), 
                    Integer.valueOf(ar.get('statusTotal'))
                );
            }
            return statusCountMap;
        }

        return null;        
    }

    /**
     * Update redScore of locations
     * Red score is updated based on the number of
     * red health status person visited the location
     * @param locationIds
     * @return locations
     */
    public static List<Location__c> updateRedScore(Set<Id> locationIds) {
        List<Location__c> locationRecordToUpdate = new List<Location__c>();
        AggregateResult[] redPeoplePerLocation = [
            SELECT Location__c, Count(Id) total
            FROM Location_Tracing__c
            WHERE Person__r.Health_Status__c = 'Red' AND Location__c IN :locationIds AND Visit_Date__c = LAST_N_DAYS:10
            GROUP BY Location__c
        ];
        for (AggregateResult ar : redPeoplePerLocation) {
            String locationId = String.valueOf(ar.get('Location__c'));
            Integer redScore = Integer.valueOf(ar.get('total'));
            String status = CTLocationController.getStatus(redScore);
            locationRecordToUpdate.add(new Location__c(Id = locationId, Red_Score__c = redScore, Status__c = status));
        }
        if (locationRecordToUpdate.size() > 0) {
            update locationRecordToUpdate;
        }
        return locationRecordToUpdate;
    }

    /**
     * get status of location based on red score
     * Red - If there are more than 10 people (Red Score) who visited the location in last 10 days are in red status
     * Orange - If there are more than 5 people (Red Score) who visited the location in last 10 days are in red status
     * Yellow - If there are more than 1 people (Red Score) who visited the location in last 10 days are in red status
     * Green - Safe
     * @param redScore
     * @return string status
     */
    public static String getStatus(Integer redScore) {
        if (redScore == 0) {
            return 'Green';
        } else if (redScore <= 5) {
            return 'Yellow';
        } else if (redScore <= 10) {
            return 'Orange';
        } else {
            return 'Red';
        }
    }
}