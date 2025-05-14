import { render, screen } from '@testing-library/react';
import { describe, it, expect } from "@jest/globals";

import Currency from '../../../app/javascript/components/Currency';

describe('Currency', () => {
    describe('with a positive value', () => {
        it('displays a value of a dollar or more with a dollar sign and a decimal point', () => {
            render(<Currency cents={100} />);
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('$1.00')).toBeInTheDocument();
        });

        it('displays a value less than 100 cents with a dollar sign, a decimal point, and a leading zero', () => {
            render(<Currency cents={50} />);
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('$0.50')).toBeInTheDocument();
        });

        it('displays a value of 1,000 dollars or more with comma(s), a dollar sign, and a decimal point', () => {
            render(<Currency cents={100000} />);
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('$1,000.00')).toBeInTheDocument();
        });
    });

    describe('with a negative value', () => {
        it('display a value of a dollar or more with a dollar sign and a decimal point', () => {
            render(<Currency cents={-100} />);
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('-$1.00')).toBeInTheDocument();
        });

        it('displays a value less than 100 cents with a dollar sign, a decimal point, and a leading zero', () => {
            render(<Currency cents={-50} />);
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('-$0.50')).toBeInTheDocument();
        });

        it('displays a value of 1,000 dollars or more with comma(s), a dollar sign, and a decimal point', () => {
            render(<Currency cents={-100000} />);
            // @ts-expect-error - Jest DOM matcher
            expect(screen.getByText('-$1,000.00')).toBeInTheDocument();
        });
    });
})