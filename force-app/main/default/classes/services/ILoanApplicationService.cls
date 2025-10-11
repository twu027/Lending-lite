/**
 * @description Interface for Loan Application Service operations
 * @author Tony Wu
 * @date 2025-10-11
 */
public interface ILoanApplicationService {
    
    /**
     * @description Process loan applications after insert
     * @param loanApplications List of loan application records
     */
    void processNewLoanApplications(List<Loan_Application__c> loanApplications);
    
    /**
     * @description Process loan applications with status changes
     * @param statusChangedApplications List of applications with status changes
     * @param oldApplicationMap Map of old application values
     */
    void processStatusChanges(List<Loan_Application__c> statusChangedApplications, Map<Id, Loan_Application__c> oldApplicationMap);
}