/**
 * @description REST Web Service for external credit score processing
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

    @HttpPost
    global static CreditResponse score() {
        try {
            RestRequest req = RestContext.request;
            CreditRequest cr = (CreditRequest) JSON.deserialize(req.requestBody.toString(), CreditRequest.class);
            
            if (cr == null || String.isBlank(cr.applicationId)) {
                throw new System.CalloutException('applicationId is required');
            }
            
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
    
    private static CreditResponse processCallback(CreditRequest cr) {
        Loan_Application__c app = [
            SELECT Id, Status__c, Amount__c, Purpose__c, Risk_Rating__c
            FROM Loan_Application__c 
            WHERE Id = :cr.applicationId 
            LIMIT 1
        ];
        
        Integer risk = cr.riskScore;
        String newStatus = convertExternalDecision(cr.decision);
        
        app.Status__c = newStatus;
        app.Risk_Rating__c = risk;
        
        update app;
        
        CreditResponse resp = new CreditResponse();
        resp.status = newStatus;
        resp.riskScore = risk;
        resp.id = app.Id;
        
        return resp;
    }
    
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
                throw new System.CalloutException('Unknown external decision: ' + externalDecision);
            }
        }
    }
}