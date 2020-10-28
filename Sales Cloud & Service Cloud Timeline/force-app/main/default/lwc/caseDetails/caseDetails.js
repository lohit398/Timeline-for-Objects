import { LightningElement,api,track,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener } from 'c/pubsub';


export default class CaseDetails extends LightningElement {
    @wire (CurrentPageReference) pageRef;
    @track cases;
    @track openDetails = false;

    @api
    get caseDetails() {
        return this.cases;
    }

    set caseDetails(value) {
        this.cases = value;
    }

    @api
    get expandAll(){
        return this.openDetails;
    }

    set expandAll(value){
        this.openDetails = value;
    }

    connectedCallback(){
        registerListener('selectedId',this.expand,this);
    }

   
    expand(selectedId){
        if(selectedId === this.cases.Id && this.openDetails === false)
            this.openDetails = true;
        else if(selectedId === this.cases.Id && this.openDetails === true)
            this.openDetails = false;
    }



   
    
}