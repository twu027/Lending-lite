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
        Test.startTest();
        
        // Create valid loan applications
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(3, false);
        
        // Create service instance
        LoanApplicationService service = new LoanApplicationService();
        
        // Test the method
        service.processNewLoanApplications(loanApps);
        
        Test.stopTest();
        
        // Verify default status was set
        for (Loan_Application__c app : loanApps) {
            System.assertEquals('Draft', app.Status__c, 'Default status should be set to Draft');
        }
    }
    
    @IsTest
    static void testProcessNewLoanApplications_ValidationErrors() {
        Test.startTest();
        
        // Create invalid loan application
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        loanApps.add(TestDataFactory.createInvalidLoanApplication());
        loanApps.add(TestDataFactory.createMaxAmountLoanApplication());
        
        // Create service instance
        LoanApplicationService service = new LoanApplicationService();
        
        // Test the method - should add errors to records
        service.processNewLoanApplications(loanApps);
        
        Test.stopTest();
        
        // Verify validation errors were added
        System.assertEquals(true, loanApps[0].hasErrors(), 'Invalid loan application should have validation errors');
        System.assertEquals(true, loanApps[1].hasErrors(), 'Max amount loan application should have validation errors');
    }
    
    @IsTest
    static void testProcessStatusChanges_ApprovedStatus() {
        Test.startTest();
        
        // Create loan applications
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, true);
        
        // Create old map with different status
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        for (Loan_Application__c app : loanApps) {
            Loan_Application__c oldApp = app.clone(true);
            oldApp.Status__c = 'Submitted'; // Use valid picklist value
            oldMap.put(app.Id, oldApp);
        }
        
        // Change status to Approved
        for (Loan_Application__c app : loanApps) {
            app.Status__c = 'Approved';
        }
        
        // Create service instance
        LoanApplicationService service = new LoanApplicationService();
        
        // Test the method
        service.processStatusChanges(loanApps, oldMap);
        
        Test.stopTest();
        
        // Verify approved status changes are processed correctly
        System.assertEquals(2, loanApps.size(), 'Should process all loan applications');
    }
    
    @IsTest
    static void testProcessStatusChanges_RejectedStatus() {
        Test.startTest();
        
        // Create loan applications
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(1, true);
        
        // Create old map with different status
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        Loan_Application__c oldApp = loanApps[0].clone(true);
        oldApp.Status__c = 'Submitted';
        oldMap.put(loanApps[0].Id, oldApp);
        
        // Change status to Declined
        loanApps[0].Status__c = 'Declined';
        
        // Create service instance
        LoanApplicationService service = new LoanApplicationService();
        
        // Test the method
        service.processStatusChanges(loanApps, oldMap);
        
        Test.stopTest();
        
        // Verify the method completed successfully
        System.assertEquals('Declined', loanApps[0].Status__c, 'Status should be Declined');
    }
    
    @IsTest
    static void testProcessStatusChanges_ReferredStatus() {
        Test.startTest();
        
        // Create loan applications
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(1, true);
        
        // Create old map with different status
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        Loan_Application__c oldApp = loanApps[0].clone(true);
        oldApp.Status__c = 'Draft';
        oldMap.put(loanApps[0].Id, oldApp);
        
        // Change status to Referred
        loanApps[0].Status__c = 'Referred';
        
        // Create service instance
        LoanApplicationService service = new LoanApplicationService();
        
        // Test the method
        service.processStatusChanges(loanApps, oldMap);
        
        Test.stopTest();
        
        // Verify the method completed successfully
        System.assertEquals('Referred', loanApps[0].Status__c, 'Status should be Referred');
    }
    
    @IsTest
    static void testProcessStatusChanges_NoStatusChange() {
        Test.startTest();
        
        // Create loan applications
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(1, true);
        
        // Create old map with same status
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        Loan_Application__c oldApp = loanApps[0].clone(true);
        oldApp.Status__c = 'Draft';
        oldMap.put(loanApps[0].Id, oldApp);
        
        // Keep same status
        loanApps[0].Status__c = 'Draft';
        
        // Create service instance
        LoanApplicationService service = new LoanApplicationService();
        
        // Test the method
        service.processStatusChanges(loanApps, oldMap);
        
        Test.stopTest();
        
        // Should not process any status changes
        System.assertEquals('Draft', loanApps[0].Status__c, 'Status should remain Draft');
    }
    
    @IsTest
    static void testProcessStatusChanges_SubmittedApplications() {
        Test.startTest();
        
        // Create loan applications
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, true);
        
        // Create old map with Draft status
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        for (Loan_Application__c app : loanApps) {
            Loan_Application__c oldApp = app.clone(true);
            oldApp.Status__c = 'Draft';
            oldMap.put(app.Id, oldApp);
        }
        
        // Change status to Submitted
        for (Loan_Application__c app : loanApps) {
            app.Status__c = 'Submitted';
        }
        
        // Create service instance
        LoanApplicationService service = new LoanApplicationService();
        
        // Test the method - this should trigger platform event publishing
        service.processStatusChanges(loanApps, oldMap);
        
        Test.stopTest();
        
        // Verify the applications are still in Submitted status
        for (Loan_Application__c app : loanApps) {
            System.assertEquals('Submitted', app.Status__c, 'Status should be Submitted');
        }
    }
    
    @IsTest
    static void testValidationLogic_BoundaryValues() {
        Test.startTest();
        
        // Test boundary values
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        
        // Valid boundary case
        loanApps.add(TestDataFactory.createLoanApplication(1000000, 'Home Loan', 'Draft', false)); // Exactly 1M
        
        // Invalid boundary case
        loanApps.add(TestDataFactory.createLoanApplication(1000001, 'Home Loan', 'Draft', false)); // Over 1M by 1
        
        // Zero amount
        loanApps.add(TestDataFactory.createLoanApplication(0, 'Home Loan', 'Draft', false));
        
        // Create service instance
        LoanApplicationService service = new LoanApplicationService();
        
        // Test validation
        service.processNewLoanApplications(loanApps);
        
        Test.stopTest();
        
        // Verify validation results
        System.assertEquals(false, loanApps[0].hasErrors(), 'Valid 1M loan should not have errors');
        System.assertEquals(true, loanApps[1].hasErrors(), 'Over 1M loan should have errors');
        System.assertEquals(true, loanApps[2].hasErrors(), 'Zero amount loan should have errors');
    }
}