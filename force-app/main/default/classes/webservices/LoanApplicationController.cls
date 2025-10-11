/**
 * @description Controller class for Loan Application Workbench LWC
 */
public with sharing class LoanApplicationController {
    
    public class LoanApplicationException extends Exception {}
    
    @AuraEnabled(cacheable=true)
    public static List<Loan_Application__c> getLoanApplications() {
        try {
            return [
                SELECT Id, Amount__c, Purpose__c, Status__c, Risk_Rating__c, CreatedDate,
                       Primary_Borrower__c, Primary_Borrower__r.Name
                FROM Loan_Application__c 
                ORDER BY CreatedDate DESC 
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new LoanApplicationException('Failed to retrieve loan applications: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Loan_Application__c submitLoanApplication(Id applicationId) {
        try {
            if (applicationId == null) {
                throw new LoanApplicationException('Application ID is required');
            }
            
            Loan_Application__c app = [
                SELECT Id, Status__c, Amount__c, Purpose__c, Primary_Borrower__c
                FROM Loan_Application__c 
                WHERE Id = :applicationId 
                LIMIT 1
            ];
            
            if (app.Status__c != 'Draft') {
                throw new LoanApplicationException('Only Draft applications can be submitted');
            }
            
            if (app.Amount__c == null || app.Amount__c <= 0) {
                throw new LoanApplicationException('Loan amount is required and must be greater than 0');
            }
            
            if (String.isBlank(app.Purpose__c)) {
                throw new LoanApplicationException('Loan purpose is required');
            }
            
            if (app.Primary_Borrower__c == null) {
                throw new LoanApplicationException('Primary borrower is required');
            }
            
            app.Status__c = 'Submitted';
            update app;
            
            return app;
            
        } catch (QueryException e) {
            throw new LoanApplicationException('Loan application not found');
        } catch (DmlException e) {
            throw new LoanApplicationException('Failed to submit application: ' + e.getMessage());
        } catch (LoanApplicationException e) {
            throw e;
        } catch (Exception e) {
            throw new LoanApplicationException('Unexpected error: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Loan_Application__c createLoanApplication(Decimal amount, String purpose, Id primaryBorrowerId) {
        try {
            if (amount == null || amount <= 0) {
                throw new LoanApplicationException('Loan amount is required and must be greater than 0');
            }
            
            if (String.isBlank(purpose)) {
                throw new LoanApplicationException('Loan purpose is required');
            }
            
            if (primaryBorrowerId == null) {
                throw new LoanApplicationException('Primary borrower is required');
            }
            
            Loan_Application__c newApp = new Loan_Application__c(
                Amount__c = amount,
                Purpose__c = purpose,
                Primary_Borrower__c = primaryBorrowerId,
                Status__c = 'Draft'
            );
            
            insert newApp;
            
            return [
                SELECT Id, Amount__c, Purpose__c, Status__c, Risk_Rating__c, CreatedDate,
                       Primary_Borrower__c, Primary_Borrower__r.Name
                FROM Loan_Application__c 
                WHERE Id = :newApp.Id 
                LIMIT 1
            ];
            
        } catch (DmlException e) {
            throw new LoanApplicationException('Failed to create application: ' + e.getMessage());
        } catch (LoanApplicationException e) {
            throw e;
        } catch (Exception e) {
            throw new LoanApplicationException('Unexpected error: ' + e.getMessage());
        }
    }
}