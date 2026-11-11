<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Payments"/></jsp:include>

<div class="glass-bar mod-hero">
  <div class="mod-title">
    <div class="mod-ico">&#128179;</div>
    <div><h3>Payment</h3><p>Admin: see who has paid, view the receipt details and delete payment records.</p></div>
  </div>
  <span class="chip green"><i class="bi bi-shield-lock-fill"></i> Demo mode &ndash; no real charges</span>
</div>

<div class="card mb-3"><div class="card-body">
  <div class="small text-muted mb-2"><i class="bi bi-diagram-3"></i> Payments are split by the learner level of the student who paid.</div>
  <div class="mod-tabs" id="lvTabs"></div>
</div></div>

<div class="row g-3 mb-3" id="stats"></div>

<div class="card mb-3"><div class="card-body"><div class="mod-filter">
  <input type="search" id="fSearch" class="form-control grow" placeholder="Search by student name, student ID, course or receipt...">
  <select id="fMethod" class="form-select"><option value="">All methods</option><option>Card</option><option>Bank transfer</option><option>Online wallet</option></select>
  <select id="fSort" class="form-select"><option value="new">Newest first</option><option value="high">Highest amount</option><option value="student">Student A - Z</option></select>
</div></div></div>

<div class="card">
  <div class="card-header"><i class="bi bi-people"></i> Students who have paid</div>
  <div class="table-responsive">
    <table class="table table-hover mb-0 align-middle">
      <thead class="table-light"><tr><th>Receipt</th><th>Paid by</th><th>Course</th><th>Date</th><th>Method</th><th class="text-end">Amount</th><th class="text-end">Actions</th></tr></thead>
      <tbody id="rows"></tbody>
    </table>
  </div>
</div>

<!-- Receipt / payer details -->
<div class="modal fade" id="receiptModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Payment details</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body receipt" id="receiptBody"></div>
      <div class="modal-footer justify-content-between">
        <button class="btn btn-outline-danger" id="rcDel"><i class="bi bi-trash"></i> Delete</button>
        <span><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button> <button class="btn btn-primary" id="btnPrint"><i class="bi bi-printer"></i> Print</button></span>
      </div>
    </div>
  </div>
</div>

<!-- Delete -->
<div class="modal fade" id="delModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
    <div class="modal-header"><h5 class="modal-title"><i class="bi bi-trash"></i> Delete payment record</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body" id="delBody"></div>
    <div class="modal-footer"><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Keep it</button><button class="btn btn-danger" id="delOk"><i class="bi bi-trash"></i> Delete</button></div>
  </div></div>
</div>

