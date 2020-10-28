import { LightningElement,api,track,wire } from 'lwc';
import{CurrentPageReference} from 'lightning/navigation';
import { registerListener } from 'c/pubsub';

export default class DisplayChatLogs extends LightningElement {
  
    @track chat;
    @track openDetails = false;
    @wire (CurrentPageReference) pageRef;

    @api
    get chatDetails() {
        return this.chat;
    }
    
    set chatDetails(value) {
        this.chat = value;
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
        if(selectedId === this.chat.Id && this.openDetails === false)
            this.openDetails = true;
        else if(selectedId === this.chat.Id && this.openDetails === true)
            this.openDetails = false;
    }


}