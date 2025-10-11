/**
 * @description Test class for LoanApplicationService
 * @author Tony Wu
 * @date 2025-10-11
 */
@IsTest
private class LoanApplicationServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data that will be available to all test methods
        TestDataFactory.createLoanApplications(5, true);
    }
    
    @IsTest
    static void testProcessNewLoanApplications_ValidData() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(3, false);
        LoanApplicationService service = new LoanApplicationService();
        
        // Act
        Test.startTest();
        service.processNewLoanApplications(loanApps);
        Test.stopTest();
        
        // Assert
        for (Loan_Application__c app : loanApps) {
            System.assertEquals('Draft', app.Status__c, 'Default status should be set to Draft');
        }
    }
    
    @IsTest
    static void testProcessNewLoanApplications_ValidationErrors() {
        // Arrange
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        loanApps.add(TestDataFactory.createInvalidLoanApplication());
        loanApps.add(TestDataFactory.createMaxAmountLoanApplication());
        LoanApplicationService service = new LoanApplicationService();
        
        // Act
        Test.startTest();
        service.processNewLoanApplications(loanApps);
        Test.stopTest();
        
        // Assert
        System.assertEquals(true, loanApps[0].hasErrors(), 'Invalid loan application should have validation errors');
        System.assertEquals(true, loanApps[1].hasErrors(), 'Max amount loan application should have validation errors');
    }
    
    @IsTest
    static void testProcessStatusChanges_ApprovedStatus() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, true);
        
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        for (Loan_Application__c app : loanApps) {
            Loan_Application__c oldApp = app.clone(true);
            oldApp.Status__c = 'Submitted';
            oldMap.put(app.Id, oldApp);
        }
        
        for (Loan_Application__c app : loanApps) {
            app.Status__c = 'Approved';
        }
        
        LoanApplicationService service = new LoanApplicationService();
        
        // Act
        Test.startTest();
        service.processStatusChanges(loanApps, oldMap);
        Test.stopTest();
        
        // Assert
        System.assertEquals(2, loanApps.size(), 'Should process all loan applications');
    }
    
    @IsTest
    static void testProcessStatusChanges_RejectedStatus() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(1, true);
        
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        Loan_Application__c oldApp = loanApps[0].clone(true);
        oldApp.Status__c = 'Submitted';
        oldMap.put(loanApps[0].Id, oldApp);
        
        loanApps[0].Status__c = 'Declined';
        
        LoanApplicationService service = new LoanApplicationService();
        
        // Act
        Test.startTest();
        service.processStatusChanges(loanApps, oldMap);
        Test.stopTest();
        
        // Assert
        System.assertEquals('Declined', loanApps[0].Status__c, 'Status should be Declined');
    }
    
    @IsTest
    static void testProcessStatusChanges_ReferredStatus() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(1, true);
        
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        Loan_Application__c oldApp = loanApps[0].clone(true);
        oldApp.Status__c = 'Draft';
        oldMap.put(loanApps[0].Id, oldApp);
        
        loanApps[0].Status__c = 'Referred';
        
        LoanApplicationService service = new LoanApplicationService();
        
        // Act
        Test.startTest();
        service.processStatusChanges(loanApps, oldMap);
        Test.stopTest();
        
        // Assert
        System.assertEquals('Referred', loanApps[0].Status__c, 'Status should be Referred');
    }
    
    @IsTest
    static void testProcessStatusChanges_NoStatusChange() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(1, true);
        
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        Loan_Application__c oldApp = loanApps[0].clone(true);
        oldApp.Status__c = 'Draft';
        oldMap.put(loanApps[0].Id, oldApp);
        
        loanApps[0].Status__c = 'Draft';
        
        LoanApplicationService service = new LoanApplicationService();
        
        // Act
        Test.startTest();
        service.processStatusChanges(loanApps, oldMap);
        Test.stopTest();
        
        // Assert
        System.assertEquals('Draft', loanApps[0].Status__c, 'Status should remain Draft');
    }
    
    @IsTest
    static void testProcessStatusChanges_SubmittedApplications() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, true);
        
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        for (Loan_Application__c app : loanApps) {
            Loan_Application__c oldApp = app.clone(true);
            oldApp.Status__c = 'Draft';
            oldMap.put(app.Id, oldApp);
        }
        
        for (Loan_Application__c app : loanApps) {
            app.Status__c = 'Submitted';
        }
        
        LoanApplicationService service = new LoanApplicationService();
        
        // Act
        Test.startTest();
        service.processStatusChanges(loanApps, oldMap);
        Test.stopTest();
        
        // Assert
        for (Loan_Application__c app : loanApps) {
            System.assertEquals('Submitted', app.Status__c, 'Status should be Submitted');
        }
    }
    
    @IsTest
    static void testValidationLogic_BoundaryValues() {
        // Arrange
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        loanApps.add(TestDataFactory.createLoanApplication(1000000, 'Home Loan', 'Draft', false));
        loanApps.add(TestDataFactory.createLoanApplication(1000001, 'Home Loan', 'Draft', false));
        loanApps.add(TestDataFactory.createLoanApplication(0, 'Home Loan', 'Draft', false));
        
        LoanApplicationService service = new LoanApplicationService();
        
        // Act
        Test.startTest();
        service.processNewLoanApplications(loanApps);
        Test.stopTest();
        
        // Assert
        System.assertEquals(false, loanApps[0].hasErrors(), 'Valid 1M loan should not have errors');
        System.assertEquals(true, loanApps[1].hasErrors(), 'Over 1M loan should have errors');
        System.assertEquals(true, loanApps[2].hasErrors(), 'Zero amount loan should have errors');
    }
}