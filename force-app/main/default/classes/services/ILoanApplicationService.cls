/**
 * @description Interface for Loan Application Service operations
 */
public interface ILoanApplicationService {
    void processNewLoanApplications(List<Loan_Application__c> loanApplications);
    void processStatusChanges(List<Loan_Application__c> statusChangedApplications, Map<Id, Loan_Application__c> oldApplicationMap);
}