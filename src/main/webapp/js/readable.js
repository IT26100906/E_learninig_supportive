/* LearnHub - contrast guard (LIGHT mode only).
   Light mode paints dark liquid-glass panels, so any text that is still black / dark grey would be
   invisible. This script finds such text and turns it white. It re-runs when the page changes. */
(function () {
  var SKIP = '.btn-warning, .btn-light, .badge.text-bg-light, .badge.text-bg-warning, .alert, select, option, .stars, .avatar-chip, .page-link, ' +
             '.dropdown-menu, .modal-backdrop, input[type=file], .chip, .credit-card, .bg-white, .bg-light, .toast, .lh-toast';
  function lum(c) {
    var m = /rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)/.exec(c);
    if (!m) return 1;
    if (m[4] !== undefined && parseFloat(m[4]) === 0) return 1;
    return (0.2126 * m[1] + 0.7152 * m[2] + 0.0722 * m[3]) / 255;
  }
  function lightBg(el) {            // does this element (or a parent) have a solid light background?
    for (var n = el; n && n !== document.body; n = n.parentElement) {
      var m = /rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d.]+))?\)/.exec(getComputedStyle(n).backgroundColor);
      if (m && (m[4] === undefined || parseFloat(m[4]) > 0.8) && lum(getComputedStyle(n).backgroundColor) > 0.7) return true;
    }
    return false;
  }
  function run() {
    var root = document.documentElement;
    if (root.classList.contains('dark-pre') || !document.body.classList.contains('liquid')) return;
    var all = document.querySelectorAll('main *, .side-menu *, .modal *, .app-footer, .app-footer *');
    for (var i = 0; i < all.length; i++) {
      var el = all[i];
      if (el.closest(SKIP) || !el.childNodes.length) continue;
      var hasText = false;
      for (var k = 0; k < el.childNodes.length; k++) if (el.childNodes[k].nodeType === 3 && el.childNodes[k].nodeValue.trim()) { hasText = true; break; }
      if (!hasText) continue;
      var cs = getComputedStyle(el);
      if (lum(cs.color) < 0.45 && !lightBg(el)) el.style.setProperty('color', '#fff', 'important');
    }
  }
  var timer;
  function later() { clearTimeout(timer); timer = setTimeout(run, 60); }
  document.addEventListener('DOMContentLoaded', function () {
    run();
    new MutationObserver(later).observe(document.body, {childList: true, subtree: true});
    new MutationObserver(later).observe(document.documentElement, {attributes: true, attributeFilter: ['class']});
  });
})();
