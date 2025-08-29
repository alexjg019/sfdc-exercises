import LightningModal from 'lightning/modal';

export default class ButtonLabelModal extends LightningModal {
    textValue;

    get isSaveDisabled() {
        return !this.textValue || this.textValue.trim() === '';
    }

    handleInputChange(event) {
        this.textValue = event.detail.value;
    }
    
    handleSave() {    
        this.close(this.textValue);
    }
}