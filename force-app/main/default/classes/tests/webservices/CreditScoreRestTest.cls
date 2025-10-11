/**
 * @description Test class for CreditScoreRest web service
 * Tests callback-only mode with proper exception handling and meaningful assertions
 * @author Tony Wu
 * @date 2025-10-11
 */
@IsTest
private class CreditScoreRestTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test loan applications for various scenarios using TestDataFactory
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        
        // Low risk application (small amount + secured loan)
        loanApps.add(TestDataFactory.createLoanApplication(10000, 'Home Loan', 'Draft', false));
        
        // Medium risk application
        loanApps.add(TestDataFactory.createLoanApplication(50000, 'Personal Loan', 'Submitted', false));
        
        // High risk application (large amount + unsecured)
        loanApps.add(TestDataFactory.createLoanApplication(600000, 'Unsecured Loan', 'Submitted', false));
        
        // Application for calculated risk test
        loanApps.add(TestDataFactory.createLoanApplication(75000, 'Personal Loan', 'Submitted', false));
        
        insert loanApps;
    }
    
    @IsTest
    static void testScore_LowRiskApproval() {
        Test.startTest();
        
        // Get low risk application
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 10000 LIMIT 1];
        
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = 25;  // Low risk score
        creditReq.decision = 'APPROVE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Call the web service
        CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals('Approved', result.status, 'External bureau approved application');
        System.assertEquals(app.Id, result.id, 'Response should contain correct application ID');
        System.assertEquals(25, result.riskScore, 'Risk score should match external bureau decision');
        
        // Verify application was updated
        Loan_Application__c updatedApp = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        System.assertEquals('Approved', updatedApp.Status__c, 'Application status should be updated to Approved');
    }
    
    @IsTest
    static void testScore_MediumRiskReferred() {
        Test.startTest();
        
        // Get medium risk application
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 50000 LIMIT 1];
        
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = 45;  // Medium risk score
        creditReq.decision = 'REFER';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Call the web service
        CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals('Referred', result.status, 'External bureau referred application');
        System.assertEquals(app.Id, result.id, 'Response should contain correct application ID');
        System.assertEquals(45, result.riskScore, 'Risk score should match external bureau decision');
        
        // Verify application was updated
        Loan_Application__c updatedApp = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        System.assertEquals('Referred', updatedApp.Status__c, 'Application status should be updated to Referred');
    }
    
    @IsTest
    static void testScore_HighRiskDeclined() {
        Test.startTest();
        
        // Get high risk application
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 600000 LIMIT 1];
        
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = 75;  // High risk score
        creditReq.decision = 'DECLINE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Call the web service
        CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals('Declined', result.status, 'External bureau declined application');
        System.assertEquals(app.Id, result.id, 'Response should contain correct application ID');
        System.assertEquals(75, result.riskScore, 'Risk score should match external bureau decision');
        
        // Verify application was updated
        Loan_Application__c updatedApp = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        System.assertEquals('Declined', updatedApp.Status__c, 'Application status should be updated to Declined');
    }
    
    @IsTest
    static void testScore_CalculatedRisk() {
        Test.startTest();
        
        // Get application for callback test
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 75000 LIMIT 1];
        
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = 55;  // Medium-high risk score
        creditReq.decision = 'REFER';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Call the web service
        CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals('Referred', result.status, 'External bureau referred application');
        System.assertEquals(app.Id, result.id, 'Response should contain correct application ID');
        System.assertEquals(55, result.riskScore, 'Risk score should match external bureau decision');
    }
    
    @IsTest
    static void testScore_MissingApplicationId() {
        Test.startTest();
        
        // Setup REST context with missing applicationId
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = null; // Missing required field
        creditReq.riskScore = 30;
        creditReq.decision = 'APPROVE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Call the web service - should throw exception
        System.CalloutException thrownException;
        try {
            CreditScoreRest.CreditResponse result = CreditScoreRest.score();
            System.assert(false, 'Expected System.CalloutException to be thrown for missing applicationId');
        } catch (System.CalloutException e) {
            thrownException = e;
        }
        
        // Verify exception was thrown and has correct message
        System.assertNotEquals(null, thrownException, 'System.CalloutException should have been thrown');
        System.assertEquals(true, thrownException.getMessage().contains('applicationId is required'), 
                            'Exception message should contain "applicationId is required", but got: ' + thrownException.getMessage());
        
        Test.stopTest();
    }
    
    @IsTest
    static void testScore_MissingCallbackData() {
        Test.startTest();
        
        // Get application
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 10000 LIMIT 1];
        
        // Setup REST context with missing riskScore
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = null; // Missing required field
        creditReq.decision = 'APPROVE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Call the web service - should throw exception
        System.CalloutException thrownException;
        try {
            CreditScoreRest.CreditResponse result = CreditScoreRest.score();
            System.assert(false, 'Expected System.CalloutException to be thrown for missing callback data');
        } catch (System.CalloutException e) {
            thrownException = e;
        }
        
        // Verify exception was thrown and has correct message
        System.assertNotEquals(null, thrownException, 'System.CalloutException should have been thrown');
        System.assertEquals(true, thrownException.getMessage().contains('riskScore and decision are required'), 
                            'Exception message should contain "riskScore and decision are required", but got: ' + thrownException.getMessage());
        
        Test.stopTest();
    }
    
    @IsTest
    static void testScore_InvalidApplicationId() {
        Test.startTest();
        
        // Setup REST context with invalid applicationId
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = '001000000000000'; // Invalid ID
        creditReq.riskScore = 30;
        creditReq.decision = 'APPROVE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Call the web service - should throw exception
        System.CalloutException thrownException;
        try {
            CreditScoreRest.CreditResponse result = CreditScoreRest.score();
            System.assert(false, 'Expected System.CalloutException to be thrown for invalid applicationId');
        } catch (System.CalloutException e) {
            thrownException = e;
        }
        
        // Verify exception was thrown and has correct message
        System.assertNotEquals(null, thrownException, 'System.CalloutException should have been thrown');
        System.assertEquals(true, thrownException.getMessage().contains('Loan application not found'), 
                            'Exception message should contain "Loan application not found", but got: ' + thrownException.getMessage());
        
        Test.stopTest();
    }
    
    @IsTest
    static void testScore_InvalidJsonRequest() {
        Test.startTest();
        
        // Setup REST context with invalid JSON
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        request.requestBody = Blob.valueOf('{ invalid json }');
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Call the web service - should handle gracefully
        System.CalloutException thrownException;
        try {
            CreditScoreRest.CreditResponse result = CreditScoreRest.score();
            System.assert(false, 'Expected System.CalloutException to be thrown for invalid JSON');
        } catch (System.CalloutException e) {
            thrownException = e;
        }
        
        // Verify exception was thrown and has meaningful message
        System.assertNotEquals(null, thrownException, 'System.CalloutException should have been thrown for invalid JSON');
        System.assertNotEquals(null, thrownException.getMessage(), 'Exception should have a meaningful error message');
        System.assertNotEquals('', thrownException.getMessage(), 'Exception message should not be empty');
        
        Test.stopTest();
    }
}