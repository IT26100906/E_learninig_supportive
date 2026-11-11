document.addEventListener('DOMContentLoaded', function () {

  // Show / hide password
  document.querySelectorAll('.toggle-pw').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var input = btn.closest('.input-group, .gfield').querySelector('input');
      var show = input.type === 'password';
      input.type = show ? 'text' : 'password';
      btn.querySelector('i').className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
    });
  });

  // Password strength meter
  document.querySelectorAll('input[data-pw-meter]').forEach(function (input) {
    var group = input.closest('.mb-3');
    var bar = group.querySelector('.pw-bar');
    var text = group.querySelector('.pw-text');
    input.addEventListener('input', function () {
      var v = input.value, score = 0;
      if (v.length >= 6) score++;
      if (v.length >= 10) score++;
      if (/[A-Z]/.test(v) && /[a-z]/.test(v)) score++;
      if (/\d/.test(v)) score++;
      if (/[^A-Za-z0-9]/.test(v)) score++;
      var levels = [
        {w: 0,   c: 'bg-secondary', t: ''},
        {w: 25,  c: 'bg-danger',    t: 'Weak'},
        {w: 50,  c: 'bg-warning',   t: 'Fair'},
        {w: 75,  c: 'bg-info',      t: 'Good'},
        {w: 100, c: 'bg-success',   t: 'Strong'}
      ];
      var lvl = v.length === 0 ? levels[0] : levels[Math.min(4, Math.max(1, score - 1))];
      bar.style.width = lvl.w + '%';
      bar.className = 'progress-bar pw-bar ' + lvl.c;
      text.textContent = lvl.t ? 'Password strength: ' + lvl.t : '';
    });
  });

  // Confirm password must match
  document.querySelectorAll('form').forEach(function (form) {
    var pw = form.querySelector('input[data-pw-meter]');
    var cf = form.querySelector('input[name="confirmPassword"]');
    if (pw && cf) {
      var check = function () {
        cf.setCustomValidity(cf.value && cf.value !== pw.value ? 'Passwords do not match' : '');
      };
      pw.addEventListener('input', check);
      cf.addEventListener('input', check);
    }
  });

  // "Are you sure?" dialogs
  document.querySelectorAll('form[data-confirm]').forEach(function (f) {
    f.addEventListener('submit', function (e) {
      if (!confirm(f.getAttribute('data-confirm'))) e.preventDefault();
    });
  });

  // Date of birth cannot be in the future
  var today = new Date().toISOString().split('T')[0];
  document.querySelectorAll('input[type=date][data-past]').forEach(function (i) { i.max = today; });

  // Upload picture as soon as a file is chosen
  document.querySelectorAll('input[data-autosubmit]').forEach(function (i) {
    i.addEventListener('change', function () { if (i.files.length) i.form.submit(); });
  });

  // Level picker (Child / Grade 1-11 / A/L / Undergraduate): show only the matching detail field
  document.querySelectorAll('.level-grid').forEach(function (grid) {
    var form = grid.closest('form');
    var sync = function () {
      var sel = form.querySelector('input[name="level"]:checked');
      var v = sel ? sel.value : '';
      form.querySelectorAll('.level-detail').forEach(function (b) {
        var on = b.getAttribute('data-level') === v;
        b.hidden = !on;
        b.querySelectorAll('input,select').forEach(function (i) { i.disabled = !on; });
      });
    };
    grid.addEventListener('change', sync);
    sync();
  });

  // Success / info messages disappear after a few seconds
  setTimeout(function () {
    document.querySelectorAll('.alert-auto').forEach(function (a) {
      a.classList.remove('show');
      setTimeout(function () { a.remove(); }, 400);
    });
  }, 5000);
});


/* ---------- Dark / Light mode toggle (remembered in the browser) ---------- */
(function () {
  var KEY = 'lh-theme';
  var btn = document.getElementById('themeToggle');
  function apply(mode) {
    var dark = mode === 'dark';
    document.body.classList.toggle('dark', dark);
    document.documentElement.classList.toggle('dark-pre', dark);
    if (btn) btn.innerHTML = dark ? '<i class="bi bi-sun-fill"></i>' : '<i class="bi bi-moon-stars-fill"></i>';
  }
  var saved = 'light';
  try { saved = localStorage.getItem(KEY) || 'light'; } catch (e) {}
  apply(saved);
  if (btn) btn.addEventListener('click', function () {
    var next = document.body.classList.contains('dark') ? 'light' : 'dark';
    try { localStorage.setItem(KEY, next); } catch (e) {}
    apply(next);
  });
})();
