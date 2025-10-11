/**
 * @description REST Web Service for external credit score processing
 * @author Tony Wu
 * @date 2025-10-11
 */
@RestResource(urlMapping='/credit/score')
global with sharing class CreditScoreRest {
    
    global class CreditRequest { 
        public String applicationId; 
        public Integer riskScore;
        public String decision;
    }

    global class CreditResponse { 
        public String status; 
        public Integer riskScore; 
        public Id id; 
    }

    /**
     * @description HTTP POST endpoint for credit scoring
     * @return CreditResponse with updated status and risk score
     */
    @HttpPost
    global static CreditResponse score() {
        try {
            RestRequest req = RestContext.request;
            CreditRequest cr = (CreditRequest) JSON.deserialize(req.requestBody.toString(), CreditRequest.class);
            
            // Validate request
            if (cr == null || String.isBlank(cr.applicationId)) {
                throw new System.CalloutException('applicationId is required');
            }
            
            // Validate callback data
            if (cr.riskScore == null || String.isBlank(cr.decision)) {
                throw new System.CalloutException('riskScore and decision are required');
            }
            
            return processCallback(cr);
            
        } catch (QueryException e) {
            throw new System.CalloutException('Loan application not found: ' + e.getMessage());
        } catch (DmlException e) {
            throw new System.CalloutException('Error updating loan application: ' + e.getMessage());
        } catch (Exception e) {
            throw new System.CalloutException('Unexpected error: ' + e.getMessage());
        }
    }
    
    /**
     * @description Process callback from external credit bureau
     * @param cr Credit request with risk score and decision
     * @return CreditResponse
     */
    private static CreditResponse processCallback(CreditRequest cr) {
        
        // Retrieve loan application
        Loan_Application__c app = [
            SELECT Id, Status__c, Amount__c, Purpose__c, Risk_Rating__c
            FROM Loan_Application__c 
            WHERE Id = :cr.applicationId 
            LIMIT 1
        ];
        
        // Use provided risk score and convert external decision to Salesforce status
        Integer risk = cr.riskScore;
        String newStatus = convertExternalDecision(cr.decision);
        
        // Update both status and risk rating
        app.Status__c = newStatus;
        app.Risk_Rating__c = risk;
        
        update app;
        
        // Prepare response
        CreditResponse resp = new CreditResponse();
        resp.status = newStatus;
        resp.riskScore = risk;
        resp.id = app.Id;
        
        System.debug('External callback: Updated application ' + app.Id + ' with status: ' + newStatus + ', risk: ' + risk);
        
        return resp;
    }
    
    /**
     * @description Convert external bureau decision to Salesforce status
     * @param externalDecision External decision (APPROVE/REFER/DECLINE)
     * @return String Salesforce status
     */
    private static String convertExternalDecision(String externalDecision) {
        switch on externalDecision {
            when 'APPROVE' {
                return 'Approved';
            }
            when 'REFER' {
                return 'Referred';
            }
            when 'DECLINE' {
                return 'Declined';
            }
            when else {
                System.debug(LoggingLevel.ERROR, 'Unknown external decision: ' + externalDecision);
                throw new System.CalloutException('Unknown external decision: ' + externalDecision);
            }
        }
    }
}