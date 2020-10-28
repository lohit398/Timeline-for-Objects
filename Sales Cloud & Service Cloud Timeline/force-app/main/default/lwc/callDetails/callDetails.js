import { LightningElement,api,track,wire } from 'lwc';
import{CurrentPageReference} from 'lightning/navigation';
import { registerListener } from 'c/pubsub';

export default class CallDetails extends LightningElement {
    @track call;
    @track openDetails = false;
    @wire (CurrentPageReference) pageRef;

  
    @api
   get callDetails() {
       //getting call details
       return this.call;
   }

   set callDetails(value) {
       this.call = value;
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
    if(selectedId === this.call.Id && this.openDetails === false)
        this.openDetails = true;
    else if(selectedId === this.call.Id && this.openDetails === true)
        this.openDetails = false;
    }  
}