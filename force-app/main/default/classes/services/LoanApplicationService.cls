/**
 * @description Service class for Loan Application business logic
 */
public with sharing class LoanApplicationService implements ILoanApplicationService {
    
    public void processNewLoanApplications(List<Loan_Application__c> loanApplications) {
        validateLoanApplications(loanApplications);
    }
    
    public void processStatusChanges(List<Loan_Application__c> statusChangedApplications, Map<Id, Loan_Application__c> oldApplicationMap) {
        List<Loan_Application__c> submittedApplications = new List<Loan_Application__c>();
        
        for (Loan_Application__c app : statusChangedApplications) {
            String newStatus = app.Status__c;
            String oldStatus = oldApplicationMap.get(app.Id).Status__c;
            
            if (newStatus == 'Submitted' && oldStatus != 'Submitted') {
                submittedApplications.add(app);
            }
        }
        
        if (!submittedApplications.isEmpty()) {
            processSubmittedApplications(submittedApplications);
        }
    }
    
    private static void validateLoanApplications(List<Loan_Application__c> loanApplications) {
        for (Loan_Application__c app : loanApplications) {
            if (app.Amount__c == null || app.Amount__c <= 0) {
                app.addError('Loan amount must be greater than zero');
            }
            
            if (app.Amount__c != null && app.Amount__c > 1000000) {
                app.addError('Loan amount cannot exceed $1,000,000');
            }
            
            if (String.isBlank(app.Purpose__c)) {
                app.addError('Loan purpose must be specified');
            }
        }
    }
    
    private static void processSubmittedApplications(List<Loan_Application__c> submittedApplications) {
        publishCreditRiskCalculationEvents(submittedApplications);
    }
    
    private static void publishCreditRiskCalculationEvents(List<Loan_Application__c> loanApplications) {
        List<Credit_Risk_Calculation_Request__e> events = new List<Credit_Risk_Calculation_Request__e>();
        
        for (Loan_Application__c app : loanApplications) {
            Credit_Risk_Calculation_Request__e event = new Credit_Risk_Calculation_Request__e(
                Loan_Application_Id__c = app.Id,
                Loan_Amount__c = app.Amount__c,
                Loan_Purpose__c = app.Purpose__c,
                Request_Type__c = 'Initial',
                Callback_Url__c = URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/credit/score'
            );
            events.add(event);
        }
        
        if (!events.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(events);
            
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    System.debug('Event publish failed for index ' + i + ': ' + results[i].getErrors());
                }
            }
        }
    }
}