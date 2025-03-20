// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "./vanilla.ts";
import { createElement, StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './components/App';
import type { Debt, Person } from './types';

interface DataForReact {
    "connected.people": Person[],
    "debts": Debt[],
    "flash": string[][]
}

document.addEventListener('turbo:load', () => {
    const domNode = document.getElementById('debts-index-app');
    if (domNode) {
        const root = createRoot(domNode);
        const dataForReactString = domNode.getAttribute('data-for-react');
        if (dataForReactString) {
            const dataForReact = JSON.parse(dataForReactString) as DataForReact;
            const connectedPeople = dataForReact['connected.people'];
            const debts = dataForReact.debts;
            root.render(
                createElement(
                    StrictMode,
                    {},
                    createElement(
                        App,
                        {
                            connectedPeople: connectedPeople,
                            initialDebts: debts,
                            initialFlash: dataForReact.flash
                        }
                    )
                )
            );
        } else {
            root.render(
                createElement(
                    StrictMode,
                    {},
                    createElement(App)
                )
            );
        }
    }
});
