// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "./vanilla.ts";
import { createElement } from 'react';
import { createRoot } from 'react-dom/client';
import TransfersIndex from './components/TransfersIndex';
import type { Person } from './types';

interface DataForReact {
    "connected.people": Person[]
}

document.addEventListener('turbo:load', () => {
    const domNode = document.getElementById('transfers-index-app');
    if (domNode) {
        const root = createRoot(domNode);
        const dataForReactString = domNode.getAttribute('data-for-react');
        if (dataForReactString) {
            const dataForReact = JSON.parse(dataForReactString) as DataForReact;
            const connectedPeople = dataForReact['connected.people'];
            root.render(createElement(TransfersIndex, {connectedPeople: connectedPeople}));
        } else {
            root.render(createElement(TransfersIndex));
        }
    }
});
