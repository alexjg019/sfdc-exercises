import { createElement } from 'lwc';
import LaunchModal from 'c/launchModal';
import ButtonLabelModal from 'c/buttonLabelModal';

// Mock the modal’s open method
jest.mock(
    'c/buttonLabelModal',
    () => {
        return {
            __esModule: true,
            default: {
                open: jest.fn()
            }
        };
    },
    { virtual: true }
);

describe('c-launch-modal', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders button with initial label "Please Click"', () => {
        const element = createElement('c-launch-modal', {
            is: LaunchModal
        });
        document.body.appendChild(element);

        const btn = element.shadowRoot.querySelector('lightning-button');
        expect(btn.label).toBe('Please Click');
    });

    it('opens modal when button clicked', async () => {
        ButtonLabelModal.open.mockResolvedValue(undefined);

        const element = createElement('c-launch-modal', {
            is: LaunchModal
        });
        document.body.appendChild(element);

        const btn = element.shadowRoot.querySelector('lightning-button');
        btn.click();

        await Promise.resolve();

        expect(ButtonLabelModal.open).toHaveBeenCalled();
    });

    it('updates button label when modal returns value', async () => {
        ButtonLabelModal.open.mockResolvedValue('Updated Label');

        const element = createElement('c-launch-modal', {
            is: LaunchModal
        });
        document.body.appendChild(element);

        const btn = element.shadowRoot.querySelector('lightning-button');
        btn.click();

        await Promise.resolve(); // wait for modal promise

        expect(btn.label).toBe('Updated Label');
    });
});
