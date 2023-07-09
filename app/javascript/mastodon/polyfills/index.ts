// Convenience function to load polyfills and return a promise when it's done.
// If there are no polyfills, then this is just Promise.resolve() which means
// it will execute in the same tick of the event loop (i.e. near-instant).

import { loadIntlPolyfills } from './intl';

function importBasePolyfills() {
  return import(/* webpackChunkName: "base_polyfills" */ './base_polyfills');
}

function importExtraPolyfills() {
  return import(/* webpackChunkName: "extra_polyfills" */ './extra_polyfills');
}

export function loadPolyfills() {
  const needsBasePolyfills = !(
    'toBlob' in HTMLCanvasElement.prototype &&
    'assign' in Object &&
    'values' in Object &&
    'Symbol' in window &&
    'finally' in Promise.prototype
  );

  // Latest version of Firefox and Safari do not have IntersectionObserver.
  // Edge does not have requestIdleCallback.
  // This avoids shipping them all the polyfills.
  const needsExtraPolyfills = !(
    window.AbortController &&
    window.IntersectionObserver &&
    window.IntersectionObserverEntry &&
    'isIntersecting' in IntersectionObserverEntry.prototype &&
    window.requestIdleCallback
  );

  return Promise.all([
    loadIntlPolyfills(),
    needsBasePolyfills && importBasePolyfills(),
    needsExtraPolyfills && importExtraPolyfills(),
  ]);
}