<jsp:include page="/WEB-INF/views/common/roster.jsp"/>
<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="true" data-level="" data-detail="" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var $ = function (id) { return document.getElementById(id); };
  var ROSTER = getRoster(), ME_CTX = document.getElementById('meData').dataset.ctx;
  function stu(id) { return ROSTER.filter(function (r) { return r.id === id; })[0]; }
  function lvInfo(code) { return LH.LEVELS.filter(function (l) { return l.code === code; })[0] || {tab: code || '-', icon: '', name: code || '-'}; }
  /* the payments are generated from the admin's enrollment list (paid enrollments), then kept in this browser */
  var pays = LH.syncAdminSeed(ROSTER).pays;   /* also adds payments for students who registered after the first visit */
  var curLv = 'ALL', delRc = null, viewRc = null, srv = [];
  /* payments made by students (saved in the database by /payment-records) + the demo list above */
  function all() { var seen = {}; return srv.concat(pays).filter(function (p) { if (seen[p.rcpt]) return false; seen[p.rcpt] = 1; return true; }); }
  function isSrv(rc) { return srv.some(function (p) { return p.rcpt === rc; }); }
  function loadSrv() {
    fetch(ME_CTX + '/payment-records', {credentials: 'same-origin'}).then(function (r) { return r.json(); })
      .then(function (j) { srv = (j && j.payments) || []; refresh(); }).catch(function () { /* keep demo list only */ });
  }
  function lvOf(p) { var s = stu(p.sid); return s ? s.lv : ''; }
  function inScope() { return all().filter(function (p) { return curLv === 'ALL' || lvOf(p) === curLv; }); }
  function persist() { LH.save('adm-pay', pays); }

  function tabs() {
    var defs = [{code: 'ALL', tab: 'All', icon: '&#128450;'}].concat(LH.LEVELS);
    $('lvTabs').innerHTML = defs.map(function (l) {
      var n = l.code === 'ALL' ? all().length : all().filter(function (p) { return lvOf(p) === l.code; }).length;
      return '<button type="button" class="mod-tab ' + (curLv === l.code ? 'active' : '') + '" data-lv="' + l.code + '">' + l.icon + ' ' + l.tab + '<span class="cnt">' + n + '</span></button>';
    }).join('');
  }
  function stats() {
    var sc = inScope(), total = sc.reduce(function (t, p) { return t + p.amount; }, 0), payers = new Set(sc.map(function (p) { return p.sid; })).size;
    var cards = [['Total collected', LH.money(total), 'bi-cash-stack', 'green'], ['Payments', sc.length, 'bi-receipt-cutoff', ''],
                 ['Students who paid', payers, 'bi-people-fill', 'cyan'], ['Average payment', sc.length ? LH.money(total / sc.length) : '-', 'bi-calculator', 'amber']];
    $('stats').innerHTML = cards.map(function (c) {
      return '<div class="col-md-3 col-6"><div class="card stat-card ' + c[3] + ' p-3"><span class="gicon"><i class="bi ' + c[2] + '"></i></span><div><div class="text-muted small">' + c[0] + '</div><div class="stat-number" style="font-size:' + (String(c[1]).length > 9 ? '1.05rem' : '1.5rem') + '">' + c[1] + '</div></div></div></div>';
    }).join('');
  }
  function list() {
    var q = $('fSearch').value.toLowerCase(), m = $('fMethod').value, so = $('fSort').value;
    var out = inScope().filter(function (p) {
      var s = stu(p.sid) || {name: ''};
      return (!m || p.method === m) && (!q || (s.name + ' ' + p.sid + ' ' + p.course + ' ' + p.rcpt).toLowerCase().indexOf(q) >= 0);
    });
    out.sort(function (a, b) {
      if (so === 'high') return b.amount - a.amount;
      if (so === 'student') return ((stu(a.sid) || {name: a.sid}).name).localeCompare((stu(b.sid) || {name: b.sid}).name);
      return b.date < a.date ? -1 : b.date > a.date ? 1 : b.rcpt < a.rcpt ? -1 : 1;
    });
    if (!out.length) { $('rows').innerHTML = '<tr><td colspan="7"><div class="empty-state"><i class="bi bi-receipt"></i>No payments in this part.</div></td></tr>'; return; }
    $('rows').innerHTML = out.map(function (p) {
      var s = stu(p.sid) || {name: 'Unknown student', lv: ''};
      return '<tr><td class="small"><strong>' + LH.esc(p.rcpt) + '</strong></td>' +
        '<td><div class="d-flex align-items-center gap-2"><div class="avatar-chip" style="background:' + LH.colorFor(s.name) + ';width:34px;height:34px;font-size:.8rem">' + LH.esc(LH.initials(s.name)) + '</div>' +
          '<div><div class="fw-bold">' + LH.esc(s.name) + '</div><div class="small text-muted">' + LH.esc(p.sid) + ' &middot; ' + LH.esc(lvInfo(s.lv).tab) + '</div></div></div></td>' +
        '<td>' + LH.esc(p.course) + '<div class="small text-muted">' + LH.esc(p.desc) + '</div></td><td class="text-nowrap">' + LH.fmtDate(p.date) + '</td>' +
        '<td><span class="chip">' + LH.esc(p.method) + '</span></td><td class="text-end text-nowrap fw-bold">' + LH.money(p.amount) + '</td>' +
        '<td class="text-end text-nowrap"><button class="btn btn-sm btn-outline-primary" data-view="' + LH.esc(p.rcpt) + '" title="View details"><i class="bi bi-eye"></i></button> ' +
          '<button class="btn btn-sm btn-outline-danger" data-del="' + LH.esc(p.rcpt) + '" title="Delete"><i class="bi bi-trash"></i></button></td></tr>';
    }).join('');
  }
  function refresh() { tabs(); stats(); list(); }
  function byRc(rc) { return all().filter(function (p) { return p.rcpt === rc; })[0]; }

  $('lvTabs').addEventListener('click', function (e) { var b = e.target.closest('[data-lv]'); if (b) { curLv = b.getAttribute('data-lv'); refresh(); } });
  ['fSearch', 'fMethod', 'fSort'].forEach(function (id) { $(id).addEventListener('input', list); });
  $('rows').addEventListener('click', function (e) {
    var v = e.target.closest('[data-view]'), d = e.target.closest('[data-del]');
    if (v) showReceipt(byRc(v.getAttribute('data-view')));
    if (d) askDelete(d.getAttribute('data-del'));
  });

  function showReceipt(p) {
    if (!p) return; viewRc = p.rcpt;
    var s = stu(p.sid) || {name: 'Unknown student', email: '-', lv: '', detail: '', member: '-'};
    function row(k, v) { return '<div class="d-flex justify-content-between gap-3 py-1 border-bottom"><span>' + k + '</span><strong class="text-end">' + v + '</strong></div>'; }
    $('receiptBody').innerHTML = '<div class="text-center mb-3"><div class="fs-1">&#127891;</div><h5 class="mb-0">LearnHub</h5><div class="small text-muted">Payment receipt</div></div>' +
      row('Receipt no.', LH.esc(p.rcpt)) + row('Paid by', LH.esc(s.name)) + row('Student ID', LH.esc(p.sid)) + row('Email', LH.esc(s.email)) +
      row('Learner level', LH.esc(lvInfo(s.lv).tab) + (s.detail ? ' (' + LH.esc(s.detail) + ')' : '')) + row('Membership', LH.esc(s.member)) +
      row('Course', LH.esc(p.course)) + row('Details', LH.esc(p.desc)) + row('Date', LH.fmtDate(p.date)) + row('Method', LH.esc(p.method)) + row('Reference', LH.esc(p.ref)) +
      '<div class="d-flex justify-content-between pt-3 fs-5"><span>Amount paid</span><strong>' + LH.money(p.amount) + '</strong></div><div class="text-center mt-3"><span class="chip green">PAID</span></div>';
    LH.modal('receiptModal').show();
  }
  $('btnPrint').addEventListener('click', function () { window.print(); });
  $('rcDel').addEventListener('click', function () { var rc = viewRc; LH.modal('receiptModal').hide(); setTimeout(function () { askDelete(rc); }, 250); });

  function askDelete(rc) {
    var p = byRc(rc); if (!p) return; delRc = rc;
    var s = stu(p.sid) || {name: p.sid};
    $('delBody').innerHTML = '<p>Delete the payment record <strong>' + LH.esc(p.rcpt) + '</strong> of <strong>' + LH.esc(s.name) + '</strong> (' + LH.esc(p.sid) + ') &ndash; ' + LH.money(p.amount) + '?</p>' +
      '<p class="mb-0 small text-muted">This only removes the record from this list. It does not refund the student.</p>';
    LH.modal('delModal').show();
  }
  $('delOk').addEventListener('click', function () {
    if (isSrv(delRc)) { var fd = new URLSearchParams({action: 'delete', rcpt: delRc}); fetch(ME_CTX + '/payment-records', {method: 'POST', body: fd, credentials: 'same-origin'}); srv = srv.filter(function (p) { return p.rcpt !== delRc; }); }
    else { pays = pays.filter(function (p) { return p.rcpt !== delRc; }); persist(); }
    delRc = null; LH.modal('delModal').hide(); refresh(); LH.toast('Payment record deleted', 'info');
  });
  refresh(); loadSrv();
  setInterval(loadSrv, 15000);   /* new student payments appear without reloading */
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
