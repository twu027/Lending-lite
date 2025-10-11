/**
 * @description Test class for LoanApplicationController
 * @author Tony Wu
 * @date 2025-10-12
 */
@IsTest
private class LoanApplicationControllerTest {
    
    @TestSetup
    static void setupTestData() {
        
        TestDataFactory.createLoanApplications(5, true);
    }
    
    @IsTest
    static void testGetLoanApplications_Success() {
        Test.startTest();
        
        // Act
        List<Loan_Application__c> results = LoanApplicationController.getLoanApplications();
        
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(5, results.size(), 'Should return all 5 loan applications');
        
        
        for (Loan_Application__c app : results) {
            System.assertNotEquals(null, app.Amount__c, 'Amount should be populated');
            System.assertNotEquals(null, app.Purpose__c, 'Purpose should be populated');
            System.assertNotEquals(null, app.Status__c, 'Status should be populated');
            System.assertNotEquals(null, app.Primary_Borrower__r.Name, 'Borrower name should be populated');
        }
    }
    
    @IsTest
    static void testGetLoanApplications_OrderedByCreatedDate() {
        Test.startTest();
        
        // Act
        List<Loan_Application__c> results = LoanApplicationController.getLoanApplications();
        
        Test.stopTest();
        
        // Assert
        if (results.size() > 1) {
            for (Integer i = 0; i < results.size() - 1; i++) {
                System.assert(results[i].CreatedDate >= results[i + 1].CreatedDate, 
                    'Results should be ordered by CreatedDate DESC');
            }
        }
    }
    
    @IsTest
    static void testCreateLoanApplication_Success() {
        
        Party__c borrower = [SELECT Id FROM Party__c LIMIT 1];
        
        Test.startTest();
        
        // Act
        Loan_Application__c result = LoanApplicationController.createLoanApplication(
            100000,
            'Home Loan',
            borrower.Id
        );
        
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.Id, 'Application should have an ID');
        System.assertEquals(100000, result.Amount__c, 'Amount should match');
        System.assertEquals('Home Loan', result.Purpose__c, 'Purpose should match');
        System.assertEquals('Draft', result.Status__c, 'Status should be Draft');
        System.assertEquals(borrower.Id, result.Primary_Borrower__c, 'Borrower should match');
        System.assertNotEquals(null, result.Primary_Borrower__r.Name, 'Borrower name should be populated');
        
