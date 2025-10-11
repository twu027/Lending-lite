/**
 * @description External Credit Bureau Service - Simulates a third-party credit assessment service
 * This class represents an external credit bureau that receives loan data via platform events
 * and makes credit decisions without knowledge of Salesforce internal IDs or structure
 * @author Tony Wu  
 * @date 2025-10-11
 */
public class ExternalCreditBureauService {
    
    /**
     * @description Process credit risk assessment requests from platform events
     * @param requestsJson JSON serialized list of credit assessment requests
     */
    public static void processCreditAssessments(String requestsJson) {
        // Use queueable job instead of @future for better demo experience
        CreditAssessmentJob job = new CreditAssessmentJob(requestsJson);
        System.enqueueJob(job);
    }
    
    /**
     * @description Queueable job to process credit assessments asynchronously
     */
    public class CreditAssessmentJob implements Queueable {
        private String requestsJson;
        
        public CreditAssessmentJob(String requestsJson) {
            this.requestsJson = requestsJson;
        }
        
        public void execute(QueueableContext context) {
            List<CreditAssessmentRequest> creditRequests = 
                (List<CreditAssessmentRequest>) JSON.deserialize(requestsJson, List<CreditAssessmentRequest>.class);
            
            for (CreditAssessmentRequest request : creditRequests) {
                processSingleCreditAssessment(request);
            }
        }
    }
    
    /**
     * @description Process individual credit assessment
     * @param request Credit assessment request containing loan data
     */
    private static void processSingleCreditAssessment(CreditAssessmentRequest request) {
        // Simulate external credit bureau decision process
        CreditDecision decision = performCreditAnalysis(request);
        
        // Send decision back via callback
        sendCreditDecisionCallback(request, decision);
    }
    
    /**
     * @description Perform credit analysis based on loan data
     * External credit bureau logic - no knowledge of Salesforce objects
     * @param request Credit assessment request
     * @return CreditDecision with risk score and recommendation
     */
    private static CreditDecision performCreditAnalysis(CreditAssessmentRequest request) {
        CreditDecision decision = new CreditDecision();
        decision.referenceId = request.referenceId;
        
        // External credit bureau risk calculation
        Integer riskScore = calculateExternalRiskScore(request.loanAmount, request.loanPurpose);
        decision.riskScore = riskScore;
        
        // External credit bureau decision logic
        if (riskScore <= 25) {
            decision.recommendation = 'APPROVE';
            decision.reasonCode = 'LOW_RISK';
        } else if (riskScore <= 55) {
            decision.recommendation = 'REFER';
            decision.reasonCode = 'MEDIUM_RISK_MANUAL_REVIEW';
        } else {
            decision.recommendation = 'DECLINE';
            decision.reasonCode = 'HIGH_RISK';
        }
        
        // Add some processing time simulation
        decision.processingTimeMs = 2000 + (Integer)(Math.random() * 3000); // 2-5 seconds
        
        return decision;
    }
    
    /**
     * @description Calculate risk score using external credit bureau algorithms
     * @param loanAmount Requested loan amount
     * @param loanPurpose Purpose of the loan
     * @return Integer risk score (0-100)
     */
    private static Integer calculateExternalRiskScore(Decimal loanAmount, String loanPurpose) {
        Integer baseScore = 15; // Lower base score for external bureau
        
        // Amount-based risk assessment
        if (loanAmount != null) {
            if (loanAmount >= 1000000) {
                baseScore += 45; 
            } else if (loanAmount >= 500000) {
                baseScore += 35; 
            } else if (loanAmount >= 100000) {
                baseScore += 20; 
            } else if (loanAmount >= 25000) {
                baseScore += 10; 
            } else {
                baseScore += 5; 
            }
        }
        
        // Purpose-based risk assessment (external bureau perspective)
        if (String.isNotBlank(loanPurpose)) {
            String purpose = loanPurpose.toLowerCase();
            if (purpose.contains('home')) {
                baseScore += 5;  
            } else if (purpose.contains('business')) {
                baseScore += 15; // Business loans - medium risk
            } else if (purpose.contains('personal')) {
                baseScore += 12; // Personal loans - medium risk
            } else if (purpose.contains('unsecured')) {
                baseScore += 25; // Unsecured - highest risk
            } else {
                baseScore += 10; // Default for unknown purposes
            }
        }
        
        // Add market conditions factor (simulated)
        Integer marketFactor = (Integer)(Math.random() * 8) - 4; // -4 to +4
        baseScore += marketFactor;
        
        // External bureau also considers credit market volatility
        Integer volatilityFactor = (Integer)(Math.random() * 6) - 3; // -3 to +3
        baseScore += volatilityFactor;
        
        return Math.min(100, Math.max(0, baseScore));
    }
    
    /**
     * @description Send credit decision back via HTTP callback
     * @param request Original credit assessment request
     * @param decision Credit decision result
     */
    private static void sendCreditDecisionCallback(CreditAssessmentRequest request, CreditDecision decision) {
        try {
            // Prepare callback payload - only essential data for demo
            Map<String, Object> callbackPayload = new Map<String, Object>{
                'applicationId' => decision.referenceId,
                'riskScore' => decision.riskScore,
                'decision' => decision.recommendation
            };
            
            String jsonPayload = JSON.serialize(callbackPayload);
            
            // Simulate external callback by directly calling the REST method
            // In real implementation, this would be an HTTP POST from external system
            // because within Salesforce we cannot make callouts to ourselves
            // So we simulate by setting RestContext and invoking the method directly
            RestResponse mockResponse = new RestResponse();
            RestRequest mockRequest = new RestRequest();
            mockRequest.requestBody = Blob.valueOf(jsonPayload);
            
            // Set REST context for the simulated call
            RestContext.request = mockRequest;
            RestContext.response = mockResponse;
            
            // Call the REST endpoint method directly (simulating external callback)
            CreditScoreRest.CreditResponse response = CreditScoreRest.score();
            
        } catch (Exception e) {
            // In real scenario, would queue for retry
        }
    }

    // those are the setup for real HTTP callouts using Salesforce technology
    // depending on the real external system the callback will be implemented differently    
    /**
     * @description Get default callback URL
     * @return String callback URL
     */
    private static String getDefaultCallbackUrl() {
        return URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/credit/score';
    }
    
    /**
     * @description Data structure for credit assessment requests
     */
    public class CreditAssessmentRequest {
        public String referenceId;
        public Decimal loanAmount;
        public String loanPurpose;
        public String callbackUrl;
        public String requestType;
        
        public CreditAssessmentRequest(String refId, Decimal amount, String purpose, String callback, String reqType) {
            this.referenceId = refId;
            this.loanAmount = amount;
            this.loanPurpose = purpose;
            this.callbackUrl = callback;
            this.requestType = reqType;
        }
    }
    
    /**
     * @description Data structure for credit decisions
     */
    public class CreditDecision {
        public String referenceId;
        public Integer riskScore;
        public String recommendation;  // APPROVE, REFER, DECLINE
        public String reasonCode;
        public Integer processingTimeMs;
    }
}