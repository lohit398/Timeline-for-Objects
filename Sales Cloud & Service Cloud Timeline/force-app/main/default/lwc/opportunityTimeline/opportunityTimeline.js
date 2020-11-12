import { LightningElement,api,wire } from 'lwc';
import getOppotunitiesData from '@salesforce/apex/CustomerInteractionTimeline_helper.getOppotunitiesData';

export default class OpportunityTimeline extends LightningElement {

    @api recordId;
    oppData={};

    @wire(getOppotunitiesData, {recordId: '$recordId'})
    opportuntyDetails({error,data}){
        if(data){
            this.oppData = data;
            console.log(this.oppData);
        }
        else if(error){
            console.log(error);
        }
    }
}