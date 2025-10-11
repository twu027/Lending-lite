/**
 * @description Simulates a third-party credit assessment service
 */
public class ExternalCreditBureauService {

    // Enqueue credit assessment processing
    public static void processCreditAssessments(String requestsJson) {
        System.enqueueJob(new CreditAssessmentJob(requestsJson));
    }

    public class CreditAssessmentJob implements Queueable {
        private String requestsJson;
        public CreditAssessmentJob(String requestsJson) {
            this.requestsJson = requestsJson;
        }
        public void execute(QueueableContext context) {
            List<CreditAssessmentRequest> creditRequests = (List<CreditAssessmentRequest>) JSON.deserialize(requestsJson, List<CreditAssessmentRequest>.class);
            for (CreditAssessmentRequest request : creditRequests) {
                processSingleCreditAssessment(request);
            }
        }
    }

    private static void processSingleCreditAssessment(CreditAssessmentRequest request) {
        CreditDecision decision = performCreditAnalysis(request);
        sendCreditDecisionCallback(request, decision);
    }

    private static CreditDecision performCreditAnalysis(CreditAssessmentRequest request) {
        CreditDecision decision = new CreditDecision();
        decision.referenceId = request.referenceId;
        decision.riskScore = calculateExternalRiskScore(request.loanAmount, request.loanPurpose);
        if (decision.riskScore <= 20) {
            decision.recommendation = 'APPROVE';
            decision.reasonCode = 'LOW_RISK_AUTO_APPROVED';
        } else if (decision.riskScore <= 50) {
            decision.recommendation = 'REFER';
            decision.reasonCode = 'MEDIUM_RISK_MANUAL_REVIEW';
        } else {
            decision.recommendation = 'DECLINE';
            decision.reasonCode = 'HIGH_RISK_DECLINED';
        }
        // Simulate processing time
        decision.processingTimeMs = 2000 + (Integer)(Math.random() * 3000);
        return decision;
    }

    private static Integer calculateExternalRiskScore(Decimal loanAmount, String loanPurpose) {
        Integer baseScore = 5;
        if (loanAmount != null) {
            if (loanAmount >= 800000) {
                baseScore += 60;
            } else if (loanAmount >= 300000) {
                baseScore += 35;
            } else if (loanAmount >= 50000) {
                baseScore += 20;
            } else if (loanAmount >= 25000) {
                baseScore += 10;
            }
        }
        if (String.isNotBlank(loanPurpose)) {
            String purpose = loanPurpose.toLowerCase();
            if (purpose.contains('home')) {
                // No adjustment
            } else if (purpose.contains('personal')) {
                baseScore += 8;
            } else if (purpose.contains('business')) {
                baseScore += 15;
            } else if (purpose.contains('unsecured')) {
                baseScore += 30;
            } else {
                baseScore += 5;
            }
        }
        // Add a single market/volatility factor for realism
        baseScore += (Integer)(Math.random() * 8) - 4;
        return Math.min(100, Math.max(0, baseScore));
    }

    private static void sendCreditDecisionCallback(CreditAssessmentRequest request, CreditDecision decision) {
        try {
            Map<String, Object> callbackPayload = new Map<String, Object>{
                'applicationId' => decision.referenceId,
                'riskScore' => decision.riskScore,
                'decision' => decision.recommendation
            };
            String jsonPayload = JSON.serialize(callbackPayload);
            RestResponse mockResponse = new RestResponse();
            RestRequest mockRequest = new RestRequest();
            mockRequest.requestBody = Blob.valueOf(jsonPayload);
            RestContext.request = mockRequest;
            RestContext.response = mockResponse;
            CreditScoreRest.CreditResponse response = CreditScoreRest.score();
        } catch (Exception e) {
            System.debug('Callback failed: ' + e.getMessage());
        }
    }

    private static String getDefaultCallbackUrl() {
        return URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/credit/score';
    }

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

    public class CreditDecision {
        public String referenceId;
        public Integer riskScore;
        public String recommendation;
        public String reasonCode;
        public Integer processingTimeMs;
    }
}