
public with sharing class CTPersonController {
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
        } else {
            return null;
        }
    }
}