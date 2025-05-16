import { render } from '@testing-library/react';
import { describe, it, expect, mock, beforeEach } from "bun:test";

import { johnSmith, billyBob } from '../fixtures/people';
import { debts } from '../fixtures/debts';
import { mockAppProps } from '../fixtures/mockAppProps';
import App from '../../../app/javascript/components/App';
import type { Debt } from '../../../app/javascript/types';

const mockSidePanel = mock();

await mock.module('../../../app/javascript/components/SidePanel', () => {
    return {
        default: mockSidePanel
    };
});

describe('App', () => {
    beforeEach(() => {
        mockSidePanel.mockClear();
        render(<App {...mockAppProps} />);
    });

    it('renders', () => {
        // @ts-expect-error - Jest DOM matcher
        expect(document.querySelector('.inner-flex')).toBeInTheDocument();
    });

    it('passes a list of the most recent debt for each connected person to SidePanel as peopleOwed', () => {
        const actualPeopleOwed = mockSidePanel.mock.calls[0][0].peopleOwed;
        const johnSmithDebt = actualPeopleOwed.find((d: Debt) => d.person.id === johnSmith.id);
        const billyBobDebt = actualPeopleOwed.find((d: Debt) => d.person.id === billyBob.id);
        expect(johnSmithDebt).toEqual(debts[1]);
        expect(billyBobDebt).toEqual(debts[4]);
        expect(actualPeopleOwed.length).toBe(2);
    });
});