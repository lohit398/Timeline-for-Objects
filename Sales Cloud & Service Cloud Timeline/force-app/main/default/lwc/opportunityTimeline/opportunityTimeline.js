import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/pubsub";
import { NavigationMixin } from "lightning/navigation";
import getOppotunitiesData from '@salesforce/apex/CustomerInteractionTimeline_helper.getOppotunitiesData';

export default class OpportunityTimeline extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;

    @api recordId;
    sortedArray = [];
    openAll = false;

    @wire(getOppotunitiesData, { recordId: '$recordId' })
    opportuntyDetails({ error, data }) {
        if (data) {
            this.sortedArray = this.getItems(data);
        }
        else if (error) {
            console.log(error);
        }
    }


    getDetails(event) {
        this.selectedId = event.currentTarget.dataset.targetid;
    
        if (this.template.querySelector('[data-targetid="' + this.selectedId + '"]').querySelector('[data-icontype="chevron"]').iconName === "utility:chevronright")
          this.template.querySelector('[data-targetid="' + this.selectedId + '"]').querySelector('[data-icontype="chevron"]').iconName = "utility:chevrondown";
        else
          this.template.querySelector('[data-targetid="' + this.selectedId + '"]').querySelector('[data-icontype="chevron"]').iconName = "utility:chevronright"
    
    
        fireEvent(this.pageRef, "selectedId", this.selectedId);
      }
    
      handleExpandAllAndCollapseAll(event) {
        if (event.target.dataset.action === "expandall") this.openAll = true;
        else {
          this.openAll = false;
        }
      }
    
      handleRedirect(event) {
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: event.target.dataset.recid,
            actionName: "view"
          }
        });
      }

      handleExpandAllAndCollapseAll(event) {
        if (event.target.dataset.action === "expandall") this.openAll = true;
        else {
          this.openAll = false;
        }
      }

    //supporting function

    getItems(data) {
        let items = [];
        for (let i = 0; i < data.stageChange.length; i++) {
            let currentDate = new Date(data.stageChange[i].Change_Date_and_Time__c);
            let pervDate;

            if (i - 1 != -1)
                pervDate = new Date(data.stageChange[i - 1].Change_Date_and_Time__c);
            else
                pervDate = null;

            let obj = {};
            obj.currentStage = data.stageChange[i].Current_Stage__c;
            obj.currentDate = currentDate;
            obj.previousStage = data.stageChange[i].Previous_Stage__c;
            obj.stageChangeId = data.stageChange[i].Id;
            obj.feedItems = [];
            for (let j = 0; j < data.feedItems.length; j++) {
                if (new Date(data.feedItems[j].CreatedDate) > pervDate && new Date(data.feedItems[j].CreatedDate) < currentDate) {
                    obj.feedItems.push(data.feedItems[j]);
                }
            }
            obj.oppProducts = [];
            for (let k = 0; k < data.oppProducts.length; k++) {
                if (new Date(data.oppProducts[k].CreatedDate) > pervDate && new Date(data.oppProducts[k].CreatedDate) < currentDate) {
                    obj.oppProducts.push(data.oppProducts[k]);
                }
            }
            items.push(obj);

        }
        return items;
    }
}