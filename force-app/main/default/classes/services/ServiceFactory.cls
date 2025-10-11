/**
 * @description Factory class for Service layer dependency injection
 * @author Tony Wu
 * @date 2025-10-11
 */
public with sharing class ServiceFactory {
    
    // Service instances - could be configured via Custom Metadata in the future
    private static ILoanApplicationService loanApplicationServiceInstance;
    
    /**
     * @description Get instance of Loan Application Service
     * @return ILoanApplicationService implementation
     */
    public static ILoanApplicationService getLoanApplicationService() {
        if (loanApplicationServiceInstance == null) {
            // Default implementation - could be configurable via Custom Metadata
            loanApplicationServiceInstance = new LoanApplicationService();
        }
        return loanApplicationServiceInstance;
    }
    
    /**
     * @description Set custom implementation (useful for testing)
     * @param serviceImpl Custom service implementation
     */
    @TestVisible
    public static void setLoanApplicationService(ILoanApplicationService serviceImpl) {
        loanApplicationServiceInstance = serviceImpl;
    }
    
    /**
     * @description Reset all service instances (useful for testing)
     */
    @TestVisible
    public static void reset() {
        loanApplicationServiceInstance = null;
    }
}