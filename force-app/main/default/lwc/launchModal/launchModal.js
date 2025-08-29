import { LightningElement } from 'lwc';
import ButtonLabelModal from 'c/buttonLabelModal';

export default class LaunchModal extends LightningElement {
    buttonLabel = 'Please Click'

    async handleClick(){
        const result = await ButtonLabelModal.open({
                size: 'small',
                description: 'LWC Button Label Change Modal: The button opens a modal where text can be entered that changes the label of the initial button clicked.',
                initialLabel: this.buttonLabel,
            });
        
        if(result !== undefined){
            this.buttonLabel = result;
        }
    }
}
