import { expect as bunExpect } from 'bun:test';
import * as matchers from '@testing-library/jest-dom/matchers';

// Create a new expect object with the extended matchers
const customExpect = Object.assign(bunExpect, matchers);

// Export it for use in tests
export { customExpect as expect };