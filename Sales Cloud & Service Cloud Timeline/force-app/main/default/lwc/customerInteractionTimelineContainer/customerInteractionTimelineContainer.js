import { LightningElement, wire, api } from 'lwc';
import getObjectName from '@salesforce/apex/CustomerInteractionTimeline_helper.getObjectName';
import isPersonAccount from '@salesforce/apex/CustomerInteractionTimeline_helper.isPersonAccount';

export default class CustomerInteractionTimelineContainer extends LightningElement {
    _isAccount = false;
    _isLead = false;
    _isOpportunity = false;
    _isSCObj = false;
    _wrongObject = false;
    __object;
    __objectName;
    @api recordId;


    @wire(getObjectName, { recordId: '$recordId' })
    getRecordInformation({ error, data }) {
        if (error) {
            console.log(error);
        }
        else if (data) {
            this.__object = data.apiName;
            this.__objectName = data.objectName;
            if (this.__object === 'Account') {
                isPersonAccount({ recordId: this.recordId })
                    .then(response => {
                        if (response) {
                            this._isAccount = false;
                            this._isSCObj = true
                        }
                        else {
                            this._isAccount = true;
                        }
                    })
                    .catch(error => {
                        console.log(error);
                    })

            }
            else if (this.__object === 'Case' || this.__object === 'LiveChatTranscript' || this.__object === 'Task' || this.__object === 'Contact' || this.__object === 'SocialPost' || this.__object === 'Lead') {
                this._isSCObj = true;
                if (this.__object === 'Lead')
                    this._isLead = true;
                else
                    this._isLead = false;
            }
            else if (this.__object === 'Opportunity') {
                this._isOpportunity = true;
            }
            else {
                this._wrongObject = true;
            }
        }
    }
}