trigger LoanApplicationTrigger on Loan_Application__c (after insert, after update) {
    LoanSubmitHandler.handle(Trigger.new, Trigger.oldMap);
}