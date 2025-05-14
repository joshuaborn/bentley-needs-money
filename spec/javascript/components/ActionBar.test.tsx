import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, jest, expect } from "@jest/globals";

import ActionBar from '../../../app/javascript/components/ActionBar';

describe('ActionBar', () => {
    it('renders', () => {
        const handleSetModeState = jest.fn();
        render(
            <ActionBar
                modeState={{ mode: 'idle' }}
                setModeState={handleSetModeState}
            />
        );
        // @ts-expect-error - Jest DOM matcher
        expect(screen.getByText('New Split')).toBeInTheDocument();
        // @ts-expect-error - Jest DOM matcher
        expect(screen.getByText('New Repayment')).toBeInTheDocument();
    });

    it('sets state to "new split" when New Split is clicked', () => {
        const handleSetModeState = jest.fn();
        render(
            <ActionBar
                modeState={{ mode: 'idle' }}
                setModeState={handleSetModeState}
            />
        );
        const newSplitButton = screen.getByRole('button', { name: /new split/i });
        fireEvent.click(newSplitButton);
        expect(handleSetModeState).toHaveBeenCalledWith({ mode: 'new split' });
    });

    it('sets state to "new repayment" when New Repayment is clicked', () => {
        const handleSetModeState = jest.fn();
        render(
            <ActionBar
                modeState={{ mode: 'idle' }}
                setModeState={handleSetModeState}
            />
        );
        const newSplitButton = screen.getByRole('button', { name: /new repayment/i });
        fireEvent.click(newSplitButton);
        expect(handleSetModeState).toHaveBeenCalledWith({ mode: 'new repayment' });
    });

    describe('with mode of "new split"', () => {
        it('disables the New Split button', () => {
            const handleSetModeState = jest.fn();
            render(
                <ActionBar
                    modeState={{ mode: 'new split' }}
                    setModeState={handleSetModeState}
                />
            );
            const newSplitButton = screen.getByRole('button', { name: /new split/i });
            // @ts-expect-error - Jest DOM matcher
            expect(newSplitButton).toBeDisabled();
        });
    });

    describe('with mode of "new repayment"', () => {
        it('disables the New Repayment button', () => {
            const handleSetModeState = jest.fn();
            render(
                <ActionBar
                    modeState={{ mode: 'new repayment' }}
                    setModeState={handleSetModeState}
                />
            );
            const newSplitButton = screen.getByRole('button', { name: /new repayment/i });
            // @ts-expect-error - Jest DOM matcher
            expect(newSplitButton).toBeDisabled();
        });
    });
})