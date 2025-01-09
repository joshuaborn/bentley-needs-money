// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "./vanilla.ts";
import { createElement } from 'react';
import { createRoot } from 'react-dom/client';
import TransfersIndex from './components/TransfersIndex.tsx';

document.addEventListener('turbo:load', () => {
    const domNode = document.getElementById('transfers-index-app');

    if (domNode) {
        const root = createRoot(domNode);
        root.render(createElement(TransfersIndex));
    }
});
