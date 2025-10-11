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
        System.debug('LoanApplicationService.processNewLoanApplications: Processing ' + loanApplications.size() + ' applications');
        
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
        System.debug('LoanApplicationService.processStatusChanges: Processing ' + statusChangedApplications.size() + ' status changes');
        
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
            
            // Create audit trail for submitted applications
            createAuditTrail(submittedApplications, 'Status Changed to Submitted');
        }
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
     * @description Calculate initial risk rating based on loan amount
     * @param loanAmount The loan amount
     * @return String risk rating
     */
    private static String calculateInitialRiskRating(Decimal loanAmount) {
        if (loanAmount <= 50000) {
            return 'Low';
        } else if (loanAmount <= 200000) {
            return 'Medium';
        } else {
            return 'High';
        }
    }
    

    
    /**
     * @description Send notifications for new applications
     * @param loanApplications List of new applications
     */
    private static void sendNewApplicationNotifications(List<Loan_Application__c> loanApplications) {
        // Placeholder for email notification logic
        System.debug('Sending new application notifications for ' + loanApplications.size() + ' applications');
        
        // TODO: Implement email notification logic
        // Example: Send email to loan processing team
        // Example: Send confirmation email to borrower
    }
    

    
    /**
     * @description Update related Party records based on loan status
     * @param loanApplications List of loan applications
     * @param status The new status
     */
    private static void updateRelatedPartyRecords(List<Loan_Application__c> loanApplications, String status) {
        System.debug('Updating related Party records for ' + loanApplications.size() + ' applications with status: ' + status);
        
        // TODO: Implement Party record update logic
        // Example: Update borrower credit status
        // Example: Update borrower loan history
    }
    
    /**
     * @description Create audit trail for loan applications
     * @param loanApplications List of loan applications
     * @param action The action being audited
     */
    private static void createAuditTrail(List<Loan_Application__c> loanApplications, String action) {
        System.debug('Creating audit trail for ' + loanApplications.size() + ' applications - Action: ' + action);
        
        // TODO: Implement audit trail creation
        // Example: Create audit records
        // Example: Log to external system
    }
    
    /**
     * @description Process submitted loan applications - triggers credit risk calculation
     * @param submittedApplications List of submitted loan applications
     */
    private static void processSubmittedApplications(List<Loan_Application__c> submittedApplications) {
        System.debug('Processing ' + submittedApplications.size() + ' submitted applications');
        
        // Publish platform events to trigger credit risk calculation
        publishCreditRiskCalculationEvents(submittedApplications);
        
        // Create audit trail
        createAuditTrail(submittedApplications, 'Submitted for Credit Review');
        
        // Status remains 'Submitted' during processing
        // Will be updated to final decision (Approved/Referred/Declined) by external service callback
        // No need to update status here - external service will handle final status update
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
                    System.debug('Failed to publish event for application: ' + loanApplications[i].Id + 
                               ' Error: ' + results[i].getErrors()[0].getMessage());
                }
            }
            
            System.debug('Published ' + events.size() + ' credit risk calculation events');
        }
    }
}