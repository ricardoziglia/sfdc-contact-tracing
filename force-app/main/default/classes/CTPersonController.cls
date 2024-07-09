
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
     * @description Gets the total count of each health status;
     * @return   return
     */
    public static Map<String, Integer> getHealthStatusCount() {
        AggregateResult[] healthStatusCount = [
            SELECT 
                Health_Status__c, COUNT(Id) statusTotal
            FROM Person__c
            GROUP BY Health_Status__c
        ];

        if (healthStatusCount != null && healthStatusCount.size() > 0) {
            Map<String, Integer> healthStatusCountMap = new Map<String, Integer>();
            for (AggregateResult ar : healthStatusCount) {
                healthStatusCountMap.put(
                    String.valueOf(ar.get('Health_Status__c')), 
                    Integer.valueOf(ar.get('statusTotal'))
                );
            }
            return healthStatusCountMap;
        }

        return null;        
    }

    /**
     * Get list of all cohabitants
     * Only include people in "Green" and "Yellow" health status
     * @param positivePeople
     * @return people
     */
    public static Set<Id> getCohabitants(Set<Id> positivePeople, Set<Id> idsToIgnore) {
        // list of all status to find
        List<String> healthStatuses = new List<String>{ 'Yellow', 'Green' };
        List<People_Tracing__c> peopleTraces = [
            SELECT Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :positivePeople
                OR Person_2__c IN :positivePeople)
                AND Contact_Type__c = 'Cohabitant'
                AND (Person_1__r.Health_Status__c IN :healthStatuses
                OR Person_2__r.Health_Status__c IN :healthStatuses)
        ];

        // Ids of all cohabitants
        Set<Id> cohabitants = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces) {
            // if both person 1 and person 2 already exist in positive people list, do nothing
            // else add the person to cohabitants
            if (!idsToIgnore.contains(pt.Person_1__c)) {
                // add person 1
                cohabitants.add(pt.Person_1__c);
                idsToIgnore.add(pt.Person_1__c);
            } else if (idsToIgnore.contains(pt.Person_1__c)) {
                // add person 2
                cohabitants.add(pt.Person_2__c);
                idsToIgnore.add(pt.Person_2__c);
            }
        }
        return cohabitants;
    }

    /**
     * Get list of all neighbours
     * Only include people in Green status
     * @param positivePeople
     * @return people
     */
    public static Set<Id> getNeighbours(Set<Id> positivePeople, Set<Id> idsToIgnore) {
        List<People_Tracing__c> peopleTraces = [
            SELECT Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :positivePeople
                OR Person_2__c IN :positivePeople)
                AND Contact_Type__c = 'Neighbour'
                AND (Person_1__r.Health_Status__c = 'Green'
                OR Person_2__r.Health_Status__c = 'Green')
        ];

        // Ids of all neighbours
        Set<Id> neighbours = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces) {
            // if both person 1 and person 2 already exist in positive people list, do nothing
            // else add the person to neighbours
            if (!idsToIgnore.contains(pt.Person_1__c)) {
                // add person 1
                neighbours.add(pt.Person_1__c);
                idsToIgnore.add(pt.Person_1__c);
            } else if (idsToIgnore.contains(pt.Person_1__c)) {
                // add person 2
                neighbours.add(pt.Person_2__c);
                idsToIgnore.add(pt.Person_2__c);
            }
        }
        return neighbours;
    }

    /**
     * Get list of primary contacts
     * Only include people in "Green" and "Yellow" health status
     * @param positivePeople
     * @return people
     */
    public static Set<Id> getPrimaryContacts(Set<Id> positivePeople, Set<Id> idsToIgnore) {
        // list of all status to find
        List<String> healthStatuses = new List<String>{ 'Yellow', 'Green' };
        List<People_Tracing__c> peopleTraces = [
            SELECT Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :positivePeople
                OR Person_2__c IN :positivePeople)
                AND Contact_Type__c = 'Other'
                AND Contact_Date__c = LAST_N_DAYS:10
                AND (Person_1__r.Health_Status__c IN :healthStatuses
                OR Person_2__r.Health_Status__c IN :healthStatuses)
        ];

        // Ids of all primary contacts
        Set<Id> primaryContacts = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces) {
            // if both person 1 and person 2 already exist in already processed list, do nothing
            // else add the person to primary contacts set
            if (!idsToIgnore.contains(pt.Person_1__c)) {
                // add person 1
                primaryContacts.add(pt.Person_1__c);
                idsToIgnore.add(pt.Person_1__c);
            } else if (idsToIgnore.contains(pt.Person_1__c)) {
                // add person 2
                primaryContacts.add(pt.Person_2__c);
                idsToIgnore.add(pt.Person_2__c);
            }
        }
        return primaryContacts;
    }

    /**
     * Get list of all secondary contacts
     * Only include people in Green status
     * @param primaryContacts
     * @return people
     */
    public static Set<Id> getSecondaryContacts(Set<Id> primaryContacts, Set<Id> idsToIgnore) {
        List<People_Tracing__c> peopleTraces = [
            SELECT Person_1__c, Person_2__c
            FROM People_Tracing__c
            WHERE
                (Person_1__c IN :primaryContacts
                OR Person_2__c IN :primaryContacts)
                AND Contact_Type__c = 'Other'
                AND Contact_Date__c = LAST_N_DAYS:10
                AND (Person_1__r.Health_Status__c = 'Green'
                OR Person_2__r.Health_Status__c = 'Green')
        ];

        // Ids of all secondary contacts
        Set<Id> secondaryContacts = new Set<Id>();
        for (People_Tracing__c pt : peopleTraces) {
            // if both person 1 and person 2 already exist in already processed list, do nothing
            // else add the person to secondary contacts set
            if (!idsToIgnore.contains(pt.Person_1__c)) {
                // add person 1
                secondaryContacts.add(pt.Person_1__c);
                idsToIgnore.add(pt.Person_1__c);
            } else if (idsToIgnore.contains(pt.Person_1__c)) {
                // add person 2
                secondaryContacts.add(pt.Person_2__c);
                idsToIgnore.add(pt.Person_2__c);
            }
        }
        return secondaryContacts;
    }
}