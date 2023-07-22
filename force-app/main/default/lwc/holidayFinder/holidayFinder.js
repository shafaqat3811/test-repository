import { LightningElement } from 'lwc';
import getHolidays from '@salesforce/apex/HolidayController.getHolidays';
export default class HolidayFinder extends LightningElement {

    isDisabled = true;
    nationalId;
    holidays;
    error = false;
    loadHolidays = false;

    columns = [
        { label: 'Holiday Name', fieldName: 'name' },
        { label: 'Description', fieldName: 'description' },
        { label: 'Date', fieldName: 'date', type: 'date',typeAttributes:{
            weekday: "long",
            year: "numeric",
            month: "long",
            day: "2-digit"
        } },
        { label: 'Primary Type', fieldName: 'primary_type' },
    ];

    handleKeyUp(event) {
        
        if(event.target.value.length == 13){
            this.nationalId = event.target.value;
            if (this.validateIdInput()) {
                this.isDisabled = false;
                this.error = false;
            } else {
                this.isDisabled = true;
                this.error = true;
            }
        }else{
            this.isDisabled = true;
        }
    }

    handleClick(event) {
        
        this.isDisabled = true;
        getHolidays({ nationalId: this.nationalId })
            .then((result) => {
                this.holidays = result;
                this.loadHolidays = true;
            })
            .catch((error) => {
                this.isDisabled = true;
                this.error = true;
            });
    }

    validateIdInput() {
        var total = 0;
        var sum = 0;
        var multiplier = 1;
        console.log('id in sum ', this.nationalId);
        for (var i = 0; i < 13; ++i) {
            total = parseInt(this.nationalId.charAt(i)) * multiplier;
            if (total > 9) {
                total = parseInt(total.toString().charAt(0)) + parseInt(total.toString().charAt(1));
            }
            sum = sum + total;
            multiplier = (multiplier % 2 == 0) ? 1 : 2;
        }
        return (sum % 10) == 0;
    }
}