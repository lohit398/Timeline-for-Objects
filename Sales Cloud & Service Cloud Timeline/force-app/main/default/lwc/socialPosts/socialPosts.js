import { LightningElement,wire,track,api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener } from 'c/pubsub';

export default class SocialPosts extends LightningElement {
    @wire (CurrentPageReference) pageRef;
    @track posts;
    @track openDetails = false;

    @api
    get postDetails() {
        return this.posts;
    }

    set postDetails(value) {
        this.posts = value;
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
        if(selectedId === this.posts.Id && this.openDetails === false)
            this.openDetails = true;
        else if(selectedId === this.posts.Id && this.openDetails === true)
            this.openDetails = false;
    }
}