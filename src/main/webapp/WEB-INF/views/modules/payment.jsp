<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Payment"/></jsp:include>

<div class="glass-bar mod-hero">
  <div class="mod-title">
    <div class="mod-ico">&#128179;</div>
    <div><h3>Payment</h3><p>Pay course fees securely and keep your receipts.</p></div>
  </div>
  <span class="chip green"><i class="bi bi-shield-lock-fill"></i> Demo mode &ndash; no real charges</span>
</div>

<div class="row g-3 mb-3" id="stats"></div>

<div class="row g-3">
  <div class="col-lg-5">
    <div class="card h-100">
      <div class="card-header"><i class="bi bi-hourglass-split"></i> Pending payments</div>
      <div class="card-body" id="pendingList"></div>
    </div>
  </div>
  <div class="col-lg-7">
    <div class="card h-100">
      <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span><i class="bi bi-receipt"></i> Payment history</span>
        <select id="hFilter" class="form-select form-select-sm" style="max-width:170px"><option value="">All methods</option><option>Card</option><option>Bank transfer</option><option>Online wallet</option></select>
      </div>
      <div class="table-responsive">
        <table class="table table-hover mb-0 align-middle">
          <thead class="table-light"><tr><th>Receipt</th><th>Course</th><th>Date</th><th>Method</th><th class="text-end">Amount</th><th></th></tr></thead>
          <tbody id="history"></tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<!-- Pay modal -->
<div class="modal fade" id="payModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <form class="modal-content" id="payForm" novalidate autocomplete="off">
      <div class="modal-header"><h5 class="modal-title">Complete payment</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="row g-4">
          <div class="col-md-5">
            <div class="mod-tile mb-3"><div class="small text-muted">You are paying for</div><div class="fw-bold" id="pCourse"></div>
              <div class="display-6 fw-bold mt-1" id="pAmount"></div></div>
            <div class="credit-card" id="cardPrev"><div class="d-flex justify-content-between"><i class="bi bi-wifi fs-4"></i><strong>LearnHub Pay</strong></div>
              <div class="num" id="pvNum">&bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull;</div>
              <div class="meta"><span id="pvName">Card holder</span><span id="pvExp">MM/YY</span></div></div>
          </div>
          <div class="col-md-7">
            <label class="form-label">Payment method</label>
            <div class="pay-methods mb-3">
              <label><input type="radio" name="method" value="Card" checked><span><i class="bi bi-credit-card-2-front"></i>Card</span></label>
              <label><input type="radio" name="method" value="Bank transfer"><span><i class="bi bi-bank"></i>Bank</span></label>
              <label><input type="radio" name="method" value="Online wallet"><span><i class="bi bi-phone"></i>Wallet</span></label>
            </div>
            <div id="boxCard">
              <div class="mb-2"><label class="form-label">Card number</label><input id="cNum" class="form-control" inputmode="numeric" maxlength="19" placeholder="1234 5678 9012 3456"></div>
              <div class="mb-2"><label class="form-label">Name on card</label><input id="cName" class="form-control" maxlength="40" placeholder="As printed on the card"></div>
              <div class="row g-2"><div class="col-6"><label class="form-label">Expiry</label><input id="cExp" class="form-control" inputmode="numeric" maxlength="5" placeholder="MM/YY"></div>
                <div class="col-6"><label class="form-label">CVV</label><input id="cCvv" class="form-control" type="password" inputmode="numeric" maxlength="4" placeholder="&bull;&bull;&bull;"></div></div>
            </div>
            <div id="boxBank" hidden>
              <div class="alert alert-info small mb-2">Transfer the amount to <strong>LearnHub (Pvt) Ltd &ndash; 1234567890, Commercial Bank</strong> and upload the slip. Use your Student ID as the reference.</div>
              <label class="form-label">Bank slip</label><input type="file" id="bSlip" class="form-control" accept=".jpg,.jpeg,.png,.pdf">
            </div>
            <div id="boxWallet" hidden>
              <label class="form-label">Wallet / mobile number</label><input id="wNum" class="form-control" inputmode="tel" maxlength="12" placeholder="07X XXX XXXX">
              <div class="form-text">You will receive a confirmation code on this number.</div>
            </div>
            <div class="text-danger small mt-2" id="pErr"></div>
            <div class="small text-muted mt-2"><i class="bi bi-lock"></i> Demo only: card details are never saved or sent anywhere. Only the last 4 digits appear on the receipt.</div>
          </div>
        </div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary" id="payBtn"><i class="bi bi-lock-fill"></i> Pay now</button></div>
    </form>
  </div>
