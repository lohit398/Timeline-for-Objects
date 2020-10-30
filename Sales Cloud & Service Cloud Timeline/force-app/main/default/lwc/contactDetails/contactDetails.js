import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener } from 'c/pubsub';
import getOpportunitiesForContact from '@salesforce/apex/CustomerInteractionTimeline_helper.getOpportunitiesForContact';

export default class ContactDetails extends LightningElement {
    @track contact;
    @track openDetails = false;
    @wire(CurrentPageReference) pageRef;
    responseArray = [];
    sortedArray = [];



    @api
    get contactDetails() {
        return this.contact;
    }

    set contactDetails(value) {
        this.contact = value;
        if (this.contact != null || this.contact != undefined) {
            getOpportunitiesForContact({ recordId: this.contact.Id })
                .then(response => {
                    this.responseArray = JSON.parse(JSON.stringify(response));
                    this.sortData();
                })
                .catch(error => {
                    console.log(error);
                })
        }
    }

    @api
    get expandAll() {
        return this.openDetails;
    }

    set expandAll(value) {
        this.openDetails = value;

    }

    connectedCallback() {
        registerListener('selectedId', this.expand, this);
    }


    expand(selectedId) {
        if (selectedId === this.contact.Id && this.openDetails === false)
            this.openDetails = true;
        else if (selectedId === this.contact.Id && this.openDetails === true){
            this.openDetails = false
        }
    }

    // support function

    sortData() {
        this.responseArray.sort((a, b) => {
          let d = new Date(b.CreatedDate);
          let c = new Date(a.CreatedDate);
          console.log(d - c);
          return d - c;
        });
        this.sortedArray = JSON.parse(JSON.stringify(this.responseArray));
      }
    
}