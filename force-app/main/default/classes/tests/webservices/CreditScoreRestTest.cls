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
        // Arrange
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 10000 LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = 25;
        creditReq.decision = 'APPROVE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Act
        Test.startTest();
        CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals('Approved', result.status, 'External bureau approved application');
        System.assertEquals(app.Id, result.id, 'Response should contain correct application ID');
        System.assertEquals(25, result.riskScore, 'Risk score should match external bureau decision');
        
        Loan_Application__c updatedApp = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        System.assertEquals('Approved', updatedApp.Status__c, 'Application status should be updated to Approved');
    }
    
    @IsTest
    static void testScore_MediumRiskReferred() {
        // Arrange
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 50000 LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = 45;
        creditReq.decision = 'REFER';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Act
        Test.startTest();
        CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals('Referred', result.status, 'External bureau referred application');
        System.assertEquals(app.Id, result.id, 'Response should contain correct application ID');
        System.assertEquals(45, result.riskScore, 'Risk score should match external bureau decision');
        
        Loan_Application__c updatedApp = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        System.assertEquals('Referred', updatedApp.Status__c, 'Application status should be updated to Referred');
    }
    
    @IsTest
    static void testScore_HighRiskDeclined() {
        // Arrange
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 600000 LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = 75;
        creditReq.decision = 'DECLINE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Act
        Test.startTest();
        CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals('Declined', result.status, 'External bureau declined application');
        System.assertEquals(app.Id, result.id, 'Response should contain correct application ID');
        System.assertEquals(75, result.riskScore, 'Risk score should match external bureau decision');
        
        Loan_Application__c updatedApp = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        System.assertEquals('Declined', updatedApp.Status__c, 'Application status should be updated to Declined');
    }
    
    @IsTest
    static void testScore_CalculatedRisk() {
        // Arrange
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 75000 LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = 55;
        creditReq.decision = 'REFER';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Act
        Test.startTest();
        CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals('Referred', result.status, 'External bureau referred application');
        System.assertEquals(app.Id, result.id, 'Response should contain correct application ID');
        System.assertEquals(55, result.riskScore, 'Risk score should match external bureau decision');
    }
    
    @IsTest
    static void testScore_MissingApplicationId() {
        // Arrange
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = null;
        creditReq.riskScore = 30;
        creditReq.decision = 'APPROVE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Act
        Test.startTest();
        System.CalloutException thrownException;
        try {
            CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        } catch (System.CalloutException e) {
            thrownException = e;
        }
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, thrownException, 'System.CalloutException should have been thrown');
        System.assertEquals(true, thrownException.getMessage().contains('applicationId is required'), 
                            'Exception message should contain "applicationId is required", but got: ' + thrownException.getMessage());
    }
    
    @IsTest
    static void testScore_MissingCallbackData() {
        // Arrange
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Amount__c = 10000 LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = app.Id;
        creditReq.riskScore = null;
        creditReq.decision = 'APPROVE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Act
        Test.startTest();
        System.CalloutException thrownException;
        try {
            CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        } catch (System.CalloutException e) {
            thrownException = e;
        }
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, thrownException, 'System.CalloutException should have been thrown');
        System.assertEquals(true, thrownException.getMessage().contains('riskScore and decision are required'), 
                            'Exception message should contain "riskScore and decision are required", but got: ' + thrownException.getMessage());
    }
    
    @IsTest
    static void testScore_InvalidApplicationId() {
        // Arrange
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        CreditScoreRest.CreditRequest creditReq = new CreditScoreRest.CreditRequest();
        creditReq.applicationId = '001000000000000';
        creditReq.riskScore = 30;
        creditReq.decision = 'APPROVE';
        
        request.requestBody = Blob.valueOf(JSON.serialize(creditReq));
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Act
        Test.startTest();
        System.CalloutException thrownException;
        try {
            CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        } catch (System.CalloutException e) {
            thrownException = e;
        }
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, thrownException, 'System.CalloutException should have been thrown');
        System.assertEquals(true, thrownException.getMessage().contains('Loan application not found'), 
                            'Exception message should contain "Loan application not found", but got: ' + thrownException.getMessage());
    }
    
    @IsTest
    static void testScore_InvalidJsonRequest() {
        // Arrange
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/credit/score';
        request.httpMethod = 'POST';
        
        request.requestBody = Blob.valueOf('{ invalid json }');
        
        RestContext.request = request;
        RestContext.response = response;
        
        // Act
        Test.startTest();
        System.CalloutException thrownException;
        try {
            CreditScoreRest.CreditResponse result = CreditScoreRest.score();
        } catch (System.CalloutException e) {
            thrownException = e;
        }
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, thrownException, 'System.CalloutException should have been thrown for invalid JSON');
        System.assertNotEquals(null, thrownException.getMessage(), 'Exception should have a meaningful error message');
        System.assertNotEquals('', thrownException.getMessage(), 'Exception message should not be empty');
    }
}