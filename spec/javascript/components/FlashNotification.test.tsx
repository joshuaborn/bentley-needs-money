import { render, screen } from '@testing-library/react';
import { describe, it, expect } from "bun:test";

import FlashNotification from '../../../app/javascript/components/FlashNotification';

describe('FlashNotification', () => {
    it('renders the text', () => {
        const text = "This is a flash message.";
        render(
            <FlashNotification
                kind="info"
                message={text}
            />
        );
        // @ts-expect-error - Jest DOM matcher
        expect(screen.getByText(text)).toBeInTheDocument();
    });

    describe('when kind is "notice"', () => {
        it('uses the Bulma class name "is-info"', () => {
            render(
                <FlashNotification
                    kind="notice"
                    message="This is a flash message."
                />
            );
            // @ts-expect-error - Jest DOM matcher
            expect(document.querySelector('.notification.is-info')).toBeInTheDocument();
        });
    });

    describe('when kind is "alert"', () => {
        it('uses the Bulma class name "is-warning"', () => {
            render(
                <FlashNotification
                    kind="alert"
                    message="This is a flash message."
                />
            );
            // @ts-expect-error - Jest DOM matcher
            expect(document.querySelector('.notification.is-warning')).toBeInTheDocument();
        });
    });

    describe('when kind is "error"', () => {
        it('uses the Bulma class name "is-danger"', () => {
            render(
                <FlashNotification
                    kind="error"
                    message="This is a flash message."
                />
            );
            // @ts-expect-error - Jest DOM matcher
            expect(document.querySelector('.notification.is-danger')).toBeInTheDocument();
        });
    });
});