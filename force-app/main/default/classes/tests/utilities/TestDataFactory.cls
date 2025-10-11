/**
 * @description Test utility class for creating test data
 * @author Tony Wu
 * @date 2025-10-11
 */
@IsTest
public class TestDataFactory {
    
    /**
     * @description Create test Loan Application records
     * @param recordCount Number of records to create
     * @param doInsert Whether to insert records into database
     * @return List of Loan Application records
     */
    public static List<Loan_Application__c> createLoanApplications(Integer recordCount, Boolean doInsert) {
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        
        // Create borrowers for each loan application
        List<Party__c> borrowers = createParties(recordCount, true);
        
        for (Integer i = 0; i < recordCount; i++) {
            // Use valid picklist values for Purpose__c
            List<String> validPurposes = new List<String>{'Home Loan', 'Personal Loan', 'Business Loan', 'Unsecured Loan'};
            String purpose = validPurposes[Math.mod(i, validPurposes.size())];
            
            Loan_Application__c loanApp = new Loan_Application__c(
                Amount__c = 50000 + (i * 10000), // Varying amounts
                Purpose__c = purpose,
                Status__c = 'Draft', // Valid default status
                Primary_Borrower__c = borrowers[i].Id
            );
            loanApps.add(loanApp);
        }
        
        if (doInsert) {
            insert loanApps;
        }
        
        return loanApps;
    }
    
    /**
     * @description Create a single test Loan Application
     * @param amount Loan amount
     * @param purpose Loan purpose
     * @param status Loan status
     * @param doInsert Whether to insert into database
     * @return Loan Application record
     */
    public static Loan_Application__c createLoanApplication(Decimal amount, String purpose, String status, Boolean doInsert) {
        // Create a primary borrower first
        Party__c borrower = createParty('John', 'Doe', 'Person', true);
        
        Loan_Application__c loanApp = new Loan_Application__c(
            Amount__c = amount,
            Purpose__c = purpose,
            Status__c = status,
            Primary_Borrower__c = borrower.Id
        );
        
        if (doInsert) {
            insert loanApp;
        }
        
        return loanApp;
    }
    
    /**
     * @description Create test Party records
     * @param recordCount Number of records to create
     * @param doInsert Whether to insert records into database
     * @return List of Party records
     */
    public static List<Party__c> createParties(Integer recordCount, Boolean doInsert) {
        List<Party__c> parties = new List<Party__c>();
        String uniqueId = String.valueOf(System.currentTimeMillis()) + String.valueOf(Math.random()).substring(2, 6);
        
        for (Integer i = 0; i < recordCount; i++) {
            Party__c party = new Party__c(
                Email__c = 'testparty' + uniqueId + '_' + i + '@example.com',
                Phone__c = '555-' + uniqueId.substring(uniqueId.length()-6) + String.valueOf(i).leftPad(2, '0'),
                Party_Type__c = 'Person'
            );
            parties.add(party);
        }
        
        if (doInsert) {
            insert parties;
        }
        
        return parties;
    }
    
    /**
     * @description Create Loan Application with specific validation errors for testing
     * @return Loan Application with validation issues
     */
    public static Loan_Application__c createInvalidLoanApplication() {
        // Create a primary borrower first
        Party__c borrower = createParty('Jane', 'Smith', 'Person', true);
        
        return new Loan_Application__c(
            Amount__c = -1000, // Invalid negative amount
            Purpose__c = null,  // Missing required purpose
            Status__c = 'Draft', // Valid status
            Primary_Borrower__c = borrower.Id
        );
    }
    
    /**
     * @description Create Loan Application with maximum amount for boundary testing
     * @return Loan Application with maximum allowed amount
     */
    public static Loan_Application__c createMaxAmountLoanApplication() {
        // Create a primary borrower first
        Party__c borrower = createParty('Max', 'Amount', 'Person', true);
        
        return new Loan_Application__c(
            Amount__c = 1500000, // Over the 1M limit
            Purpose__c = 'Business Loan', // Valid picklist value
            Status__c = 'Draft', // Valid status
            Primary_Borrower__c = borrower.Id
        );
    }
    
    /**
     * @description Create a test Party record
     * @param firstName First name
     * @param lastName Last name 
     * @param partyType Party type (Borrower, Co-Borrower, etc.)
     * @param doInsert Whether to insert into database
     * @return Party record
     */
    public static Party__c createParty(String firstName, String lastName, String partyType, Boolean doInsert) {
        // Add timestamp to ensure uniqueness
        String timestamp = String.valueOf(System.now().getTime());
        String uniqueEmail = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '+' + timestamp + '@example.com';
        
        Party__c party = new Party__c(
            Name = firstName + ' ' + lastName + ' ' + timestamp.substring(timestamp.length()-4),
            Party_Type__c = 'Person', // Valid picklist value
            Email__c = uniqueEmail,
            Phone__c = '(555) 123-4567'
        );
        
        if (doInsert) {
            insert party;
        }
        
        return party;
    }
}