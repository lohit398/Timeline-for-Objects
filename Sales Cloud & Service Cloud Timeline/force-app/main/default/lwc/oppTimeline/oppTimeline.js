import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener } from 'c/pubsub';

export default class OppTimeline extends LightningElement {
    @track openDetails = false;
    @wire(CurrentPageReference) pageRef;
    responseArray = [];
    sortedArray = [];
    selected;



    @api
    get items() {
        return this.responseArray;

    }

    set items(value) {
        //this.item = value;
        this.selected = value.stageChangeId;
        this.responseArray = this.responseArray.concat(value.feedItems);
        this.responseArray = this.responseArray.concat(value.oppProducts);
        this.sortData();

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
        console.log(this.selected);
        console.log(selectedId);
        if (selectedId === this.selected && this.openDetails === false)
            this.openDetails = true;
        else if (selectedId === this.selected && this.openDetails === true){
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