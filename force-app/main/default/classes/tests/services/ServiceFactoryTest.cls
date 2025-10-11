/**
 * @description Test class for ServiceFactory
 * @author Tony Wu
 * @date 2025-10-11
 */
@IsTest
private class ServiceFactoryTest {
    
    @IsTest
    static void testGetLoanApplicationService_DefaultImplementation() {
        Test.startTest();
        
        // Reset factory to ensure clean state
        ServiceFactory.reset();
        
        // Get service instance
        ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
        
        Test.stopTest();
        
        // Verify we get a service instance
        System.assertNotEquals(null, service, 'Service should not be null');
        System.assertEquals(true, service instanceof LoanApplicationService, 'Should return LoanApplicationService implementation');
    }
    
    @IsTest
    static void testGetLoanApplicationService_Singleton() {
        Test.startTest();
        
        // Reset factory to ensure clean state
        ServiceFactory.reset();
        
        // Get service instance twice
        ILoanApplicationService service1 = ServiceFactory.getLoanApplicationService();
        ILoanApplicationService service2 = ServiceFactory.getLoanApplicationService();
        
        Test.stopTest();
        
        // Verify singleton behavior - same instance returned
        System.assertEquals(service1, service2, 'Factory should return same instance (singleton pattern)');
    }
    
    @IsTest
    static void testSetLoanApplicationService_MockImplementation() {
        Test.startTest();
        
        // Create mock implementation
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        
        // Set mock implementation
        ServiceFactory.setLoanApplicationService(mockService);
        
        // Get service instance
        ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
        
        Test.stopTest();
        
        // Verify we get the mock implementation
        System.assertEquals(mockService, service, 'Factory should return the mock implementation');
        System.assertEquals(true, service instanceof MockLoanApplicationService, 'Should return MockLoanApplicationService');
    }
    
    @IsTest
    static void testReset_ClearsInstance() {
        Test.startTest();
        
        // Get initial service instance
        ILoanApplicationService service1 = ServiceFactory.getLoanApplicationService();
        
        // Reset factory
        ServiceFactory.reset();
        
        // Get service instance again
        ILoanApplicationService service2 = ServiceFactory.getLoanApplicationService();
        
        Test.stopTest();
        
        // Verify reset creates new instance
        System.assertNotEquals(service1, service2, 'Reset should create new instance');
    }
    
    @IsTest
    static void testFactoryWithMockInTriggerContext() {
        Test.startTest();
        
        // Setup mock service
        MockLoanApplicationService mockService = new MockLoanApplicationService();
        ServiceFactory.setLoanApplicationService(mockService);
        
        // Create test data
        List<Loan_Application__c> loanApps = TestDataFactory.createLoanApplications(2, false);
        
        // Get service and test methods
        ILoanApplicationService service = ServiceFactory.getLoanApplicationService();
        service.processNewLoanApplications(loanApps);
        
        Test.stopTest();
        
        // Verify mock was called
        System.assertEquals(1, mockService.newApplicationCallCount, 'Mock service should have been called once');
        System.assertEquals(2, mockService.processedNewApplications.size(), 'Mock should have processed 2 applications');
    }
}