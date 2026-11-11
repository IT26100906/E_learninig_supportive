<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Course Enrollment"/></jsp:include>

<div class="glass-bar mod-hero">
  <div class="mod-title">
    <div class="mod-ico">&#127891;</div>
    <div><h3>Course Enrollment</h3><p>Browse available courses and manage your enrollments.</p></div>
  </div>
  <c:if test="${not currentUser.canManageUsers()}">
    <div style="min-width:240px">
      <div class="d-flex justify-content-between small fw-bold"><span>Enrollment limit (<c:out value="${currentUser.membershipLabel}"/>)</span><span id="limitText"></span></div>
      <div class="progress thin mt-1"><div class="progress-bar" id="limitBar" style="width:0"></div></div>
      <div class="small mt-1 opacity-75"><i class="bi bi-gift"></i> Free enrollments used: <strong id="freeText"></strong></div>
    </div>
  </c:if>
</div>

<c:if test="${currentUser.canManageUsers()}">
  <div class="alert alert-info"><i class="bi bi-info-circle"></i> You are viewing as an admin. Students can enroll in up to their membership limit (Regular / Premium).</div>
</c:if>

<ul class="nav nav-pills mb-3 gap-2" id="enrTabs">
  <li class="nav-item"><button class="mod-tab active" data-view="catalog">Available courses</button></li>
  <li class="nav-item"><button class="mod-tab" data-view="mine">My enrollments <span class="cnt" id="myCnt">0</span></button></li>
</ul>

<div id="catalogView">
  <div class="card mb-3"><div class="card-body"><div class="mod-filter">
    <input type="search" id="fSearch" class="form-control grow" placeholder="Search courses or instructors...">
    <select id="fCat" class="form-select"></select>
    <select id="fPrice" class="form-select"><option value="">Free &amp; paid</option><option value="free">Free courses</option><option value="paid">Paid courses</option></select>
    <select id="fLevel" class="form-select"><option value="">All levels</option><option>Beginner</option><option>Intermediate</option><option>Advanced</option></select>
  </div></div></div>
  <div class="row g-3" id="catalog"></div>
</div>

<div id="mineView" hidden>
  <div class="row g-3" id="mineGrid"></div>
</div>

<!-- Remove (drop) course confirmation -->
<div class="modal fade" id="dropModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
    <div class="modal-header"><h5 class="modal-title"><i class="bi bi-box-arrow-right"></i> Remove course</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body" id="dropBody"></div>
    <div class="modal-footer"><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Keep course</button>
      <button class="btn btn-danger" id="dropConfirm"><i class="bi bi-trash"></i> Remove</button></div>
  </div></div>
</div>

<!-- ============ INSIDE THE COURSE (after enrolling) ============ -->
<div id="learnView" hidden></div>

