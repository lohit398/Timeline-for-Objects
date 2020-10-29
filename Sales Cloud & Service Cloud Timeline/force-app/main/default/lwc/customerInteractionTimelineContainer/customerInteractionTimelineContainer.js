import { LightningElement, wire, api } from 'lwc';
import getObjectName from '@salesforce/apex/CustomerInteractionTimeline_helper.getObjectName';

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
            console.log(data);
            if (data === 'Account') {
                this._isAccount = true;
            }
            else if (data === 'Case' || data === 'LiveChatTranscript' || data === 'Task' || data === 'Contact' || data === 'SocialPost') {
                this._isSCObj = true;
            }
            else if (data === 'Lead') {
                this._isLead = true;
            }
            else if (data === 'Opportunity') {
                this._isOpportunity = true;
            }
        }
    }
}