/**
 * @description Test class for LoanSubmitHandler
 * @author Tony Wu
 * @date 2025-10-11
 */
@IsTest
private class LoanSubmitHandlerTest {
    
    @IsTest
    static void testHandle_AfterInsert() {
        // Arrange
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        ServiceFactory.setLoanApplicationService(mockService);
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(3, false);
        
        // Act
        Test.startTest();
        LoanSubmitHandler.handle(loanApps, null);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, mockService.newApplicationCallCount, 'processNewLoanApplications should be called once');
        System.assertEquals(0, mockService.statusChangeCallCount, 'processStatusChanges should not be called for insert');
        System.assertEquals(3, mockService.processedNewApplications.size(), 'Should process all 3 applications');
        
        ServiceFactory.reset();
    }
    
    @IsTest
    static void testHandle_AfterUpdate_WithStatusChanges() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, true);
        
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        ServiceFactory.setLoanApplicationService(mockService);
        
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        for (Loan_Application__c app : loanApps) {
            Loan_Application__c oldApp = app.clone(true);
            oldApp.Status__c = 'Draft';
            oldMap.put(app.Id, oldApp);
        }
        
        loanApps[0].Status__c = 'Approved';
        loanApps[1].Status__c = 'Declined';
        
        // Act
        Test.startTest();
        LoanSubmitHandler.handle(loanApps, oldMap);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, mockService.newApplicationCallCount, 'processNewLoanApplications should not be called for update');
        System.assertEquals(1, mockService.statusChangeCallCount, 'processStatusChanges should be called once');
        System.assertEquals(2, mockService.processedStatusChanges.size(), 'Should process status changes for both applications');
        
        ServiceFactory.reset();
    }
    
    @IsTest
    static void testHandle_AfterUpdate_NoStatusChanges() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, true);
        
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        ServiceFactory.setLoanApplicationService(mockService);
        
        Map<Id, Loan_Application__c> oldMap = new Map<Id, Loan_Application__c>();
        for (Loan_Application__c app : loanApps) {
            Loan_Application__c oldApp = app.clone(true);
            oldApp.Status__c = 'Draft';
            oldMap.put(app.Id, oldApp);
        }
        
        // Act
        Test.startTest();
        LoanSubmitHandler.handle(loanApps, oldMap);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, mockService.newApplicationCallCount, 'processNewLoanApplications should not be called for update');
        System.assertEquals(0, mockService.statusChangeCallCount, 'processStatusChanges should not be called when no status changes');
        System.assertEquals(0, mockService.processedStatusChanges.size(), 'Should not process any status changes');
        
        ServiceFactory.reset();
    }
    
    @IsTest
    static void testTriggerIntegration_Insert() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, false);
        
        // Act
        Test.startTest();
        insert loanApps;
        Test.stopTest();
        
        // Assert
        List<Loan_Application__c> insertedApps = [SELECT Id, Name, Status__c FROM Loan_Application__c WHERE Id IN :loanApps];
        System.assertEquals(2, insertedApps.size(), 'Both loan applications should be inserted');
        
        for (Loan_Application__c app : insertedApps) {
            System.assertEquals('Draft', app.Status__c, 'Default status should be Draft');
        }
    }
    
    @IsTest
    static void testTriggerIntegration_Update() {
        // Arrange
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(1, true);
        loanApps[0].Status__c = 'Approved';
        
        // Act
        Test.startTest();
        update loanApps;
        Test.stopTest();
        
        // Assert
        Loan_Application__c updatedApp = [SELECT Id, Status__c FROM Loan_Application__c WHERE Id = :loanApps[0].Id];
        System.assertEquals('Approved', updatedApp.Status__c, 'Status should be updated to Approved');
    }
    
    @IsTest
    static void testValidationErrors_ThroughTrigger() {
        // Arrange
        Loan_Application__c invalidApp = TestDataFactory.createInvalidLoanApplication();
        
        // Act
        Test.startTest();
        DmlException thrownException;
        try {
            insert invalidApp;
        } catch (DmlException e) {
            thrownException = e;
        }
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, thrownException, 'DmlException should have been thrown for invalid loan application');
        System.assert(thrownException.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') || 
                     thrownException.getMessage().contains('REQUIRED_FIELD_MISSING'), 
                     'Exception message should contain validation error');
    }
}