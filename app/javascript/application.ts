// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "./vanilla.ts";
import { createElement } from 'react';
import { createRoot } from 'react-dom/client';
import TransfersIndex from './components/TransfersIndex';
import type { Person, Transfer } from './types';

interface DataForReact {
    "connected.people": Person[],
    "person.transfers": Transfer[],
    "flash": string[][]
}

document.addEventListener('turbo:load', () => {
    const domNode = document.getElementById('transfers-index-app');
    if (domNode) {
        const root = createRoot(domNode);
        const dataForReactString = domNode.getAttribute('data-for-react');
        if (dataForReactString) {
            const dataForReact = JSON.parse(dataForReactString) as DataForReact;
            const connectedPeople = dataForReact['connected.people'];
            const personTransfers = dataForReact['person.transfers'];
            root.render(createElement(TransfersIndex, {
                connectedPeople: connectedPeople,
                initialPersonTransfers: personTransfers,
                flash: dataForReact.flash
            }));
        } else {
            root.render(createElement(TransfersIndex));
        }
    }
});
