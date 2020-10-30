import { LightningElement, wire, api } from 'lwc';
import getObjectName from '@salesforce/apex/CustomerInteractionTimeline_helper.getObjectName';
import isPersonAccount from '@salesforce/apex/CustomerInteractionTimeline_helper.isPersonAccount';

export default class CustomerInteractionTimelineContainer extends LightningElement {
    _isAccount = false;
    _isLead = false;
    _isOpportunity = false;
    _isSCObj = false;

    @api recordId;


    @wire(getObjectName, { recordId: '$recordId' })
    getRecordInformation({ error, data }) {
        if (error) {
            console.log(error);
        }
        else if (data) {
            if (data === 'Account') {
                isPersonAccount({recordId: this.recordId})
                .then(response => {
                    if(response){
                        this._isAccount = false;
                        this._isSCObj = true
                    }
                    else{
                        this._isAccount = true;
                    }
                })
                .catch(error => {
                    console.log(error);
                })
                
            }
            else if (data === 'Case' || data === 'LiveChatTranscript' || data === 'Task' || data === 'Contact' || data === 'SocialPost' || data === 'Lead') {
                this._isSCObj = true;
                if(data === 'Lead')
                    this._isLead = true;
                else 
                    this._isLead = false;
            }
            else if (data === 'Opportunity') {
                this._isOpportunity = true;
            }
        }
    }
}