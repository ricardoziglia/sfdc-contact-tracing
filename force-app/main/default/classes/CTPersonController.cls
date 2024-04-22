
public with sharing class CTPersonController {
    
    /**
     * generate unique token using mobile number
     * use MD5 algorithm to generate one-way hash
     * @param mobile
     * @return string token
     */
    public static String getToken(String mobileNumber) {
        Blob hashToken = Crypto.generateDigest('MD5', Blob.valueOf(mobileNumber));
        return EncodingUtil.base64Encode(hashToken);
    }

    /**
     * Get 100 contacts with recent health status change
     * @return List<Person__c>
     */
    public static List<Person__c> getRecentHealthChanges(){
        return [
            SELECT 
                Id, Name, Health_Status__c, 
                Mobile__c, Status_Update_Date__c, 
                Token__c 
            FROM Person__c
            ORDER BY Status_Update_Date__c DESC NULLS LAST 
            LIMIT 100
        ];
    }

    /**
     * Search a person by name, token or mobile
     * @param  searchString search term
     * @return List<Person__c>
     */
    public static List<Person__c> searchPeople(String searchString){
        searchString = searchString + '%';
        return [
            SELECT 
                Id, Name, Health_Status__c, 
                Mobile__c, Status_Update_Date__c, 
                Token__c 
            FROM Person__c
            WHERE Name LIKE :searchString 
                OR Mobile__c LIKE :searchString 
                OR Token__c LIKE :searchString
            ORDER BY Status_Update_Date__c DESC NULLS LAST
        ];
    }

    /**
     * Search a person by id
     * @param  personId The person Id
     * @return Person__c
     */
    public static Person__c getPersonById(String personId){
        List<Person__c> people = [
            SELECT 
                Id, Name, Health_Status__c, 
                Mobile__c, Status_Update_Date__c, Token__c 
            FROM Person__c
            WHERE Id = :personId
        ];

        if (people != null && people.size() > 0) {
            return people[0];
        }
        
        return null;
    }

    /**
     * @description Gets the count of each heath status.
     * @return   return
     */
    public static Map<String, Integer> getHealthStatusCount() {
        Map<String, Integer> healthStatusCount = new Map<String, Integer>();
        AggregateResult[] aggregateResults = [
            SELECT 
                Health_Status__c, COUNT(Id) statusTotal
            FROM Person__c
            GROUP BY Health_Status__c
        ];

        if (healthStatusCount != null && healthStatusCount.size() > 0) {
            for (AggregateResult result: aggregateResults) {
                healthStatusCount.put(
                    String.valueOf(result.get('Health_Status__c')), 
                    Integer.valueOf(result.get('statusTotal'))
                );
            }
            return healthStatusCount;
        }

        return null;        
    }
}