<!-- Enroll modal: Payment tab / Free enrollment tab (first 2 courses can be free) -->
<div class="modal fade" id="enrollModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <form class="modal-content" id="enrForm" novalidate autocomplete="off">
      <div class="modal-header"><h5 class="modal-title"><i class="bi bi-mortarboard"></i> Enroll in course</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="row g-4">
          <div class="col-md-5">
            <div class="mod-tile mb-3">
              <div class="small text-muted">You are enrolling in</div><div class="fw-bold" id="eCourse"></div>
              <div class="small text-muted" id="eMeta"></div>
              <div class="small text-muted mt-2">Course fee</div><div class="display-6 fw-bold" id="eAmount"></div>
            </div>
            <div class="credit-card" id="eCardPrev"><div class="d-flex justify-content-between"><i class="bi bi-wifi fs-4"></i><strong>LearnHub Pay</strong></div>
              <div class="num" id="evNum">&bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull;</div>
              <div class="meta"><span id="evName">Card holder</span><span id="evExp">MM/YY</span></div></div>
          </div>
          <div class="col-md-7">
            <div class="d-flex gap-2 mb-3" id="tabsRow">
              <button type="button" class="mod-tab active" data-etab="pay"><i class="bi bi-credit-card"></i> Payment</button>
              <button type="button" class="mod-tab" data-etab="free" id="tabFreeBtn"><i class="bi bi-gift"></i> Free enrollment <span class="cnt" id="freeLeft"></span></button>
            </div>

            <div id="paneFree" hidden>
              <div class="alert alert-info small mb-2" id="freeInfo"></div>
            </div>

            <div id="panePay">
              <label class="form-label">Payment method</label>
              <div class="pay-methods mb-3">
                <label><input type="radio" name="emethod" value="Card" checked><span><i class="bi bi-credit-card-2-front"></i>Card</span></label>
                <label><input type="radio" name="emethod" value="Bank transfer"><span><i class="bi bi-bank"></i>Bank</span></label>
                <label><input type="radio" name="emethod" value="Online wallet"><span><i class="bi bi-phone"></i>Wallet</span></label>
              </div>
              <div id="eBoxCard">
                <div class="mb-2"><label class="form-label">Card number</label><input id="eNum" class="form-control" inputmode="numeric" maxlength="19" placeholder="1234 5678 9012 3456"></div>
                <div class="mb-2"><label class="form-label">Name on card</label><input id="eName" class="form-control" maxlength="40" placeholder="As printed on the card"></div>
                <div class="row g-2"><div class="col-6"><label class="form-label">Expiry</label><input id="eExp" class="form-control" inputmode="numeric" maxlength="5" placeholder="MM/YY"></div>
                  <div class="col-6"><label class="form-label">CVV</label><input id="eCvv" class="form-control" type="password" inputmode="numeric" maxlength="4" placeholder="&bull;&bull;&bull;"></div></div>
              </div>
              <div id="eBoxBank" hidden>
                <div class="alert alert-info small mb-2">Transfer the amount to <strong>LearnHub (Pvt) Ltd &ndash; 1234567890, Commercial Bank</strong> and upload the slip. Use your Student ID as the reference.</div>
                <label class="form-label">Bank slip</label><input type="file" id="eSlip" class="form-control" accept=".jpg,.jpeg,.png,.pdf">
              </div>
              <div id="eBoxWallet" hidden>
                <label class="form-label">Wallet / mobile number</label><input id="eWal" class="form-control" inputmode="tel" maxlength="12" placeholder="07X XXX XXXX">
                <div class="form-text">You will receive a confirmation code on this number.</div>
              </div>
              <div class="small text-muted mt-2"><i class="bi bi-lock"></i> Demo only: card details are never saved or sent anywhere. Only the last 4 digits appear on the receipt.</div>
            </div>
            <div class="text-danger small mt-2" id="eErr"></div>
          </div>
        </div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary" id="eSubmit"><i class="bi bi-lock-fill"></i> Pay &amp; enroll</button></div>
    </form>
  </div>
</div>

