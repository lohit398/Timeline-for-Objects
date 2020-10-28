import { LightningElement,track,wire,api } from 'lwc';
import{CurrentPageReference} from 'lightning/navigation';
import { registerListener } from 'c/pubsub';



export default class DisplayEmailDetails extends LightningElement {
    @track selectedRecordId;
    @api email;
    @track openDetails = false;
    @wire (CurrentPageReference) pageRef;


   

    
   @api
   get emailDetails(){
       return this.email;
   }

   set emailDetails(value){
       this.email = value;
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
    if(selectedId === this.email.Id && this.openDetails === false)
        this.openDetails = true;
    else if(selectedId === this.email.Id && this.openDetails === true)
        this.openDetails = false;
}

}