/* Liquid glass helpers (runs on every page that uses body.liquid):
   1) turn on the SVG lens refraction in Chromium browsers
   2) the specular light on glass panels follows the mouse */
(function () {
  var ua = navigator.userAgent;
  var chromium = /Chrome|Chromium|Edg|OPR/.test(ua) && !/Firefox|FxiOS/.test(ua);
  if (!document.body.classList.contains('liquid')) return;
  if (chromium) document.documentElement.classList.add('lg-refract');

  var SEL = '.glass-card, .welcome-banner, .child-hero, .school-banner, .al-banner, .card, .glass-bar';
  document.querySelectorAll(SEL).forEach(function (el) {
    el.addEventListener('pointermove', function (e) {
      var r = el.getBoundingClientRect();
      el.style.setProperty('--mx', (e.clientX - r.left) + 'px');
      el.style.setProperty('--my', (e.clientY - r.top) + 'px');
    });
    el.addEventListener('pointerleave', function () {
      el.style.removeProperty('--mx'); el.style.removeProperty('--my');
    });
  });
})();
