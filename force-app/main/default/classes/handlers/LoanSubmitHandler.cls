/**
 * @description Handler class for Loan Application trigger events
 */
public with sharing class LoanSubmitHandler {
    
    public static void handle(List<Loan_Application__c> newRecords, Map<Id, Loan_Application__c> oldMap) {
        if (oldMap == null) {
            handleAfterInsert(newRecords);
        } else {
            handleAfterUpdate(newRecords, oldMap);
        }
    }
    
    private static void handleAfterInsert(List<Loan_Application__c> newRecords) {
        ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
        service.processNewLoanApplications(newRecords);
    }
    
    private static void handleAfterUpdate(List<Loan_Application__c> newRecords, Map<Id, Loan_Application__c> oldMap) {
        List<Loan_Application__c> statusChangedRecords = new List<Loan_Application__c>();
        
        for (Loan_Application__c loanApp : newRecords) {
            Loan_Application__c oldRecord = oldMap.get(loanApp.Id);
            
            if (loanApp.Status__c != oldRecord.Status__c) {
                statusChangedRecords.add(loanApp);
            }
        }
        
        if (!statusChangedRecords.isEmpty()) {
            ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
            service.processStatusChanges(statusChangedRecords, oldMap);
        }
    }
}