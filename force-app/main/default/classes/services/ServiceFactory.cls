/**
 * @description Factory class for Service layer dependency injection
 * @version 1.0
 */
public with sharing class ServiceFactory {
    
    private static ILoanApplicationService loanApplicationServiceInstance;
    
    public static ILoanApplicationService getLoanApplicationService() {
        if (loanApplicationServiceInstance == null) {
            loanApplicationServiceInstance = new LoanApplicationService();
        }
        return loanApplicationServiceInstance;
    }
    
    @TestVisible
    public static void setLoanApplicationService(ILoanApplicationService serviceImpl) {
        loanApplicationServiceInstance = serviceImpl;
    }
    
    @TestVisible
    public static void reset() {
        loanApplicationServiceInstance = null;
    }
}