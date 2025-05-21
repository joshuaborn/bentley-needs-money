import { render, screen } from '@testing-library/react';
import { describe, it, expect, beforeEach, mock } from "bun:test";

import { debts } from '../fixtures/debts';
import MainPanel from '../../../app/javascript/components/MainPanel';

describe('MainPanel', () => {
    beforeEach(() => {
        render(<MainPanel debts={debts} setModeState={mock()} />);
    });

    it('renders mobile grid view', () => {
        // @ts-expect-error - Jest DOM matcher
        expect(document.querySelector('.debts .debts-content')).toBeInTheDocument();
    });

    it('renders tablet/desktop table view', () => {
        // @ts-expect-error - Jest DOM matcher
        expect(document.querySelector('.debts table.table')).toBeInTheDocument();
    });

    it('renders all the debts', () => {
        debts.forEach((debt) => {
            const elements = screen.getAllByText(debt.reason.payee);
            expect(elements.length).toBe(2);
        });
    });
});