</div>

<!-- Receipt modal -->
<div class="modal fade" id="receiptModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Payment receipt</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body receipt" id="receiptBody"></div>
      <div class="modal-footer"><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
        <button class="btn btn-primary" id="btnPrint"><i class="bi bi-printer"></i> Print</button></div>
    </div>
  </div>
</div>

<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="${currentUser.canManageUsers()}" data-level="${currentUser.level.code}" data-detail="<c:out value='${currentUser.levelDetail}'/>" data-premium="${currentUser.type == 'PREMIUM'}" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var meEl = document.getElementById('meData'), ME = {id: meEl.dataset.id, name: meEl.dataset.name, admin: meEl.dataset.admin === 'true', premium: meEl.dataset.premium === 'true'};
  var $ = function (id) { return document.getElementById(id); };
  var ENR = LH.keep(LH.load('enrolled', LH.defaultEnrolled()), 'id'), SEEDP = LH.seedPayments(LH.courses(), ENR);
  var pending = LH.keep(LH.load('pay-pending', SEEDP.pending), 'course', ['Premium membership']), history = LH.keep(LH.load('pay-history', SEEDP.history), 'course', ['Premium membership']), cur = null;
  if (ME.premium) pending = pending.filter(function (p) { return p.course !== 'Premium membership'; });   /* already premium: nothing to buy */

  function stats() {
    var paid = history.reduce(function (t, h) { return t + h.amount; }, 0), owed = pending.reduce(function (t, p) { return t + p.amount; }, 0);
    var overdue = pending.filter(function (p) { return LH.daysFrom(p.due) < 0; }).length;
    var cards = [['Total paid', LH.money(paid), 'bi-wallet2', 'green'], ['Outstanding', LH.money(owed), 'bi-hourglass-split', 'amber'],
                 ['Overdue invoices', overdue, 'bi-exclamation-triangle-fill', 'red'], ['Receipts', history.length, 'bi-receipt-cutoff', 'cyan']];
    $('stats').innerHTML = cards.map(function (c) {
      return '<div class="col-md-3 col-6"><div class="card stat-card ' + c[3] + ' p-3"><span class="gicon"><i class="bi ' + c[2] + '"></i></span><div><div class="text-muted small">' + c[0] + '</div><div class="stat-number" style="font-size:' + (String(c[1]).length > 9 ? '1.05rem' : '1.5rem') + '">' + c[1] + '</div></div></div></div>';
    }).join('');
  }
  function pendingList() {
    if (!pending.length) { $('pendingList').innerHTML = '<div class="empty-state"><i class="bi bi-patch-check"></i>All paid up. Thank you!</div>'; return; }
    $('pendingList').innerHTML = pending.map(function (p) {
      var d = LH.daysFrom(p.due), late = d < 0;
      return '<div class="mod-tile mb-2"><div class="d-flex justify-content-between gap-2"><div><div class="fw-bold">' + LH.esc(p.course) + '</div><div class="small text-muted">' + LH.esc(p.desc) + '</div></div>' +
        '<div class="text-end"><div class="fw-bold">' + LH.money(p.amount) + '</div>' + (late ? '<span class="chip red">Overdue</span>' : '<span class="chip amber">' + (d === 0 ? 'Due today' : d + ' days left') + '</span>') + '</div></div>' +
        '<div class="d-flex justify-content-between align-items-center mt-2"><span class="small text-muted">' + LH.esc(p.id) + ' &middot; due ' + LH.fmtDate(p.due) + '</span>' +
        (ME.admin ? '' : '<button class="btn btn-sm btn-primary" data-pay="' + p.id + '"><i class="bi bi-credit-card"></i> Pay now</button>') + '</div></div>';
    }).join('');
  }
  function histTable() {
    var f = $('hFilter').value, rows = history.filter(function (h) { return !f || h.method === f; });
    if (!rows.length) { $('history').innerHTML = '<tr><td colspan="6"><div class="empty-state"><i class="bi bi-receipt"></i>No payments yet.</div></td></tr>'; return; }
    $('history').innerHTML = rows.map(function (h) {
      return '<tr><td class="small"><strong>' + LH.esc(h.rcpt) + '</strong></td><td>' + LH.esc(h.course) + '<div class="small text-muted">' + LH.esc(h.desc) + '</div></td><td class="text-nowrap">' + LH.fmtDate(h.date) + '</td>' +
        '<td><span class="chip">' + LH.esc(h.method) + '</span></td><td class="text-end text-nowrap fw-bold">' + LH.money(h.amount) + '</td>' +
        '<td class="text-end"><button class="btn btn-sm btn-outline-primary" data-rcpt="' + LH.esc(h.rcpt) + '" title="View receipt"><i class="bi bi-file-earmark-text"></i></button></td></tr>';
    }).join('');
  }
  function refresh() { stats(); pendingList(); histTable(); }

  function method() { return document.querySelector('input[name=method]:checked').value; }
  function showBox() {
    var m = method(); $('boxCard').hidden = m !== 'Card'; $('boxBank').hidden = m !== 'Bank transfer'; $('boxWallet').hidden = m !== 'Online wallet';
    $('cardPrev').style.opacity = m === 'Card' ? 1 : .35;
  }
  document.querySelectorAll('input[name=method]').forEach(function (r) { r.addEventListener('change', showBox); });
  $('cNum').addEventListener('input', function () {
    var v = this.value.replace(/\D/g, '').slice(0, 16); this.value = v.replace(/(.{4})/g, '$1 ').trim();
    var p = (v + '################').slice(0, 16).replace(/#/g, '•'); $('pvNum').textContent = p.replace(/(.{4})/g, '$1 ').trim();
  });
  $('cName').addEventListener('input', function () { $('pvName').textContent = this.value.trim() || 'Card holder'; });
  $('cExp').addEventListener('input', function () {
    var v = this.value.replace(/\D/g, '').slice(0, 4); if (v.length > 2) v = v.slice(0, 2) + '/' + v.slice(2); this.value = v; $('pvExp').textContent = v || 'MM/YY';
  });
  $('cCvv').addEventListener('input', function () { this.value = this.value.replace(/\D/g, ''); });

  function luhn(n) {
    var s = 0, alt = false;
    for (var i = n.length - 1; i >= 0; i--) { var d = +n[i]; if (alt) { d *= 2; if (d > 9) d -= 9; } s += d; alt = !alt; }
    return s % 10 === 0;
  }
  $('pendingList').addEventListener('click', function (e) {
    var b = e.target.closest('[data-pay]'); if (!b) return;
    cur = pending.filter(function (p) { return p.id === b.getAttribute('data-pay'); })[0];
    $('payForm').reset(); $('pErr').textContent = ''; $('pvNum').innerHTML = '&bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull;';
    $('pvName').textContent = 'Card holder'; $('pvExp').textContent = 'MM/YY'; showBox();
    $('pCourse').textContent = cur.course + ' - ' + cur.desc; $('pAmount').textContent = LH.money(cur.amount); LH.modal('payModal').show();
  });
  $('payForm').addEventListener('submit', function (e) {
    e.preventDefault();
    var m = method(), ref = '';
    if (m === 'Card') {
      var n = $('cNum').value.replace(/\s/g, ''), ex = $('cExp').value.split('/'), mm = +ex[0], yy = +ex[1];
      if (n.length !== 16 || !luhn(n)) return $('pErr').textContent = 'Enter a valid 16-digit card number (demo tip: 4242 4242 4242 4242).';
      if ($('cName').value.trim().length < 3) return $('pErr').textContent = 'Enter the name on the card.';
      var now = new Date(), curYY = now.getFullYear() % 100, curMM = now.getMonth() + 1;
      if (!(mm >= 1 && mm <= 12) || isNaN(yy) || yy < curYY || (yy === curYY && mm < curMM)) return $('pErr').textContent = 'Card expiry is invalid or expired.';
      if (!/^\d{3,4}$/.test($('cCvv').value)) return $('pErr').textContent = 'Enter the 3 or 4 digit CVV.';
      ref = '**** ' + n.slice(-4);
    } else if (m === 'Bank transfer') {
      var f = $('bSlip').files[0]; if (!f) return $('pErr').textContent = 'Please upload your bank slip.'; ref = 'Slip: ' + f.name;
    } else {
      var w = $('wNum').value.replace(/\s/g, ''); if (!/^0\d{9}$/.test(w)) return $('pErr').textContent = 'Enter a valid 10-digit mobile number.'; ref = w.slice(0, 3) + ' *** ' + w.slice(-4);
    }
    var btn = $('payBtn'); btn.disabled = true; btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processing...';
    var paid = cur, body = new URLSearchParams({course: paid.course, desc: paid.desc, amount: paid.amount, method: m, ref: ref});
    function done() { btn.disabled = false; btn.innerHTML = '<i class="bi bi-lock-fill"></i> Pay now'; }
    /* the payment is saved on the server (so the admin sees it); buying "Premium membership" also upgrades the account */
    fetch(meEl.dataset.ctx + '/payment-records', {method: 'POST', body: body, credentials: 'same-origin'}).catch(function () { return null; })
      .then(function (r) { return r ? r.json().catch(function () { return null; }) : null; })
      .then(function (j) {
        if (!j || !j.ok) { done(); $('pErr').textContent = (j && j.error) || 'Could not record the payment. Please try again.'; return; }
        var rec = {rcpt: j.rcpt, course: paid.course, desc: paid.desc, amount: paid.course === 'Premium membership' ? 1500 : paid.amount, date: j.date, method: m, ref: ref};
        history.unshift(rec); pending = pending.filter(function (p) { return p.id !== paid.id; });
        LH.save('pay-history', history); LH.save('pay-pending', pending);
        done(); LH.modal('payModal').hide(); refresh(); showReceipt(rec);
        if (j.premium && !ME.premium) { ME.premium = true; showPremiumTag(); LH.toast('Payment successful - you are now a Premium student!'); } else LH.toast('Payment successful');
      });
  });
  /* gold "Premium" tag next to the LearnHub name, without waiting for a page reload */
  function showPremiumTag() {
    if (document.getElementById('premiumTag')) return;
    var b = document.querySelector('.app-navbar .brand-link'); if (!b) return;
    var t = document.createElement('span'); t.className = 'premium-tag'; t.id = 'premiumTag'; t.innerHTML = '<i class="bi bi-star-fill"></i> Premium';
    b.insertAdjacentElement('afterend', t);
  }

  function showReceipt(h) {
    function row(k, v) { return '<div class="d-flex justify-content-between py-1 border-bottom"><span>' + k + '</span><strong class="text-end">' + v + '</strong></div>'; }
    $('receiptBody').innerHTML = '<div class="text-center mb-3"><div class="fs-1">&#127891;</div><h5 class="mb-0">LearnHub</h5><div class="small text-muted">Payment receipt</div></div>' +
      row('Receipt no.', LH.esc(h.rcpt)) + row('Student', LH.esc(ME.name) + ' (' + LH.esc(ME.id) + ')') + row('Course', LH.esc(h.course)) + row('Details', LH.esc(h.desc)) +
      row('Date', LH.fmtDate(h.date)) + row('Method', LH.esc(h.method)) + row('Reference', LH.esc(h.ref)) +
      '<div class="d-flex justify-content-between pt-3 fs-5"><span>Amount paid</span><strong>' + LH.money(h.amount) + '</strong></div>' +
      '<div class="text-center mt-3"><span class="chip green">PAID</span></div>';
    LH.modal('receiptModal').show();
  }
  $('history').addEventListener('click', function (e) {
    var b = e.target.closest('[data-rcpt]'); if (!b) return;
    showReceipt(history.filter(function (h) { return h.rcpt === b.getAttribute('data-rcpt'); })[0]);
  });
  $('btnPrint').addEventListener('click', function () { window.print(); });
  $('hFilter').addEventListener('input', histTable);
  refresh();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
