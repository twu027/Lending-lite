/**
 * @description Service class for Loan Application business logic
 * @author Tony Wu
 * @date 2025-10-11
 */
public with sharing class LoanApplicationService implements ILoanApplicationService {
    
    /**
     * @description Process loan applications after insert
     * @param loanApplications List of loan application records
     */
    public void processNewLoanApplications(List<Loan_Application__c> loanApplications) {
        // Validate required fields
        validateLoanApplications(loanApplications);
        
        // Send notifications for new applications
        sendNewApplicationNotifications(loanApplications);
        
        // Create audit trail
        createAuditTrail(loanApplications, 'Created');
    }
    
    /**
     * @description Process loan applications with status changes
     * @param statusChangedApplications List of applications with status changes
     * @param oldApplicationMap Map of old application values
     */
    public void processStatusChanges(List<Loan_Application__c> statusChangedApplications, Map<Id, Loan_Application__c> oldApplicationMap) {
        List<Loan_Application__c> submittedApplications = new List<Loan_Application__c>();
        
        // Filter for submitted applications only
        for (Loan_Application__c app : statusChangedApplications) {
            String newStatus = app.Status__c;
            String oldStatus = oldApplicationMap.get(app.Id).Status__c;
            
            if (newStatus == 'Submitted' && oldStatus != 'Submitted') {
                submittedApplications.add(app);
            }
        }
        
        // Process submitted applications
        if (!submittedApplications.isEmpty()) {
            processSubmittedApplications(submittedApplications);
        }
        // only processed the submitted status, other status changes can be handled here if needed
    }
    
    /**
     * @description Validate loan application required fields and business rules
     * @param loanApplications List of loan applications to validate
     */
    private static void validateLoanApplications(List<Loan_Application__c> loanApplications) {
        for (Loan_Application__c app : loanApplications) {
            // Validate loan amount
            if (app.Amount__c == null || app.Amount__c <= 0) {
                app.addError('Loan amount must be greater than zero');
            }
            
            // Validate maximum loan amount (example: $1M limit)
            if (app.Amount__c != null && app.Amount__c > 1000000) {
                app.addError('Loan amount cannot exceed $1,000,000');
            }
            
            // Validate purpose is specified
            if (String.isBlank(app.Purpose__c)) {
                app.addError('Loan purpose must be specified');
            }
        }
    }
    

    
    /**
     * @description Process submitted loan applications - triggers credit risk calculation
     * @param submittedApplications List of submitted loan applications
     */
    private static void processSubmittedApplications(List<Loan_Application__c> submittedApplications) {
        // Publish platform events to trigger credit risk calculation
        publishCreditRiskCalculationEvents(submittedApplications);
        // future processings can be added here
    }
    
    /**
     * @description Publish platform events for credit risk calculation
     * @param loanApplications List of loan applications requiring credit assessment
     */
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
            
            // Log any failures
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    // Could implement proper error handling/logging here
                    // For now, silently continue processing other events
                }
            }
        }
    }
}