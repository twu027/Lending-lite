/**
 * @description Test class for LoanSubmitHandler
 * @author Tony Wu
 * @date 2025-10-11
 */
@IsTest
private class LoanSubmitHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        // Setup will be done in individual test methods as needed
    }
    
    @IsTest
    static void testHandle_AfterInsert() {
        Test.startTest();
        
        // Setup mock service to verify calls
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        ServiceFactory.setLoanApplicationService(mockService);
        
        // Create test loan applications
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(3, false);
        
        // Call handler method (simulating trigger context)
        LoanSubmitHandler.handle(loanApps, null); // null oldMap indicates insert
        
        Test.stopTest();
        
        // Verify service method was called
        System.assertEquals(1, mockService.newApplicationCallCount, 'processNewLoanApplications should be called once');
        System.assertEquals(0, mockService.statusChangeCallCount, 'processStatusChanges should not be called for insert');
        System.assertEquals(3, mockService.processedNewApplications.size(), 'Should process all 3 applications');
        
        // Reset factory for other tests
        ServiceFactory.reset();
    }
    
    @IsTest
    static void testHandle_AfterUpdate_WithStatusChanges() {
        // Create test loan applications first (before setting up mock)
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, true);
        
        Test.startTest();
        
        // Setup mock service to verify calls AFTER insert
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        ServiceFactory.setLoanApplicationService(mockService);
        
        // Create old map with different statuses
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        for (Loan_Application__c app : loanApps) {
            Loan_Application__c oldApp = app.clone(true);
            oldApp.Status__c = 'Draft';
            oldMap.put(app.Id, oldApp);
        }
        
        // Change status to trigger status change processing
        loanApps[0].Status__c = 'Approved';
        loanApps[1].Status__c = 'Declined'; // Use valid picklist value
        
        // Call handler method (simulating update trigger context)
        LoanSubmitHandler.handle(loanApps, oldMap);
        
        Test.stopTest();
        
        // Verify service method was called
        System.assertEquals(0, mockService.newApplicationCallCount, 'processNewLoanApplications should not be called for update');
        System.assertEquals(1, mockService.statusChangeCallCount, 'processStatusChanges should be called once');
        System.assertEquals(2, mockService.processedStatusChanges.size(), 'Should process status changes for both applications');
        
        // Reset factory for other tests
        ServiceFactory.reset();
    }
    
    @IsTest
    static void testHandle_AfterUpdate_NoStatusChanges() {
        // Create test loan applications first (before setting up mock)
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, true);
        
        Test.startTest();
        
        // Setup mock service to verify calls AFTER insert
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        ServiceFactory.setLoanApplicationService(mockService);
        
        // Create old map with same statuses (no changes)
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        for (Loan_Application__c app : loanApps) {
            Loan_Application__c oldApp = app.clone(true);
            oldApp.Status__c = 'Draft'; // Same status as app.Status__c
            oldMap.put(app.Id, oldApp);
        }
        
        // Call handler method (simulating update trigger context)
        LoanSubmitHandler.handle(loanApps, oldMap);
        
        Test.stopTest();
        
        // Verify service method was not called for status changes
        System.assertEquals(0, mockService.newApplicationCallCount, 'processNewLoanApplications should not be called for update');
        System.assertEquals(0, mockService.statusChangeCallCount, 'processStatusChanges should not be called when no status changes');
        System.assertEquals(0, mockService.processedStatusChanges.size(), 'Should not process any status changes');
        
        // Reset factory for other tests
        ServiceFactory.reset();
    }
    
    @IsTest
    static void testTriggerIntegration_Insert() {
        Test.startTest();
        
        // Create loan applications and insert (triggers will fire)
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, false);
        
        // Insert to trigger the actual trigger
        insert loanApps;
        
        Test.stopTest();
        
        // Verify records were inserted successfully
        List<Loan_Application__c> insertedApps = [SELECT Id, Name, Status__c FROM Loan_Application__c WHERE Id IN :loanApps];
        System.assertEquals(2, insertedApps.size(), 'Both loan applications should be inserted');
        
        // Verify default status was set (if service logic is working)
        for (Loan_Application__c app : insertedApps) {
            System.assertEquals('Draft', app.Status__c, 'Default status should be Draft');
        }
    }
    
    @IsTest
    static void testTriggerIntegration_Update() {
        Test.startTest();
        
        // Create and insert loan applications
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(1, true);
        
        // Update status to trigger status change logic
        loanApps[0].Status__c = 'Approved';
        update loanApps;
        
        Test.stopTest();
        
        // Verify update was successful
        Loan_Application__c updatedApp = [SELECT Id, Status__c FROM Loan_Application__c WHERE Id = :loanApps[0].Id];
        System.assertEquals('Approved', updatedApp.Status__c, 'Status should be updated to Approved');
    }
    
    @IsTest
    static void testValidationErrors_ThroughTrigger() {
        Test.startTest();
        
        // Create invalid loan application
        Loan_Application__c invalidApp = TestDataFactory.createInvalidLoanApplication();
        
        // Try to insert - should fail due to validation
        DmlException thrownException;
        try {
            insert invalidApp;
            System.assert(false, 'Expected DmlException to be thrown for invalid loan application');
        } catch (DmlException e) {
            thrownException = e;
        }
        
        // Verify exception was thrown and has validation error message
        System.assertNotEquals(null, thrownException, 'DmlException should have been thrown for invalid loan application');
        System.assertEquals(true, thrownException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') || 
                                 thrownException.getMessage().contains('REQUIRED_FIELD_MISSING'), 
                           'Exception message should contain validation error, but got: ' + thrownException.getMessage());
        
        Test.stopTest();
    }
}