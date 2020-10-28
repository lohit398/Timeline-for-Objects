import { LightningElement,api,track,wire } from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import { registerListener } from 'c/pubsub';



export default class MessagingSessionDetails extends LightningElement {
    @track session;
    @track openDetails = false;
    @wire (CurrentPageReference) pageRef;

  
       @api
       get sessionDetails() {
           return this.session;
       }

       set sessionDetails(value) {
            this.session = value;
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
          if(selectedId === this.session.messagingSession.Id && this.openDetails === false) {
            this.openDetails = true; 
          }
          else if(selectedId === this.session.messagingSession.Id && this.openDetails === true)
              this.openDetails = false;
              
      }
      

 
}