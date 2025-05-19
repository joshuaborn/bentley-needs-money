import { render, screen } from '@testing-library/react';
import { describe, it, expect, mock } from "bun:test";

import { debts } from '../fixtures/debts';
import SidePanel from '../../../app/javascript/components/SidePanel';
import type { ModeState } from '../../../app/javascript/types';

const renderComponent = (modeState: ModeState, flashMessages = []) => {
    render(<SidePanel
        connectedPeople={[]}
        debts={debts}
        flashState={{
            counter: flashMessages.length,
            messages: flashMessages
        }}
        modeState={modeState}
        peopleOwed={[debts[1], debts[4]]}
        setDebtsState={mock()}
        setFlashState={mock()}
        setModeState={mock()}
    />);
};

describe('SidePanel', () => {
    it('renders itself', () => {
        renderComponent({ mode: 'idle' });
        // @ts-expect-error - Jest DOM matcher
        expect(document.querySelector('.side-panel')).toBeInTheDocument();
    });

    describe("with flash messages", () => {
        it('renders the flash messages', () => {
            const messages = [
                ["notice", "This is the first flash message."],
                ["error", "This is the second flash message."],
                ["warning", "This is the third flash message."]
            ];
            renderComponent({ mode: 'idle' }, messages);
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText(messages[0][1])).toBeInTheDocument();
        });
    });

    describe('when the mode is "new split"', () => {
        it('renders a NewSplitCard component', () => {
            renderComponent({ mode: 'new split' });
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('New Split')).toBeInTheDocument();
        });
    });

    describe('when the mode is "create split"', () => {
        it('renders a NewSplitCard component', () => {
            renderComponent({ mode: 'create split' });
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('New Split')).toBeInTheDocument();
        });
    });

    describe('when the mode is "new repayment"', () => {
        it('renders a NewRepaymentCard component', () => {
            renderComponent({ mode: 'new repayment' });
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('New Repayment')).toBeInTheDocument();
        });
    });

    describe('when the mode is "create repayment"', () => {
        it('renders a NewRepaymentCard component', () => {
            renderComponent({ mode: 'create repayment' });
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('New Repayment')).toBeInTheDocument();
        });
    });

    describe('when the mode is "edit split"', () => {
        it('renders an EditSplitCard component', () => {
            renderComponent({ mode: 'edit split', splitId: debts[1].id });
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('Edit Split')).toBeInTheDocument();
        });
    });

    describe('when the mode is "update split"', () => {
        it('renders an EditSplitCard component', () => {
            renderComponent({ mode: 'update split', splitId: debts[1].id });
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('Edit Split')).toBeInTheDocument();
        });
    });

    describe('when the mode is "edit repayment"', () => {
        it('renders an EditRepaymentCard component', () => {
            renderComponent({ mode: 'edit repayment', repaymentId: debts[1].id });
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('Edit Repayment')).toBeInTheDocument();
        });
    });

    describe('when the mode is "update repayment"', () => {
        it('renders an EditRepaymentCard component', () => {
            renderComponent({ mode: 'update repayment', repaymentId: debts[1].id });
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('Edit Repayment')).toBeInTheDocument();
        });
    });
});