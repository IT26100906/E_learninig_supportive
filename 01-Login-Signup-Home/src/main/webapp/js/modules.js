/* Shared helpers for the Feedback / Notes / Enrollment / Assignment / Payment pages (UI demo data). */
window.LH = (function () {
  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c];
    });
  }
  /* ---------- data storage: saved in the DATABASE (table app_data) through /store ----------
     /js/store.js (loaded before this file) puts the logged-in user's saved data into window.LH_STORE:
       u = private values of this user, s = values shared by everybody (SHARED list below).
     load() reads from it, save() updates it and sends the value to the server. */
  var SHARED = {'courses-overlay': 1, 'reviews': 1, 'adm-enr': 1, 'adm-pay': 1, 'adm-seen': 1, 'adm-asg': 1};
  var STORE = window.LH_STORE || {ctx: '', u: {}, s: {}};
  STORE.u = STORE.u || {}; STORE.s = STORE.s || {};
  function bucket(key) { return SHARED[key] ? STORE.s : STORE.u; }
  /* data an older version kept in this browser (localStorage) is moved into the database the first time */
  function legacy(key) {
    try {
      var el = document.getElementById('meData'), id = el && el.dataset.id ? el.dataset.id : 'guest';
      return localStorage.getItem(key === 'courses-overlay' ? 'lh-courses-overlay' : 'lh-demo-' + id + '-' + key);
    } catch (e) { return null; }
  }
  function load(key, fallback) {
    var raw = bucket(key)[key];
    var fromLegacy = false;
    if (raw == null) { raw = legacy(key); fromLegacy = raw != null; }
    if (raw != null) {
      try {
        var v = JSON.parse(raw);
        if (fromLegacy) save(key, v);
        return v;
      } catch (e) { /* damaged value: use the sample data */ }
    }
    return JSON.parse(JSON.stringify(fallback));
  }
  var queue = Promise.resolve(), warned = false;
  function send(params) {
    queue = queue.then(function () {
      return fetch((STORE.ctx || '') + '/store', {method: 'POST', credentials: 'same-origin', keepalive: true,
          headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'}, body: new URLSearchParams(params).toString()})
        .then(function (r) {
          if (r.ok) return;
          return r.text().then(function (t) {
            var msg = 'save failed (' + r.status + ')'; try { msg = JSON.parse(t).error || msg; } catch (e) { /* not JSON */ }
            if (r.status === 403) { console.warn('LH store: not allowed to write this value - ' + msg); return; }
            throw new Error(r.status === 401 ? 'Your session expired - please log in again, then repeat the change.' : msg);
          });
        })
        .catch(function (err) {
          console.error('LH store:', err);
          if (!warned) { warned = true; toast('Could not save to the database: ' + (err && err.message ? err.message : 'check the connection / log in again.'), 'err'); setTimeout(function () { warned = false; }, 8000); }
        });
    });
  }
  function save(key, value) {
    var text = JSON.stringify(value);
    bucket(key)[key] = text;
    send({key: key, value: text});
  }
  /* removes one saved value (a student withdrawing a submission, for example) */
  function remove(key) {
    delete bucket(key)[key];
    send({action: 'delete', key: key});
  }
  /* removes the data of the logged-in user from the database (private keys only) */
  function resetAll() {
    STORE.u = {};
    send({action: 'reset'});
  }
  function stars(n) {
    var r = Math.round(n), out = '<span class="stars" aria-label="' + n + ' out of 5">';
    for (var i = 1; i <= 5; i++) out += i <= r ? '&#9733;' : '<span class="off">&#9733;</span>';
    return out + '</span>';
  }
  function money(n) { return 'LKR ' + Number(n).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}); }
  function today() { return new Date().toISOString().slice(0, 10); }
  function fmtDate(d) {
    var x = new Date(d + 'T00:00:00');
    return isNaN(x) ? d : x.toLocaleDateString('en-GB', {day: '2-digit', month: 'short', year: 'numeric'});
  }
  function daysFrom(d) {
    return Math.ceil((new Date(d + 'T00:00:00') - new Date(today() + 'T00:00:00')) / 86400000);
  }
  function addDays(n) { var d = new Date(); d.setDate(d.getDate() + n); return d.toISOString().slice(0, 10); }
  function toast(msg, type) {
    var wrap = document.querySelector('.toast-wrap');
    if (!wrap) { wrap = document.createElement('div'); wrap.className = 'toast-wrap'; document.body.appendChild(wrap); }
    var t = document.createElement('div');
    var icon = type === 'err' ? 'bi-x-circle-fill' : type === 'info' ? 'bi-info-circle-fill' : 'bi-check-circle-fill';
    t.className = 'lh-toast ' + (type || 'ok');
    t.innerHTML = '<i class="bi ' + icon + '"></i><span>' + esc(msg) + '</span>';
    wrap.appendChild(t);
    setTimeout(function () { t.remove(); }, 3200);
  }
  function modal(id) { return bootstrap.Modal.getOrCreateInstance(document.getElementById(id)); }
  function initials(name) {
    return String(name).split(/\s+/).filter(Boolean).slice(0, 2).map(function (p) { return p[0].toUpperCase(); }).join('');
  }
  var colors = ['#2563eb', '#7c3aed', '#db2777', '#059669', '#d97706', '#0891b2', '#dc2626', '#4f46e5'];
  function colorFor(s) { var h = 0; for (var i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) >>> 0; return colors[h % colors.length]; }

  /* ---------- files: upload to / open from the server (/files), and sample files made in the browser ---------- */
  function ctx() { var el = document.getElementById('meData'); return el && el.dataset.ctx ? el.dataset.ctx : ''; }
  /* url of a stored file. dl=true makes the browser save it to the device instead of showing it */
  function fileUrl(kind, id, name, dl) {
    return ctx() + '/files?kind=' + encodeURIComponent(kind) + '&id=' + encodeURIComponent(id) + '&name=' + encodeURIComponent(name || '') + (dl ? '&dl=1' : '');
  }
  /* uploads one File; resolves {id, name, size} or rejects with a readable Error */
  function upload(kind, file, extra) {
    var fd = new FormData(); fd.append('kind', kind);
    Object.keys(extra || {}).forEach(function (k) { fd.append(k, extra[k]); });
    if (file) fd.append('file', file);
    var ctl = window.AbortController ? new AbortController() : null, timer = ctl ? setTimeout(function () { ctl.abort(); }, 120000) : 0;
    return fetch(ctx() + '/files', {method: 'POST', body: fd, credentials: 'same-origin', signal: ctl ? ctl.signal : undefined}).catch(function () {
      throw new Error('Could not reach the server. Check the connection and try again.');
    }).then(function (r) {
      clearTimeout(timer);
      return r.text().then(function (t) {
        var j = null; try { j = JSON.parse(t); } catch (e) { /* not JSON (login page / server error) */ }
        if (!r.ok || !j || j.error) throw new Error(j && j.error ? j.error : 'Upload failed. Please log in again and retry.');
        return j;
      });
    });
  }
  function removeFile(kind, id, entry) {
    var fd = new FormData(); fd.append('action', 'delete'); fd.append('kind', kind); fd.append('id', id || ''); if (entry) fd.append('entry', entry);
    return fetch(ctx() + '/files', {method: 'POST', body: fd, credentials: 'same-origin'}).catch(function () { /* ignore */ });
  }
  /* saves a Blob to the user's device (works for files made in the browser) */
  function saveBlob(blob, name) {
    var a = document.createElement('a'), u = URL.createObjectURL(blob);
    a.href = u; a.download = name; document.body.appendChild(a); a.click(); a.remove();
    setTimeout(function () { URL.revokeObjectURL(u); }, 4000);
  }
  /* tiny PDF writer (text only). pages: [[{t: 'text', s: 18, b: true}, ...], ...]  landscape: slide-shaped pages */
  function makePdf(pages, landscape) {
    var W = landscape ? 842 : 595, H = landscape ? 595 : 842, objs = [], ascii = function (x) { return String(x).replace(/[^\x20-\x7e]/g, '?').replace(/([\\()])/g, '\\$1'); };
    objs[1] = '<< /Type /Catalog /Pages 2 0 R >>';
    objs[3] = '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>';
    objs[4] = '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>';
    var kids = [];
    pages.forEach(function (lines, i) {
      var y = H - 80, c = 'BT\n';
      lines.forEach(function (l) {
        var size = l.s || 12; y -= size * 1.7;
        c += '/' + (l.b ? 'F2' : 'F1') + ' ' + size + ' Tf 1 0 0 1 56 ' + y.toFixed(1) + ' Tm (' + ascii(l.t) + ') Tj\n';
      });
      c += 'ET\n';
      var po = 5 + i * 2, co = po + 1;
      kids.push(po + ' 0 R');
      objs[po] = '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ' + W + ' ' + H + '] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> /Contents ' + co + ' 0 R >>';
      objs[co] = '<< /Length ' + c.length + ' >>\nstream\n' + c + 'endstream';
    });
    objs[2] = '<< /Type /Pages /Kids [' + kids.join(' ') + '] /Count ' + kids.length + ' >>';
    var out = '%PDF-1.4\n', off = [];
    for (var n = 1; n < objs.length; n++) { if (!objs[n]) continue; off[n] = out.length; out += n + ' 0 obj\n' + objs[n] + '\nendobj\n'; }
    var xr = out.length; out += 'xref\n0 ' + objs.length + '\n0000000000 65535 f \n';
    for (n = 1; n < objs.length; n++) out += (off[n] !== undefined ? ('0000000000' + off[n]).slice(-10) + ' 00000 n \n' : '0000000000 65535 f \n');
    out += 'trailer\n<< /Size ' + objs.length + ' /Root 1 0 R >>\nstartxref\n' + xr + '\n%%EOF';
    return new Blob([out], {type: 'application/pdf'});
  }
  /* a sample PDF page set for a study note / sample submission; wraps long text */
  function wrap(text, n) {
    var words = String(text || '').split(/\s+/), lines = [], cur = '';
    words.forEach(function (w) { if ((cur + ' ' + w).trim().length > n) { lines.push(cur); cur = w; } else cur = (cur + ' ' + w).trim(); });
    if (cur) lines.push(cur);
    return lines;
  }
  /* keeps only the saved items that belong to the learner's own courses (admins keep everything).
     field: 'course' (course name) or 'id' (course id). extra: names that are always allowed (e.g. 'Premium membership') */
  function keep(list, field, extra) {
    var el = document.getElementById('meData');
    if (!el || el.dataset.admin === 'true' || !LH.courses) return list;
    var ok = {}; LH.courses().forEach(function (c) { ok[field === 'id' ? c.id : c.name] = 1; });
    (extra || []).forEach(function (x) { ok[x] = 1; });
    return list.filter(function (x) { return ok[x[field]]; });
  }
  return {remove: remove, keep: keep, ctx: ctx, fileUrl: fileUrl, upload: upload, removeFile: removeFile, saveBlob: saveBlob, makePdf: makePdf, wrap: wrap,
          esc: esc, load: load, save: save, resetAll: resetAll, stars: stars, money: money, today: today, fmtDate: fmtDate,
          daysFrom: daysFrom, addDays: addDays, toast: toast, modal: modal, initials: initials, colorFor: colorFor};
})();