<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="${currentUser.canManageUsers()}" data-level="${currentUser.level.code}" data-detail="<c:out value='${currentUser.levelDetail}'/>" data-max="${currentUser.maxEnrollments}" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var meEl = document.getElementById('meData'), ADMIN = meEl.dataset.admin === 'true', MAX = parseInt(meEl.dataset.max, 10) || 0;
  var $ = function (id) { return document.getElementById(id); };
  var COURSES = LH.courses();
  var enrolled = LH.keep(LH.load('enrolled', LH.defaultEnrolled()), 'id');
  var pending = null, FREE_LIMIT = 2, tab = 'pay';
  function byId(id) { return COURSES.filter(function (c) { return c.id === id; })[0]; }
  function isIn(id) { return enrolled.some(function (e) { return e.id === id; }); }
  function seatsLeft(c) { return c.seats - c.taken - (isIn(c.id) ? 1 : 0); } // 'taken' = other students

  var cats = {}; COURSES.forEach(function (c) { cats[c.cat] = 1; });
  $('fCat').innerHTML = '<option value="">All categories</option>' + Object.keys(cats).map(function (c) { return '<option>' + LH.esc(c) + '</option>'; }).join('');

  function freeUsed() { return enrolled.filter(function (e) { return e.paid === false; }).length; } // entries without 'paid' are treated as paid
  function limit() {
    if (!$('limitText')) return;
    $('freeText').textContent = Math.min(freeUsed(), FREE_LIMIT) + ' / ' + FREE_LIMIT;
    $('limitText').textContent = enrolled.length + ' / ' + MAX;
    var pct = MAX ? Math.min(100, enrolled.length * 100 / MAX) : 0;
    $('limitBar').style.width = pct + '%'; $('limitBar').className = 'progress-bar ' + (pct >= 100 ? 'bg-danger' : pct >= 70 ? 'bg-warning' : 'bg-success');
  }
  function catalog() {
    var q = $('fSearch').value.toLowerCase(), ca = $('fCat').value, lv = $('fLevel').value, pr = $('fPrice').value;
    var rows = COURSES.filter(function (c) { return (!pr || (pr === 'free' ? c.fee === 0 : c.fee > 0)) && (!ca || c.cat === ca) && (!lv || c.diff === lv) && (!q || (c.name + ' ' + c.teacher).toLowerCase().indexOf(q) >= 0); });
    if (!rows.length) { $('catalog').innerHTML = '<div class="col-12"><div class="card"><div class="empty-state"><i class="bi bi-search"></i>No courses found.</div></div></div>'; return; }
    $('catalog').innerHTML = rows.map(function (c) {
      var left = seatsLeft(c), full = left <= 0, mine = isIn(c.id), atLimit = !ADMIN && enrolled.length >= MAX;
      var btn = ADMIN ? '<button class="btn btn-outline-secondary w-100" disabled>Students only</button>'
        : mine ? '<button class="btn btn-success w-100" data-open="' + c.id + '"><i class="bi bi-play-circle"></i> Open course</button>'
        : full ? '<button class="btn btn-outline-secondary w-100" disabled>Course full</button>'
        : atLimit ? '<button class="btn btn-outline-secondary w-100" disabled title="Enrollment limit reached">Limit reached</button>'
        : '<button class="btn btn-primary w-100" data-enroll="' + c.id + '"><i class="bi bi-plus-circle"></i> ' + (c.fee === 0 ? 'Enroll free' : 'Enroll') + '</button>';
      return '<div class="col-md-6 col-xl-3" data-cid="' + c.id + '"><div class="card h-100"><div class="card-body d-flex flex-column">' +
        '<div class="course-banner" style="background:' + c.color + '">' + c.icon + '</div>' +
        '<div class="d-flex gap-1 mb-1 flex-wrap"><span class="chip blue">' + LH.esc(c.cat) + '</span><span class="chip">' + c.diff + '</span>' + (c.fee === 0 ? '<span class="chip green">FREE</span>' : '') + '</div>' +
        '<h6 class="fw-bold">' + LH.esc(c.name) + '</h6>' +
        '<div class="small text-muted mb-2"><i class="bi bi-person-video3"></i> ' + LH.esc(c.teacher) + '<br><i class="bi bi-clock"></i> ' + c.weeks + ' weeks</div>' +
        '<div class="flex-fill"></div>' +
        '<div class="d-flex justify-content-between small mb-1"><span>' + (full ? '<span class="chip red">Full</span>' : left + ' seats left') + '</span><strong>' + LH.price(c) + '</strong></div>' +
        '<div class="progress thin mb-3"><div class="progress-bar ' + (left <= 5 ? 'bg-danger' : 'bg-info') + '" style="width:' + Math.round((c.seats - left) * 100 / c.seats) + '%"></div></div>' +
        btn + '</div></div></div>';
    }).join('');
  }
  function payChip(e) { return e.paid === 'free' ? '<span class="chip blue">Free course</span>' : e.paid === false ? '<span class="chip amber">Free slot</span>' : '<span class="chip green">Paid</span>'; }
  function mine() {
    $('myCnt').textContent = enrolled.length;
    var list = enrolled.filter(function (x) { return byId(x.id); });
    if (!list.length) {
      $('mineGrid').innerHTML = '<div class="col-12"><div class="card"><div class="empty-state"><i class="bi bi-journal-x"></i>You have not enrolled in any course yet.' +
        '<div class="mt-3"><button class="btn btn-primary" data-view-go="catalog"><i class="bi bi-plus-circle"></i> Browse courses</button></div></div></div></div>'; return;
    }
    var ctx = document.body.dataset.ctx;
    $('mineGrid').innerHTML = list.map(function (en) {
      var c = byId(en.id), done = en.progress >= 100;
      return '<div class="col-md-6 col-xl-3"><div class="card h-100"><div class="card-body d-flex flex-column">' +
        '<div class="course-banner" style="background:' + c.color + '">' + c.icon + '</div>' +
        '<div class="d-flex gap-1 mb-1 flex-wrap"><span class="chip blue">' + LH.esc(c.cat) + '</span><span class="chip">' + LH.esc(c.diff) + '</span>' + payChip(en) + (done ? '<span class="chip green">Completed</span>' : '') + '</div>' +
        '<h6 class="fw-bold">' + LH.esc(c.name) + '</h6>' +
        '<div class="small text-muted mb-2"><i class="bi bi-person-video3"></i> ' + LH.esc(c.teacher) + '<br><i class="bi bi-calendar-check"></i> Enrolled ' + LH.fmtDate(en.date) + '</div>' +
        '<div class="flex-fill"></div>' +
        '<div class="d-flex justify-content-between small mb-1"><span>' + en.progress + '% complete</span><strong>' + LH.price(c) + '</strong></div>' +
        '<div class="progress thin mb-3"><div class="progress-bar bg-success" style="width:' + en.progress + '%"></div></div>' +
        '<button class="btn btn-primary w-100 mb-2" data-open="' + c.id + '"><i class="bi bi-play-circle"></i> Open course</button>' +
        '<div class="d-flex gap-2"><a class="btn btn-sm btn-outline-primary flex-fill" href="' + ctx + '/course-notes"><i class="bi bi-journal-text"></i> Notes</a>' +
        '<button class="btn btn-sm btn-outline-danger flex-fill" data-drop="' + c.id + '"><i class="bi bi-trash"></i> Remove</button></div>' +
      '</div></div></div>';
    }).join('');
  }
  function refresh() { limit(); catalog(); mine(); }

  var view = 'catalog', curLearn = null;
  function setView(v) {
    view = v;
    $('catalogView').hidden = v !== 'catalog'; $('mineView').hidden = v !== 'mine'; $('learnView').hidden = v !== 'learn'; $('enrTabs').hidden = v === 'learn';
    document.querySelectorAll('[data-view]').forEach(function (x) { x.classList.toggle('active', x.getAttribute('data-view') === (v === 'learn' ? 'mine' : v)); });
    window.scrollTo(0, 0);
  }
  document.querySelectorAll('[data-view]').forEach(function (b) { b.addEventListener('click', function () { setView(b.getAttribute('data-view')); }); });

  /* ---------- inside the course: lessons, progress, materials ---------- */
  var LESSON_NAMES = ['Video lesson', 'Practice activity', 'Quick quiz'], LESSON_ICONS = ['bi-play-circle', 'bi-pencil-square', 'bi-question-circle'];
  function lessonCount(c) { return c.topics.length * 3; }
  function entry(id) { return enrolled.filter(function (x) { return x.id === id; })[0]; }
  function doneOf(en, c) {
    if (!en.done) {   // old sample enrollments only have a % -> tick the first lessons that match it
      var all = [], n; c.topics.forEach(function (t, k) { [0, 1, 2].forEach(function (j) { all.push(k + '.' + j); }); });
      n = Math.round(en.progress * all.length / 100); en.done = all.slice(0, n);
    }
    return en.done;
  }
  function progressBits(en, c) {
    var total = lessonCount(c), done = doneOf(en, c).length;
    $('lBar').style.width = en.progress + '%'; $('lPct').textContent = en.progress + '%'; $('lCount').textContent = done + ' of ' + total + ' lessons completed';
    $('lCert').innerHTML = en.progress >= 100 ? '<span class="chip green"><i class="bi bi-patch-check-fill"></i> Course completed - certificate ready</span>' : '';
    c.topics.forEach(function (t, k) {
      var d = [0, 1, 2].filter(function (j) { return en.done.indexOf(k + '.' + j) >= 0; }).length, el = $('pc' + k); if (el) el.textContent = d + '/3';
    });
  }
  function openLearn(id) {
    var c = byId(id), en = entry(id); if (!c || !en) return;
    curLearn = id; doneOf(en, c);
    var ctx = document.body.dataset.ctx, rows = c.topics.map(function (t, k) {
      var items = [0, 1, 2].map(function (j) {
        var key = k + '.' + j;
        return '<label class="d-flex align-items-center gap-2 py-1"><input type="checkbox" class="form-check-input mt-0" data-lesson="' + key + '"' + (en.done.indexOf(key) >= 0 ? ' checked' : '') + '>' +
               '<i class="bi ' + LESSON_ICONS[j] + '"></i><span>' + LH.esc(t) + ' &ndash; ' + LESSON_NAMES[j] + '</span></label>';
      }).join('');
      return '<details class="syl"' + (k === 0 ? ' open' : '') + '><summary>Part ' + (k + 1) + ': ' + LH.esc(t) + ' <span class="chip ms-1" id="pc' + k + '"></span></summary>' + items + '</details>';
    }).join('');
    $('learnView').innerHTML =
      '<button class="btn btn-outline-secondary mb-3" id="lBack"><i class="bi bi-arrow-left"></i> My enrollments</button>' +
      '<div class="card mb-3"><div class="card-body d-flex flex-wrap gap-3 align-items-center">' +
        '<div class="course-banner mb-0" style="background:' + c.color + ';width:110px;height:95px">' + c.icon + '</div>' +
        '<div class="flex-fill"><div class="d-flex gap-1 flex-wrap mb-1"><span class="chip blue">' + LH.esc(c.cat) + '</span><span class="chip">' + LH.esc(c.diff) + '</span>' + payChip(en) + '</div>' +
          '<h3 class="fw-bold mb-1">' + LH.esc(c.name) + '</h3><div class="small text-muted"><i class="bi bi-person-video3"></i> ' + LH.esc(c.teacher) + ' &middot; <i class="bi bi-clock"></i> ' + c.weeks + ' weeks &middot; enrolled on ' + LH.fmtDate(en.date) + '</div></div></div></div>' +
      '<div class="row g-3"><div class="col-lg-8">' +
        '<div class="card mb-3"><div class="card-body"><div class="d-flex justify-content-between fw-bold"><span>Your progress</span><span id="lPct"></span></div>' +
          '<div class="progress thin my-2"><div class="progress-bar bg-success" id="lBar" style="width:0"></div></div>' +
          '<div class="d-flex justify-content-between flex-wrap gap-2 small"><span id="lCount"></span><span id="lCert"></span></div></div></div>' +
        '<div class="card mb-3"><div class="card-header"><i class="bi bi-list-check"></i> Lessons <span class="small text-muted">(tick a lesson when you finish it)</span></div><div class="card-body">' + rows + '</div></div>' +
        '<div class="card"><div class="card-header"><i class="bi bi-info-circle"></i> About this course</div><div class="card-body"><p>' + LH.esc(c.desc) + '</p>' +
          '<div class="fw-bold mb-1">What you will learn</div><ul class="mb-0">' + c.learn.map(function (x) { return '<li>' + LH.esc(x) + '</li>'; }).join('') + '</ul></div></div>' +
      '</div><div class="col-lg-4">' +
        '<div class="card mb-3"><div class="card-header"><i class="bi bi-grid"></i> Course tools</div><div class="card-body d-grid gap-2">' +
          '<a class="btn btn-outline-primary" href="' + ctx + '/course-notes"><i class="bi bi-journal-text"></i> Study materials</a>' +
          '<a class="btn btn-outline-primary" href="' + ctx + '/assignments"><i class="bi bi-clipboard-check"></i> Assignments</a>' +
          '<a class="btn btn-outline-primary" href="' + ctx + '/course-feedback"><i class="bi bi-star"></i> Rate this course</a>' +
          '<button class="btn btn-outline-danger" data-drop="' + c.id + '"><i class="bi bi-trash"></i> Remove this course</button></div></div>' +
        '<div class="card mb-3"><div class="card-header"><i class="bi bi-card-checklist"></i> Course facts</div><div class="card-body small">' +
          '<div class="py-1"><span class="text-muted">Instructor:</span> <strong>' + LH.esc(c.teacher) + '</strong></div><div class="py-1"><span class="text-muted">Schedule:</span> <strong>' + LH.esc(c.schedule) + '</strong></div>' +
          '<div class="py-1"><span class="text-muted">Language:</span> <strong>' + LH.esc(c.lang) + '</strong></div><div class="py-1"><span class="text-muted">Fee:</span> <strong>' + LH.price(c) + '</strong></div></div></div>' +
        '<div class="card"><div class="card-header"><i class="bi bi-clipboard-check"></i> Requirements</div><div class="card-body"><ul class="mb-0 small">' + c.reqs.map(function (x) { return '<li>' + LH.esc(x) + '</li>'; }).join('') + '</ul></div></div>' +
      '</div></div>';
    progressBits(en, c); setView('learn');
    $('lBack').addEventListener('click', function () { curLearn = null; if (location.hash) history.replaceState(null, '', location.pathname + location.search); mine(); setView('mine'); });
  }
  $('learnView').addEventListener('change', function (ev) {
    var cb = ev.target.closest('[data-lesson]'); if (!cb || !curLearn) return;
    var c = byId(curLearn), en = entry(curLearn), key = cb.getAttribute('data-lesson'), i = en.done.indexOf(key);
    if (cb.checked && i < 0) en.done.push(key);
    if (!cb.checked && i >= 0) en.done.splice(i, 1);
    en.progress = Math.round(en.done.length * 100 / lessonCount(c)); LH.save('enrolled', enrolled); progressBits(en, c);
    if (en.progress >= 100 && cb.checked) LH.toast('Course completed! Well done.');
  });
  document.addEventListener('click', function (ev) { var b = ev.target.closest('[data-open]'); if (b) openLearn(b.getAttribute('data-open')); });

  ['fSearch', 'fCat', 'fLevel', 'fPrice'].forEach(function (id) { $(id).addEventListener('input', catalog); });

  /* ---------- enroll modal: Payment tab + Free tab ---------- */
  function method() { return document.querySelector('input[name=emethod]:checked').value; }
  function showBox() {
    var m = method(); $('eBoxCard').hidden = m !== 'Card'; $('eBoxBank').hidden = m !== 'Bank transfer'; $('eBoxWallet').hidden = m !== 'Online wallet';
    $('eCardPrev').style.opacity = m === 'Card' ? 1 : .35;
  }
  function setTab(t) {
    var freeLeft = FREE_LIMIT - freeUsed();
    if (t === 'free' && freeLeft <= 0) t = 'pay';
    tab = t;
    document.querySelectorAll('[data-etab]').forEach(function (b) { b.classList.toggle('active', b.getAttribute('data-etab') === t); });
    $('panePay').hidden = t !== 'pay'; $('paneFree').hidden = t !== 'free'; $('eErr').textContent = '';
    $('eSubmit').innerHTML = t === 'pay' ? '<i class="bi bi-lock-fill"></i> Pay &amp; enroll' : '<i class="bi bi-check2-circle"></i> Enroll for free';
  }
  function freeTab() {
    var left = Math.max(0, FREE_LIMIT - freeUsed()), btn = $('tabFreeBtn');
    $('freeLeft').textContent = left + ' left';
    btn.disabled = left <= 0; btn.style.opacity = left <= 0 ? .5 : 1;
    btn.title = left <= 0 ? 'You have already used your ' + FREE_LIMIT + ' free enrollments. Payment is required.' : '';
    $('freeInfo').innerHTML = left > 0
      ? 'You can enroll in <strong>' + FREE_LIMIT + ' courses without payment</strong>. You have <strong>' + left + '</strong> free enrollment' + (left > 1 ? 's' : '') + ' left. After that every course needs a payment.'
      : 'You have used all ' + FREE_LIMIT + ' free enrollments. Please use the Payment tab.';
  }
  document.querySelectorAll('[data-etab]').forEach(function (b) {
    b.addEventListener('click', function () { if (!b.disabled) setTab(b.getAttribute('data-etab')); });
  });
  document.querySelectorAll('input[name=emethod]').forEach(function (r) { r.addEventListener('change', showBox); });
  $('eNum').addEventListener('input', function () {
    var v = this.value.replace(/\D/g, '').slice(0, 16); this.value = v.replace(/(.{4})/g, '$1 ').trim();
    var p = (v + '################').slice(0, 16).replace(/#/g, '•'); $('evNum').textContent = p.replace(/(.{4})/g, '$1 ').trim();
  });
  $('eName').addEventListener('input', function () { $('evName').textContent = this.value.trim() || 'Card holder'; });
  $('eExp').addEventListener('input', function () {
    var v = this.value.replace(/\D/g, '').slice(0, 4); if (v.length > 2) v = v.slice(0, 2) + '/' + v.slice(2); this.value = v; $('evExp').textContent = v || 'MM/YY';
  });
  $('eCvv').addEventListener('input', function () { this.value = this.value.replace(/\D/g, ''); });
  function luhn(n) {
    var s = 0, alt = false;
    for (var i = n.length - 1; i >= 0; i--) { var d = +n[i]; if (alt) { d *= 2; if (d > 9) d -= 9; } s += d; alt = !alt; }
    return s % 10 === 0;
  }

  $('catalog').addEventListener('click', function (e) {
    var b = e.target.closest('[data-enroll]'); if (!b) return;
    var c = byId(b.getAttribute('data-enroll')); pending = c;
    $('enrForm').reset(); $('evNum').innerHTML = '&bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull;';
    $('evName').textContent = 'Card holder'; $('evExp').textContent = 'MM/YY'; showBox(); freeTab(); setTab('pay');
    $('tabsRow').hidden = false; $('eCardPrev').hidden = false;
    if (c.fee === 0) {                                      // free course: no payment at all
      tab = 'course'; $('tabsRow').hidden = true; $('eCardPrev').hidden = true; $('panePay').hidden = true; $('paneFree').hidden = false;
      $('freeInfo').innerHTML = '<strong>This course is free.</strong> No payment is needed and it does not use your free enrollment slots.';
      $('eSubmit').innerHTML = '<i class="bi bi-check2-circle"></i> Enroll for free';
    }
    $('eCourse').textContent = c.name; $('eMeta').textContent = c.teacher + ' · ' + c.weeks + ' weeks'; $('eAmount').textContent = LH.price(c);
    LH.modal('enrollModal').show();
  });

  /* add the paid invoice to the Payment page history and remove the matching pending invoice */
  function recordPayment(c, m, ref, before, rc, date) {
    var seed = LH.seedPayments(COURSES, before);
    var hist = LH.load('pay-history', seed.history), pend = LH.load('pay-pending', seed.pending);
    hist.unshift({rcpt: rc, course: c.name, desc: 'Course fee - full payment', amount: c.fee, date: date || LH.today(), method: m, ref: ref});
    pend = pend.filter(function (p) { return !(p.course === c.name && String(p.desc).indexOf('Course fee') === 0); });
    LH.save('pay-history', hist); LH.save('pay-pending', pend);
    return rc;
  }
  function finish(entry, msg) {
    enrolled.push(entry); LH.save('enrolled', enrolled);
    LH.modal('enrollModal').hide(); refresh(); LH.toast(msg); pending = null;
  }
  $('enrForm').addEventListener('submit', function (e) {
    e.preventDefault();
    var c = pending; if (!c) return;
    if (enrolled.length >= MAX) return $('eErr').textContent = 'Enrollment limit reached for your membership.';
    if (isIn(c.id)) return $('eErr').textContent = 'You are already enrolled in this course.';
    if (seatsLeft(c) <= 0) return $('eErr').textContent = 'Sorry, this course is full.';

    if (tab === 'course') return finish({id: c.id, date: LH.today(), progress: 0, paid: 'free'}, 'Enrolled in ' + c.name + ' (free course)');
    if (tab === 'free') {                                   // ---- free enrollment (max 2 paid courses) ----
      if (freeUsed() >= FREE_LIMIT) { freeTab(); setTab('pay'); return $('eErr').textContent = 'No free enrollments left. Please pay to enroll.'; }
      return finish({id: c.id, date: LH.today(), progress: 0, paid: false}, 'Enrolled in ' + c.name + ' (free enrollment)');
    }

    // ---- paid enrollment: validate payment first ----
    var m = method(), ref = '';
    if (m === 'Card') {
      var n = $('eNum').value.replace(/\s/g, ''), ex = $('eExp').value.split('/'), mm = +ex[0], yy = +ex[1];
      if (n.length !== 16 || !luhn(n)) return $('eErr').textContent = 'Enter a valid 16-digit card number (demo tip: 4242 4242 4242 4242).';
      if ($('eName').value.trim().length < 3) return $('eErr').textContent = 'Enter the name on the card.';
      var now = new Date(), curYY = now.getFullYear() % 100, curMM = now.getMonth() + 1;
      if (!(mm >= 1 && mm <= 12) || isNaN(yy) || yy < curYY || (yy === curYY && mm < curMM)) return $('eErr').textContent = 'Card expiry is invalid or expired.';
      if (!/^\d{3,4}$/.test($('eCvv').value)) return $('eErr').textContent = 'Enter the 3 or 4 digit CVV.';
      ref = '**** ' + n.slice(-4);
    } else if (m === 'Bank transfer') {
      var f = $('eSlip').files[0]; if (!f) return $('eErr').textContent = 'Please upload your bank slip.'; ref = 'Slip: ' + f.name;
    } else {
      var w = $('eWal').value.replace(/\s/g, ''); if (!/^0\d{9}$/.test(w)) return $('eErr').textContent = 'Enter a valid 10-digit mobile number.'; ref = w.slice(0, 3) + ' *** ' + w.slice(-4);
    }
    $('eErr').textContent = '';
    var btn = $('eSubmit'); btn.disabled = true; btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processing...';
    var before = enrolled.slice();
    /* save the payment on the server first, so it shows up on the admin's Payment page */
    var body = new URLSearchParams({course: c.name, desc: 'Course fee - full payment', amount: c.fee, method: m, ref: ref});
    fetch(document.getElementById('meData').dataset.ctx + '/payment-records', {method: 'POST', body: body, credentials: 'same-origin'}).catch(function () { return null; })
      .then(function (r) { return r ? r.json().catch(function () { return null; }) : null; })
      .then(function (j) {
        btn.disabled = false; btn.innerHTML = '<i class="bi bi-lock-fill"></i> Pay &amp; enroll';
        if (!j || !j.ok) return $('eErr').textContent = (j && j.error) || 'Could not record the payment. Please try again.';
        var rc = recordPayment(c, m, ref, before, j.rcpt, j.date);
        finish({id: c.id, date: LH.today(), progress: 0, paid: true, rcpt: rc}, 'Payment successful. Enrolled in ' + c.name);
      });
  });
  var dropping = null;
  document.addEventListener('click', function (ev) {
    var g = ev.target.closest('[data-view-go]'); if (g) { setView(g.getAttribute('data-view-go')); return; }
    var b = ev.target.closest('[data-drop]'); if (!b) return;
    var c = byId(b.getAttribute('data-drop')), en = entry(c.id); if (!c || !en) return;
    dropping = c;
    var note = en.paid === 'free' ? 'This is a free course, so you can enroll again at any time.'
      : en.paid === false ? 'This course used one of your free enrollments. Removing it gives that free enrollment back.'
      : 'You paid for this course. <strong>The fee is not refunded</strong> and you will need to pay again to re-enroll.';
    $('dropBody').innerHTML = '<p>Remove <strong>' + LH.esc(c.name) + '</strong> from your enrollments?</p><ul class="mb-2"><li>Your progress (' + en.progress + '%) will be lost.</li><li>' + note + '</li></ul>';
    LH.modal('dropModal').show();
  });
  $('dropConfirm').addEventListener('click', function () {
    if (!dropping) return;
    var c = dropping; dropping = null;
    enrolled = enrolled.filter(function (x) { return x.id !== c.id; });
    LH.save('enrolled', enrolled); LH.modal('dropModal').hide();
    if (view === 'learn') { curLearn = null; if (location.hash) history.replaceState(null, '', location.pathname + location.search); setView('mine'); }
    refresh(); LH.toast('Removed ' + c.name, 'info');
  });
  refresh();
  /* coming from Course Details (#C103): scroll to that course and highlight it */
  var hid = location.hash.replace('#', ''); if (hid.indexOf('learn-') === 0) { var lid = hid.slice(6); hid = ''; if (isIn(lid)) openLearn(lid); }
  var target = hid && document.querySelector('[data-cid="' + hid + '"] .card');
  if (target) {
    target.classList.add('pulse'); target.scrollIntoView({block: 'center'}); setTimeout(function () { target.classList.remove('pulse'); }, 3500);
    var eb = document.querySelector('[data-cid="' + hid + '"] [data-enroll]');   // not enrolled yet -> open the payment tab straight away
    if (eb) setTimeout(function () { eb.click(); }, 350);
  }
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
