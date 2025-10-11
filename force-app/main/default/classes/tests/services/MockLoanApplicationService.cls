/**
 * @description Mock implementation of ILoanApplicationService for testing
 * @author Tony Wu
 * @date 2025-10-11
 */
@IsTest
public class MockLoanApplicationService implements ILoanApplicationService {
    
    public List<Loan_Application__c> processedNewApplications = new List<Loan_Application__c>();
    public List<Loan_Application__c> processedStatusChanges = new List<Loan_Application__c>();
    public Map<Id, Loan_Application__c> capturedOldMap = new Map<Id, Loan_Application__c>();
    
    public Integer newApplicationCallCount = 0;
    public Integer statusChangeCallCount = 0;
    
    /**
     * @description Mock implementation of processNewLoanApplications
     * @param loanApplications List of loan application records
     */
    public void processNewLoanApplications(List<Loan_Application__c> loanApplications) {
        newApplicationCallCount++;
        processedNewApplications.addAll(loanApplications);
    }
    
    /**
     * @description Mock implementation of processStatusChanges
     * @param statusChangedApplications List of applications with status changes
     * @param oldApplicationMap Map of old application values
     */
    public void processStatusChanges(List<Loan_Application__c> statusChangedApplications, Map<Id, Loan_Application__c> oldApplicationMap) {
        statusChangeCallCount++;
        processedStatusChanges.addAll(statusChangedApplications);
        if (oldApplicationMap != null) {
            capturedOldMap.putAll(oldApplicationMap);
        }
    }
    
    /**
     * @description Reset mock data for clean testing
     */
    public void reset() {
        processedNewApplications.clear();
        processedStatusChanges.clear();
        capturedOldMap.clear();
        newApplicationCallCount = 0;
        statusChangeCallCount = 0;
    }
}