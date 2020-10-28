import { LightningElement, wire, api, track } from 'lwc';
import GET_RELATED_RECORDS from '@salesforce/apex/CaseRelatedRecords.getRelatedRecords';
import { CurrentPageReference } from "lightning/navigation";
import { registerListener } from 'c/pubsub';

export default class CaseView extends LightningElement {
    @api recordId;
    @track responseArray = [];
    @track sortedArray = [];
    @track relatedLists = [];
    @track itemId = "";
    @track expandList = false;

    @api
    get relatedValues() {
        return this.relatedLists;
    }

    set relatedValues(value) {
        this.itemId = value.Id;
        this.relatedLists = this.relatedLists.concat(value.chatsList);
        this.relatedLists = this.relatedLists.concat(value.callTasks);
        this.relatedLists = this.relatedLists.concat(value.emailMessages);
        this.relatedLists = this.relatedLists.concat(value.messagingList);
        this.relatedLists = this.relatedLists.concat(value.socialPosts);
        
        this.relatedLists.sort((a, b) => {
            let d =
                b.CreatedDate != undefined
                    ? new Date(b.CreatedDate)
                    : new Date(b.messagingSession.CreatedDate);
            let c =
                a.CreatedDate != undefined
                    ? new Date(a.CreatedDate)
                    : new Date(a.messagingSession.CreatedDate);
            return d - c;
        });

        this.sortedArray = this.relatedLists;
    }


    @wire(CurrentPageReference) pageRef;
    @wire(GET_RELATED_RECORDS, { recId: '$recordId' })
    sortData({ error, data }) {
        if (data) {
            JSON.parse(JSON.stringify(data)).map((item) => {
                let obj = item.c;
                obj.chatsList = item.chatsList;
                obj.callTasks = item.callTasks;
                obj.emailMessages = item.emailMessages;
                obj.messagingList = item.messagingList;
                obj.socialPosts = item.socialPosts;
                this.responseArray.push(obj);
            });

            this.responseArray.sort((a, b) => {
                if (JSON.stringify(b) != "{}" && JSON.stringify(a) != "{}")
                    return new Date(b.CreatedDate) - new Date(a.CreatedDate);
            });
            this.responseArray[this.responseArray.length - 1].Id = "No_case_attached";
            this.sortedArray = JSON.parse(JSON.stringify(this.responseArray));

        }
    }

    connectedCallback() {
        registerListener('selectedId', this.expand, this);
    }
    expand(selectedId) {
        if (selectedId === this.itemId && this.expandList === false)
            this.expandList = true;
        else if (selectedId === this.itemId && this.expandList === true)
            this.expandList = false;
    }

}