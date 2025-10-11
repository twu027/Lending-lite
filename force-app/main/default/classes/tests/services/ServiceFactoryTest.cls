/**
 * @description Test class for ServiceFactory
 * @author Tony Wu
 * @date 2025-10-11
 */
@IsTest
private class ServiceFactoryTest {
    
    @IsTest
    static void testGetLoanApplicationService_DefaultImplementation() {
        // Arrange
        ServiceFactory.reset();
        
        // Act
        Test.startTest();
        ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, service, 'Service should not be null');
        System.assertEquals(true, service instanceof LoanApplicationService, 'Should return LoanApplicationService implementation');
    }
    
    @IsTest
    static void testGetLoanApplicationService_Singleton() {
        // Arrange
        ServiceFactory.reset();
        
        // Act
        Test.startTest();
        ILoanApplicationService service1 = ServiceFactory.getLoanApplicationService();
        ILoanApplicationService service2 = ServiceFactory.getLoanApplicationService();
        Test.stopTest();
        
        // Assert
        System.assertEquals(service1, service2, 'Factory should return same instance (singleton pattern)');
    }
    
    @IsTest
    static void testSetLoanApplicationService_MockImplementation() {
        // Arrange
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        ServiceFactory.setLoanApplicationService(mockService);
        
        // Act
        Test.startTest();
        ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
        Test.stopTest();
        
        // Assert
        System.assertEquals(mockService, service, 'Factory should return the mock implementation');
        System.assertEquals(true, service instanceof MockLoanApplicationService, 'Should return MockLoanApplicationService');
    }
    
    @IsTest
    static void testReset_ClearsInstance() {
        // Arrange
        ILoanApplicationService service1 = ServiceFactory.getLoanApplicationService();
        
        // Act
        Test.startTest();
        ServiceFactory.reset();
        ILoanApplicationService service2 = ServiceFactory.getLoanApplicationService();
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(service1, service2, 'Reset should create new instance');
    }
    
    @IsTest
    static void testFactoryWithMockInTriggerContext() {
        // Arrange
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        ServiceFactory.setLoanApplicationService(mockService);
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, false);
        
        // Act
        Test.startTest();
        ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
        service.processNewLoanApplications(loanApps);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, mockService.newApplicationCallCount, 'Mock service should have been called once');
        System.assertEquals(2, mockService.processedNewApplications.size(), 'Mock should have processed 2 applications');
    }
}