/**
 * @description Handler class for Loan Application trigger events
 * @author Tony Wu
 * @date 2025-10-11
 */
public with sharing class LoanSubmitHandler {
    
    /**
     * @description Main handler method for Loan Application trigger events
     * @param newRecords List of new Loan Application records
     * @param oldMap Map of old Loan Application records (null for insert)
     */
    public static void handle(List<Loan_Application__c> newRecords, Map<Id, Loan_Application__c> oldMap) {
        
        // Handle after insert logic
        if (oldMap == null) {
            handleAfterInsert(newRecords);
        } 
        // Handle after update logic
        else {
            handleAfterUpdate(newRecords, oldMap);
        }
    }
    
    /**
     * @description Handle logic for after insert events
     * @param newRecords List of newly inserted Loan Application records
     */
    private static void handleAfterInsert(List<Loan_Application__c> newRecords) {
        System.debug('LoanSubmitHandler.handleAfterInsert: Processing ' + newRecords.size() + ' new loan applications');
        
        // Delegate to service layer for business logic using factory pattern
        ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
        service.processNewLoanApplications(newRecords);
    }
    
    /**
     * @description Handle logic for after update events
     * @param newRecords List of updated Loan Application records
     * @param oldMap Map of old Loan Application record values
     */
    private static void handleAfterUpdate(List<Loan_Application__c> newRecords, Map<Id, Loan_Application__c> oldMap) {
        System.debug('LoanSubmitHandler.handleAfterUpdate: Processing ' + newRecords.size() + ' updated loan applications');
        
        List<Loan_Application__c> statusChangedRecords = new List<Loan_Application__c>();
        
        // Check for status changes
        for (Loan_Application__c loanApp : newRecords) {
            Loan_Application__c oldRecord = oldMap.get(loanApp.Id);
            
            if (loanApp.Status__c != oldRecord.Status__c) {
                statusChangedRecords.add(loanApp);
                System.debug('Loan Application status changed: ' + loanApp.Id + 
                           ' - Old Status: ' + oldRecord.Status__c + 
                           ' - New Status: ' + loanApp.Status__c);
            }
        }
        
        // Process status changes using service layer
        if (!statusChangedRecords.isEmpty()) {
            ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
            service.processStatusChanges(statusChangedRecords, oldMap);
        }
    }
    

}