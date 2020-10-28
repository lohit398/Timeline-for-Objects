import { LightningElement, api, track } from 'lwc';

export default class FilterRecords extends LightningElement {

    responses = [];
    filteredData = [];
    _checkRenderedCallback = true;
    _checkRenderedCallback_filters_all_types = true;
    _types = [];
    __initialFilterLoad = true;
    _selectedRange;
    objectData = [];
    

    @api
    get responseArray() {
        return this.responses;
    }
    set responseArray(value) {
        this.responses = value;
    }

    @api
    get selectedValue() {
        return this._selectedRange;
    }

    set selectedValue(value) {
        this._selectedRange = value;
    }

    @api
    get selectedRadioButton(){
       return this.__initialFilterLoad;
    }

    set selectedRadioButton(value) {
        if (value != null || value != undefined)
            this.__initialFilterLoad = value;
    }
    @api
    get selectedType() {
        return this._types;
    }
    set selectedType(value) {
        this._types = JSON.parse(JSON.stringify(value));
    }


    handleDateValues(event) {
        this._selectedRange = parseInt(event.target.value);
    }

    renderedCallback() {
        if (this.template.querySelector('[data-filtervalue="' + this._selectedRange + '"]') != null && this._checkRenderedCallback === true && !this.__initialFilterLoad) {
            this.template.querySelector('[data-filtervalue="' + this._selectedRange + '"]').checked = "checked";
            this._checkRenderedCallback = false;
        }
        else if(this.__initialFilterLoad && this.template.querySelector('[data-filtervalue="0"]') && this.template.querySelector('[data-filtervalue="allTypes"]') != null ){
            this._selectedRange = 0; 
            this._types.push("allTypes");
            this.template.querySelector('[data-filtervalue="0"]').checked = true;
            this.template.querySelector('[data-filtervalue="allTypes"]').checked = true;
            this.__initialFilterLoad = false;
            this.dispatchEvent(new CustomEvent("sendradiobutton", {detail:  this.__initialFilterLoad}));
        } 

        if(!this.__initialFilterLoad && this._types.length != 0 && this._types != undefined && this._checkRenderedCallback_filters_all_types === true){
            this._types.map(item => {
                this.template.querySelector('[data-filtervalue="'+item+'"]').checked = true;
                
            })
            this._checkRenderedCallback_filters_all_types = false;
        }
        
    }

    handleDateFilter(event) {
        if (this._selectedRange != 0) {
            let difference = new Date();
            let dateRange = new Date(difference.setDate(difference.getDate() - this._selectedRange));
            this.filteredData = this.responses.filter(item => {
                let d = item.CreatedDate != undefined ? new Date(item.CreatedDate) : new Date(item.messagingSession.CreatedDate);
                return d >= dateRange;
            });
        }
        else {
            this.filteredData = JSON.parse(JSON.stringify(this.responses));
        }
        
        if( this._types.length != 0 && !this._types.includes('allTypes')){
                    this.filteredData = this.filteredData.filter(item => {
                        console.log(item);
                        if(this._types.includes('calls') &&  item.Type === 'Call') {
                            return true;
                        }
                        else if(this._types.includes('emails') && item.Priority) {
                            return true;
                        }
                        else if(this._types.includes('cases') && item.CaseNumber) {
                            return true;
                        }
                        else if(this._types.includes('messaging') && item.messagingSession) {
                            return true;
                        }
                        else if(this._types.includes('chats') && item.Body) {
                            return true;
                        }
                        else if(this._types.includes('posts') && item.Content){
                            return true;
                        }
                    });   
        }
        this.dispatchEvent(new CustomEvent("filtereddata", { detail: { filtered: this.filteredData, selected: this._selectedRange, types: this._types } }));
    }
 
    getObjectTypes(event){
        console.log(event);
        if(event.target.checked){
            this._types.push(event.target.name);
        }
        else{
            this._types = this._types.filter((item,index) => {
                if(item === event.target.name)
                    return false;
                else
                    return true;
            })
        }   
    }

}