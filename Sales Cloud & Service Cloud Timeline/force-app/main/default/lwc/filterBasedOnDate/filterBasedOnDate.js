import { LightningElement,api } from 'lwc';

export default class FilterBasedOnDate extends LightningElement {
    // TODO: Handle filter values persistancy

    _selectedRange;
    responses = [];
    filteredData;


    @api
    get responseArray() {
        return this.responses;
    }
    set responseArray(value) {
        this.responses = value;
    }

    handleDateValues(event) {
        this._selectedRange = parseInt(event.target.value);
        //console.log(this._selectedRange);
    }

    handleDateFilter() {
        if (this._selectedRange != 0) {
            let difference = new Date();
            let dateRange = new Date(difference.setDate(difference.getDate() - this._selectedRange));
            this.filteredData = this.responses.filter(item => {
                let d = new Date(item.CreatedDate);
                return d >= dateRange;
            });
        }
        else {
            this.filteredData = JSON.parse(JSON.stringify(this.responses));
        }
        this.dispatchEvent(new CustomEvent("filtereddata", { detail: { filtered: this.filteredData, selected: this._selectedRange} }));
    }
}