        Loan_Application__c dbRecord = [SELECT Id FROM Loan_Application__c WHERE Id = :result.Id];
        System.assertNotEquals(null, dbRecord, 'Record should exist in database');
    }
    
    @IsTest
    static void testCreateLoanApplication_NullAmount() {
        Party__c borrower = [SELECT Id FROM Party__c LIMIT 1];
        
        Test.startTest();
        
        LoanApplicationController.LoanApplicationException thrownException;
        try {
            LoanApplicationController.createLoanApplication(null, 'Home Loan', borrower.Id);
        } catch (LoanApplicationController.LoanApplicationException e) {
            thrownException = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, thrownException, 'Exception should have been thrown for null amount');
        System.assert(thrownException.getMessage().contains('Loan amount is required'), 
            'Exception message should mention amount requirement');
    }
    
    @IsTest
    static void testCreateLoanApplication_ZeroAmount() {
        Party__c borrower = [SELECT Id FROM Party__c LIMIT 1];
        
        Test.startTest();
        
        LoanApplicationController.LoanApplicationException thrownException;
        try {
            LoanApplicationController.createLoanApplication(0, 'Home Loan', borrower.Id);
        } catch (LoanApplicationController.LoanApplicationException e) {
            thrownException = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, thrownException, 'Exception should have been thrown for zero amount');
        System.assert(thrownException.getMessage().contains('must be greater than 0'), 
            'Exception message should mention amount must be positive');
    }
    
    @IsTest
    static void testCreateLoanApplication_NegativeAmount() {
        Party__c borrower = [SELECT Id FROM Party__c LIMIT 1];
        
        Test.startTest();
        
        LoanApplicationController.LoanApplicationException thrownException;
        try {
            LoanApplicationController.createLoanApplication(-1000, 'Home Loan', borrower.Id);
        } catch (LoanApplicationController.LoanApplicationException e) {
            thrownException = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, thrownException, 'Exception should have been thrown for negative amount');
    }
    
    @IsTest
    static void testCreateLoanApplication_NullPurpose() {
        Party__c borrower = [SELECT Id FROM Party__c LIMIT 1];
        
        Test.startTest();
        
        LoanApplicationController.LoanApplicationException thrownException;
        try {
            LoanApplicationController.createLoanApplication(50000, null, borrower.Id);
        } catch (LoanApplicationController.LoanApplicationException e) {
            thrownException = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, thrownException, 'Exception should have been thrown for null purpose');
        System.assert(thrownException.getMessage().contains('Loan purpose is required'), 
            'Exception message should mention purpose requirement');
    }
    
    @IsTest
    static void testCreateLoanApplication_BlankPurpose() {
        Party__c borrower = [SELECT Id FROM Party__c LIMIT 1];
        
        Test.startTest();
        
        LoanApplicationController.LoanApplicationException thrownException;
        try {
            LoanApplicationController.createLoanApplication(50000, '', borrower.Id);
        } catch (LoanApplicationController.LoanApplicationException e) {
            thrownException = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, thrownException, 'Exception should have been thrown for blank purpose');
    }
    
    @IsTest
    static void testCreateLoanApplication_NullBorrower() {
        Test.startTest();
        
        LoanApplicationController.LoanApplicationException thrownException;
        try {
            LoanApplicationController.createLoanApplication(50000, 'Home Loan', null);
        } catch (LoanApplicationController.LoanApplicationException e) {
            thrownException = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, thrownException, 'Exception should have been thrown for null borrower');
        System.assert(thrownException.getMessage().contains('Primary borrower is required'), 
            'Exception message should mention borrower requirement');
    }
    
    @IsTest
    static void testSubmitLoanApplication_Success() {
        // Arrange
        Loan_Application__c app = [SELECT Id, Status__c FROM Loan_Application__c WHERE Status__c = 'Draft' LIMIT 1];
        
        Test.startTest();
        
        // Act
        Loan_Application__c result = LoanApplicationController.submitLoanApplication(app.Id);
        
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('Submitted', result.Status__c, 'Status should be updated to Submitted');
        
        Loan_Application__c dbRecord = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        System.assertEquals('Submitted', dbRecord.Status__c, 'Database record should be updated');
    }
    
    @IsTest
    static void testSubmitLoanApplication_NullId() {
        Test.startTest();
        
        LoanApplicationController.LoanApplicationException thrownException;
        try {
            LoanApplicationController.submitLoanApplication(null);
        } catch (LoanApplicationController.LoanApplicationException e) {
            thrownException = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, thrownException, 'Exception should have been thrown for null ID');
        System.assert(thrownException.getMessage().contains('Application ID is required'), 
            'Exception message should mention ID requirement');
    }
    
    @IsTest
    static void testSubmitLoanApplication_InvalidId() {
        Test.startTest();
        
        LoanApplicationController.LoanApplicationException thrownException;
        try {
            // Use a valid ID format but non-existent record
            LoanApplicationController.submitLoanApplication('a0X000000000000AAA');
        } catch (LoanApplicationController.LoanApplicationException e) {
            thrownException = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, thrownException, 'Exception should have been thrown for invalid ID');
        System.assert(thrownException.getMessage().contains('not found'), 
            'Exception message should mention application not found');
    }
    
    @IsTest
    static void testSubmitLoanApplication_AlreadySubmitted() {
        // Get a draft application and submit it first
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c WHERE Status__c = 'Draft' LIMIT 1];
        app.Status__c = 'Submitted';
        update app;
        
        Test.startTest();
        
        LoanApplicationController.LoanApplicationException thrownException;
        try {
            LoanApplicationController.submitLoanApplication(app.Id);
        } catch (LoanApplicationController.LoanApplicationException e) {
            thrownException = e;
        }
        
        Test.stopTest();
        
        System.assertNotEquals(null, thrownException, 'Exception should have been thrown for already submitted application');
        System.assert(thrownException.getMessage().contains('Only Draft applications can be submitted'), 
            'Exception message should mention Draft requirement');
    }
}
