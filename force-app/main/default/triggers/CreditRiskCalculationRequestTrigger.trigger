/**
 * @description Platform Event Trigger for Credit Risk Calculation Requests
 * Routes loan data to external credit bureau service for assessment
 * @author Tony Wu
 * @date 2025-10-11
 */
trigger CreditRiskCalculationRequestTrigger on Credit_Risk_Calculation_Request__e (after insert) {
    // Build credit assessment requests for external bureau
    List<ExternalCreditBureauService.CreditAssessmentRequest> creditRequests = 
        new List<ExternalCreditBureauService.CreditAssessmentRequest>();
    
    for (Credit_Risk_Calculation_Request__e event : Trigger.new) {
        if (String.isNotBlank(event.Loan_Application_Id__c) && 
            event.Loan_Amount__c != null && 
            String.isNotBlank(event.Loan_Purpose__c)) {
            
            ExternalCreditBureauService.CreditAssessmentRequest request = 
                new ExternalCreditBureauService.CreditAssessmentRequest(
                    event.Loan_Application_Id__c,
                    event.Loan_Amount__c,
                    event.Loan_Purpose__c,
                    event.Callback_Url__c,
                    event.Request_Type__c
                );
            
            creditRequests.add(request);
        }
    }
    
    if (!creditRequests.isEmpty()) {
        // Serialize requests to JSON for @future method
        String requestsJson = JSON.serialize(creditRequests);
        
        // Send to external credit bureau service asynchronously
        ExternalCreditBureauService.processCreditAssessments(requestsJson);
    }
}