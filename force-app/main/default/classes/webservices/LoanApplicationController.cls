/**
 * @description Controller class for Loan Application Workbench LWC
 * @author Tony Wu
 * @date 2025-10-11
 */
public with sharing class LoanApplicationController {
    
    public class LoanApplicationException extends Exception {}
    
    /**
     * @description Get loan applications for the workbench
     * @return List of Loan Application records with related data
     */
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
    
    /**
     * @description Submit a loan application for credit review
     * @param applicationId ID of the application to submit
     * @return Updated Loan Application record
     */
    @AuraEnabled
    public static Loan_Application__c submitLoanApplication(Id applicationId) {
        try {
            // Validate input
            if (applicationId == null) {
                throw new LoanApplicationException('Application ID is required');
            }
            
            // Get the current application
            Loan_Application__c app = [
                SELECT Id, Status__c, Amount__c, Purpose__c, Primary_Borrower__c
                FROM Loan_Application__c 
                WHERE Id = :applicationId 
                LIMIT 1
            ];
            
            // Validate that application can be submitted
            if (app.Status__c != 'Draft') {
                throw new LoanApplicationException('Only Draft applications can be submitted');
            }
            
            // Validate required fields
            if (app.Amount__c == null || app.Amount__c <= 0) {
                throw new LoanApplicationException('Loan amount is required and must be greater than 0');
            }
            
            if (String.isBlank(app.Purpose__c)) {
                throw new LoanApplicationException('Loan purpose is required');
            }
            
            if (app.Primary_Borrower__c == null) {
                throw new LoanApplicationException('Primary borrower is required');
            }
            
            // Update status to Submitted - this will trigger our service logic
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
    
    /**
     * @description Create a new loan application
     * @param amount Loan amount
     * @param purpose Loan purpose
     * @param primaryBorrowerId ID of the primary borrower
     * @return Created Loan Application record
     */
    @AuraEnabled
    public static Loan_Application__c createLoanApplication(Decimal amount, String purpose, Id primaryBorrowerId) {
        try {
            // Validate inputs
            if (amount == null || amount <= 0) {
                throw new LoanApplicationException('Loan amount is required and must be greater than 0');
            }
            
            if (String.isBlank(purpose)) {
                throw new LoanApplicationException('Loan purpose is required');
            }
            
            if (primaryBorrowerId == null) {
                throw new LoanApplicationException('Primary borrower is required');
            }
            
            // Create new application
            Loan_Application__c newApp = new Loan_Application__c(
                Amount__c = amount,
                Purpose__c = purpose,
                Primary_Borrower__c = primaryBorrowerId,
                Status__c = 'Draft'
            );
            
            insert newApp;
            
            // Return with related data
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