import { createElement } from 'lwc';
import ButtonLabelModal from 'c/buttonLabelModal';

describe('c-button-label-modal', () => {
    let modal;

    beforeEach(() => {
        modal = createElement('c-button-label-modal', {
            is: ButtonLabelModal
        });
        document.body.appendChild(modal);
    });

    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('should render the component', () => {
        const modalElement = modal.shadowRoot.querySelector('lightning-modal');
        const inputElement = modal.shadowRoot.querySelector('lightning-input');
        const saveButton = modal.shadowRoot.querySelector('lightning-button');

        expect(modalElement).not.toBeNull();
        expect(inputElement).not.toBeNull();
        expect(saveButton).not.toBeNull();
        expect(saveButton.disabled).toBe(true);
    });

    it('should enable the save button when input is provided', () => {
        const inputElement = modal.shadowRoot.querySelector('lightning-input');
        const saveButton = modal.shadowRoot.querySelector('lightning-button');

        inputElement.value = 'New Label';
        inputElement.dispatchEvent(new CustomEvent('change', { detail: { value: 'New Label' } }));

        return Promise.resolve().then(() => {
            expect(saveButton.disabled).toBe(false);
        });
    });

    it('should disable the save button when input is empty', () => {
        const inputElement = modal.shadowRoot.querySelector('lightning-input');
        const saveButton = modal.shadowRoot.querySelector('lightning-button');

        inputElement.value = '';
        inputElement.dispatchEvent(new CustomEvent('change', { detail: { value: '' } }));

        return Promise.resolve().then(() => {
            expect(saveButton.disabled).toBe(true);
        });
    });

    it('should close the modal with the input value when save is clicked', () => {
        const inputElement = modal.shadowRoot.querySelector('lightning-input');
        const saveButton = modal.shadowRoot.querySelector('lightning-button');
        const closeModalMock = jest.fn();

        modal.close = closeModalMock;

        inputElement.value = 'New Label';
        inputElement.dispatchEvent(new CustomEvent('change', { detail: { value: 'New Label' } }));

        return Promise.resolve().then(() => {
            saveButton.click();

            return Promise.resolve().then(() => {
                expect(closeModalMock).toHaveBeenCalledWith('New Label');
            });
        });
    });
});