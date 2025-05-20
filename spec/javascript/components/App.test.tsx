import { render } from '@testing-library/react';
import { describe, it, expect, beforeEach } from "bun:test";

import { mockAppProps } from '../fixtures/mockAppProps';
import App from '../../../app/javascript/components/App';

describe('App', () => {
    beforeEach(() => {
        render(<App {...mockAppProps} />);
    });

    it('renders', () => {
        // @ts-expect-error - Jest DOM matcher
        expect(document.querySelector('.inner-flex')).toBeInTheDocument();
    });

    // TODO: Move this to NewRepaymentCard.test.tsx.
    // it('passes a list of the most recent debt for each connected person to SidePanel as peopleOwed', () => {
    //     const actualPeopleOwed = mockSidePanel.mock.calls[0][0].peopleOwed;
    //     const johnSmithDebt = actualPeopleOwed.find((d: Debt) => d.person.id === johnSmith.id);
    //     const billyBobDebt = actualPeopleOwed.find((d: Debt) => d.person.id === billyBob.id);
    //     expect(johnSmithDebt).toEqual(debts[1]);
    //     expect(billyBobDebt).toEqual(debts[4]);
    //     expect(actualPeopleOwed.length).toBe(2);
    // });
});