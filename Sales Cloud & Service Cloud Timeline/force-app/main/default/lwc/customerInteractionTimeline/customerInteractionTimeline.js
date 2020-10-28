import { LightningElement, api, track, wire } from "lwc";
import getRecords from "@salesforce/apex/GetMultiObjectRecord.getRecords";
import { CurrentPageReference } from "lightning/navigation";

import { fireEvent } from "c/pubsub";
import { NavigationMixin } from "lightning/navigation";

export default class MultiObjectViewAndMultiChannelView extends NavigationMixin(
  LightningElement
) {
  @wire(CurrentPageReference) pageRef;
  @api recordId;
  @track openAll = false;
  @track selectedId = "";
  @track sortedArray = [];
  @track openFilter = false;
  @track responseArray = [];
  @track dateArray = [];
  _selectedRadioButton;
  _selectedFilter = true;
  _initial = true;
  _selectedTypes = []; 
  
  @track _callFromCaseViewComponent = false;
  @track caseView = false;
  @track relatedLists = [];

  @api
  get valuesArray() {
    return this.sortedArray;
  }

  set valuesArray(value) {
    if(JSON.stringify(value) != "[]"){
      this.sortedArray = value;
      
    }
    this._callFromCaseViewComponent = true;
  }

  connectedCallback() {
    if (!this._callFromCaseViewComponent) {
      getRecords({
        recId: this.recordId
      }).then((response) => {
        this.responseArray = this.responseArray.concat(response.caseList);
        this.responseArray = this.responseArray.concat(response.chatsList);
        this.responseArray = this.responseArray.concat(response.emailMessages);
        this.responseArray = this.responseArray.concat(response.callTasks);
        this.responseArray = this.responseArray.concat(response.messaging);
        this.responseArray = this.responseArray.concat(response.socialPosts);

        this.responseArray.sort((a, b) => {
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
        
        this.sortedArray = JSON.parse(JSON.stringify(this.responseArray));
      });
    }

  }

  renderedCallback(){
    if(this._initial && !this._callFromCaseViewComponent){
      this.template.querySelector('.slds-scrollable').classList.add('parent-header');
      this._initial = false;
    }  
  }

  getDetails(event) {
    this.selectedId = event.currentTarget.dataset.targetid;

    if(this.template.querySelector('[data-targetid="'+this.selectedId+'"]').querySelector('[data-icontype="chevron"]').iconName === "utility:chevronright")
      this.template.querySelector('[data-targetid="'+this.selectedId+'"]').querySelector('[data-icontype="chevron"]').iconName  =  "utility:chevrondown";
    else
      this.template.querySelector('[data-targetid="'+this.selectedId+'"]').querySelector('[data-icontype="chevron"]').iconName = "utility:chevronright"
    
    
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
  showFilterPanel(event) {
    if (this.openFilter === false) {
      this.template.querySelector('[data-elementtype="buttonicon"]').variant =
        "inverse";

      this.template.querySelector(
        '[data-elementtype="buttonicon"]'
      ).style.background = "rgb(28, 81, 151)";

      this.openFilter = true;
    } else {
      this.template.querySelector('[data-elementtype="buttonicon"]').variant =
        "";
      this.template.querySelector(
        '[data-elementtype="buttonicon"]'
      ).style.background = "white";

      this.openFilter = false;
    }
  }

  showCaseView(event) {
    if(this.caseView === false)
      this.caseView = true;
    else if(this.caseView === true)
      this.caseView = false;
  }

  handleFilterData(event) {
    this.sortedArray = event.detail.filtered;
    this._selectedFilter = event.detail.selected;
    this._selectedTypes = event.detail.types;
  }

  handleRadioButton(event) {
    this._selectedRadioButton = event.detail;
  }

  handleSearch(event){
    //console.log(event.target.value);
      if(event.target.value != ""){
        this.sortedArray = this.responseArray.filter(item => {
          if(item.CaseNumber)
            if(item.CaseNumber.includes(event.target.value))
              return true;
          if(item.Subject)
            if(item.Subject.includes(event.target.value))
              return true;
          if(item.messagingSession)
            if(item.messagingSession.Name.includes(event.target.value))
              return true;
          if(item.Name)
            if(item.Name.includes(event.target.value))
              return true;
          if(item.Content)
            if(item.Content.includes(event.target.value))
              return true;
        })
      }
    else
      this.sortedArray = this.responseArray;
   
  }

}