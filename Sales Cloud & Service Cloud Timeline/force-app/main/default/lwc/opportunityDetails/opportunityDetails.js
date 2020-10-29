import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener } from 'c/pubsub';

export default class OpportunityDetails extends LightningElement {
    @track opp;
    @track openDetails = false;
    @wire(CurrentPageReference) pageRef;


    @api
    get oppDetails() {
        return this.opp;
    }

    set oppDetails(value) {
        this.opp = value;
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
        if (selectedId === this.opp.Id && this.openDetails === false)
            this.openDetails = true;
        else if (selectedId === this.opp.Id && this.openDetails === true)
            this.openDetails = false;
    }
}