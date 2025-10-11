import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getLoanApplications from '@salesforce/apex/LoanApplicationController.getLoanApplications';
import submitLoanApplication from '@salesforce/apex/LoanApplicationController.submitLoanApplication';

export default class LoanAppWorkbench extends NavigationMixin(LightningElement) {
    @track loanApplications = [];
    @track isLoading = false;
    wiredLoanApplicationsResult;

    @wire(getLoanApplications)
    wiredLoanApplications(result) {
        this.wiredLoanApplicationsResult = result;
        if (result.data) {
            this.loanApplications = result.data.map(app => ({
                id: app.Id,
                applicantName: app.Primary_Borrower__r ? app.Primary_Borrower__r.Name : 'Unknown',
                loanAmount: app.Amount__c ? app.Amount__c.toLocaleString() : '0',
                status: app.Status__c || 'Draft',
                applicationDate: app.CreatedDate ? new Date(app.CreatedDate).toLocaleDateString() : '',
                purpose: app.Purpose__c || '',
                riskRating: app.Risk_Rating__c || 0,
                canSubmit: app.Status__c === 'Draft'
            }));
        } else if (result.error) {
            this.showToast('Error', 'Failed to load loan applications', 'error');
            console.error('Error loading loan applications:', result.error);
        }
        // Always set loading to false when wire service completes (success or error)
        this.isLoading = false;
    }

    connectedCallback() {
        // Only show loading if we don't have data yet and wire service hasn't completed
        if ((!this.loanApplications || this.loanApplications.length === 0) && 
            (!this.wiredLoanApplicationsResult || (!this.wiredLoanApplicationsResult.data && !this.wiredLoanApplicationsResult.error))) {
            this.isLoading = true;
        }
    }

    renderedCallback() {
        // Ensure loading is turned off if we have data or error from wire service
        if (this.wiredLoanApplicationsResult && (this.wiredLoanApplicationsResult.data || this.wiredLoanApplicationsResult.error)) {
            this.isLoading = false;
        }
    }

    async handleRefresh() {
        try {
            this.isLoading = true;
            await refreshApex(this.wiredLoanApplicationsResult);
        } catch (error) {
            this.showToast('Error', 'Failed to refresh data: ' + error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleViewApplication(event) {
        const applicationId = event.target.dataset.id;
        // Navigate to record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: applicationId,
                objectApiName: 'Loan_Application__c',
                actionName: 'view'
            }
        });
    }

    async handleSubmitApplication(event) {
        const applicationId = event.target.dataset.id;
        
        try {
            this.isLoading = true;
            await submitLoanApplication({ applicationId: applicationId });
            
            this.showToast('Success', 'Loan application submitted successfully. Credit review process initiated.', 'success');
            
            // Refresh the data
            await this.handleRefresh();
            
        } catch (error) {
            this.showToast('Error', 'Failed to submit application: ' + error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get hasApplications() {
        return this.loanApplications && this.loanApplications.length > 0;
    }
}