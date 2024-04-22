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
}