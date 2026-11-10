<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Manage Enrollments"/></jsp:include>

<div class="glass-bar mod-hero">
  <div class="mod-title">
    <div class="mod-ico">&#127891;</div>
    <div><h3>Course Enrollment</h3><p>Admin: view, create, edit and delete the enrollments of every student.</p></div>
  </div>
  <button class="btn btn-primary" id="btnAdd"><i class="bi bi-plus-circle"></i> New enrollment</button>
</div>

<div class="card mb-3"><div class="card-body">
  <div class="small text-muted mb-2"><i class="bi bi-diagram-3"></i> Enrollments are split by learner level, the same four parts as Course Details.</div>
  <div class="mod-tabs" id="lvTabs"></div>
</div></div>

<div class="row g-3 mb-3" id="stats"></div>

<div class="card mb-3"><div class="card-body"><div class="mod-filter">
  <input type="search" id="fSearch" class="form-control grow" placeholder="Search by student name, student ID or course...">
  <select id="fCourse" class="form-select"></select>
  <select id="fPaid" class="form-select"><option value="">All payment types</option><option value="true">Paid</option><option value="false">Free slot</option><option value="free">Free course</option></select>
  <select id="fSort" class="form-select"><option value="new">Newest first</option><option value="student">Student A - Z</option><option value="course">Course A - Z</option><option value="prog">Highest progress</option></select>
</div></div></div>

<div class="card">
  <div class="table-responsive">
    <table class="table table-hover mb-0 align-middle">
      <thead class="table-light"><tr><th>#</th><th>Student</th><th>Course</th><th>Enrolled</th><th style="min-width:130px">Progress</th><th>Payment</th><th class="text-end">Actions</th></tr></thead>
      <tbody id="rows"></tbody>
    </table>
  </div>
</div>

<!-- View -->
<div class="modal fade" id="viewModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Enrollment details</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body" id="viewBody"></div>
      <div class="modal-footer justify-content-between">
        <button class="btn btn-outline-danger" id="viewDel"><i class="bi bi-trash"></i> Delete</button>
        <span><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button> <button class="btn btn-primary" id="viewEdit"><i class="bi bi-pencil-square"></i> Edit</button></span>
      </div>
    </div>
  </div>
</div>

<!-- Create / edit -->
<div class="modal fade" id="formModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <form class="modal-content" id="enrForm" novalidate>
      <div class="modal-header"><h5 class="modal-title" id="fTitle">New enrollment</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <input type="hidden" id="fId">
        <div class="mb-3"><label class="form-label">Learner level</label><select id="fLevel" class="form-select"></select></div>
        <div class="mb-3"><label class="form-label">Student</label><select id="fStudent" class="form-select"></select>
          <div class="form-text" id="fStuNote"></div></div>
        <div class="mb-3"><label class="form-label">Course <span class="text-muted small">(only courses that suit this student)</span></label><select id="fCourseSel" class="form-select"></select></div>
        <div class="row g-2 mb-2">
          <div class="col-sm-4"><label class="form-label">Enrolled on</label><input type="date" id="fDate" class="form-control"></div>
          <div class="col-sm-4"><label class="form-label">Progress (%)</label><input type="number" id="fProg" class="form-control" min="0" max="100" value="0"></div>
          <div class="col-sm-4"><label class="form-label">Payment</label><select id="fPay" class="form-select"><option value="true">Paid</option><option value="false">Free slot</option><option value="free">Free course</option></select></div>
        </div>
        <div class="text-danger small" id="fErr"></div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn btn-primary" id="fSave">Save</button></div>
    </form>
  </div>
</div>

<!-- Delete -->
<div class="modal fade" id="delModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered"><div class="modal-content">
    <div class="modal-header"><h5 class="modal-title"><i class="bi bi-trash"></i> Delete enrollment</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
    <div class="modal-body" id="delBody"></div>
    <div class="modal-footer"><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Keep it</button><button class="btn btn-danger" id="delOk"><i class="bi bi-trash"></i> Delete</button></div>
  </div></div>
</div>

<jsp:include page="/WEB-INF/views/common/roster.jsp"/>
<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="true" data-level="" data-detail="" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var $ = function (id) { return document.getElementById(id); };
  var ROSTER = getRoster(), COURSES = {};
  LH.allCourses().forEach(function (c) { COURSES[c.id] = c; });
  function stu(id) { return ROSTER.filter(function (r) { return r.id === id; })[0]; }
  var rows = LH.syncAdminSeed(ROSTER).enr;   /* also adds rows for students who registered after the first visit */
  var curLv = 'ALL', delId = null, viewId = null, FREE_LIMIT = 2;
  function persist() { LH.save('adm-enr', rows); }
  function lvOf(e) { var s = stu(e.sid); return s ? s.lv : (COURSES[e.cid] || {}).lv; }
  function lvInfo(code) { return LH.LEVELS.filter(function (l) { return l.code === code; })[0] || {tab: code, icon: '', name: code}; }
  function inScope() { return rows.filter(function (e) { return curLv === 'ALL' || lvOf(e) === curLv; }); }
  var PAY = {'true': ['green', 'Paid'], 'false': ['amber', 'Free slot'], 'free': ['blue', 'Free course']};
  function payChip(e) { var p = PAY[String(e.paid)] || PAY['true']; return '<span class="chip ' + p[0] + '">' + p[1] + '</span>'; }

  function tabs() {
    var defs = [{code: 'ALL', tab: 'All', icon: '&#128450;'}].concat(LH.LEVELS);
    $('lvTabs').innerHTML = defs.map(function (l) {
      var n = l.code === 'ALL' ? rows.length : rows.filter(function (e) { return lvOf(e) === l.code; }).length;
      return '<button type="button" class="mod-tab ' + (curLv === l.code ? 'active' : '') + '" data-lv="' + l.code + '">' + l.icon + ' ' + l.tab + '<span class="cnt">' + n + '</span></button>';
    }).join('');
  }
  function stats() {
    var sc = inScope(), students = new Set(sc.map(function (e) { return e.sid; })).size;
    var avg = sc.length ? Math.round(sc.reduce(function (t, e) { return t + e.progress; }, 0) / sc.length) : 0;
    var cards = [['Enrollments', sc.length, 'bi-mortarboard-fill', ''], ['Students enrolled', students, 'bi-people-fill', 'cyan'],
                 ['Average progress', avg + '%', 'bi-graph-up-arrow', 'green'], ['Completed', sc.filter(function (e) { return e.progress >= 100; }).length, 'bi-patch-check-fill', 'amber']];
    $('stats').innerHTML = cards.map(function (c) {
      return '<div class="col-md-3 col-6"><div class="card stat-card ' + c[3] + ' p-3"><span class="gicon"><i class="bi ' + c[2] + '"></i></span><div><div class="text-muted small">' + c[0] + '</div><div class="stat-number">' + c[1] + '</div></div></div></div>';
    }).join('');
  }
  function courseFilter() {
    var cur = $('fCourse').value, ids = {};
    inScope().forEach(function (e) { ids[e.cid] = 1; });
    $('fCourse').innerHTML = '<option value="">All courses</option>' + Object.keys(ids).map(function (id) { return COURSES[id]; }).filter(Boolean)
      .sort(function (a, b) { return a.name.localeCompare(b.name); }).map(function (c) { return '<option value="' + c.id + '">' + LH.esc(c.name) + '</option>'; }).join('');
    $('fCourse').value = ids[cur] ? cur : '';
  }
  function list() {
    var q = $('fSearch').value.toLowerCase(), co = $('fCourse').value, pa = $('fPaid').value, so = $('fSort').value;
    var out = inScope().filter(function (e) {
      var s = stu(e.sid) || {name: e.sid}, c = COURSES[e.cid] || {name: e.cid};
      return (!co || e.cid === co) && (!pa || String(e.paid) === pa) && (!q || (s.name + ' ' + e.sid + ' ' + c.name).toLowerCase().indexOf(q) >= 0);
    });
    out.sort(function (a, b) {
      var sa = stu(a.sid) || {name: a.sid}, sb = stu(b.sid) || {name: b.sid}, ca = COURSES[a.cid] || {name: ''}, cb = COURSES[b.cid] || {name: ''};
      if (so === 'student') return sa.name.localeCompare(sb.name);
      if (so === 'course') return ca.name.localeCompare(cb.name);
      if (so === 'prog') return b.progress - a.progress;
      return b.date < a.date ? -1 : b.date > a.date ? 1 : b.id - a.id;
    });
    if (!out.length) { $('rows').innerHTML = '<tr><td colspan="7"><div class="empty-state"><i class="bi bi-journal-x"></i>No enrollments in this part.</div></td></tr>'; return; }
    $('rows').innerHTML = out.map(function (e) {
      var s = stu(e.sid) || {name: 'Unknown student', lv: ''}, c = COURSES[e.cid] || {name: 'Removed course (' + e.cid + ')', icon: '?'};
      return '<tr><td class="text-muted small">' + e.id + '</td>' +
        '<td><div class="d-flex align-items-center gap-2"><div class="avatar-chip" style="background:' + LH.colorFor(s.name) + ';width:34px;height:34px;font-size:.8rem">' + LH.esc(LH.initials(s.name)) + '</div>' +
          '<div><div class="fw-bold">' + LH.esc(s.name) + '</div><div class="small text-muted">' + LH.esc(e.sid) + ' &middot; ' + LH.esc(lvInfo(s.lv).tab) + '</div></div></div></td>' +
        '<td>' + (c.icon || '') + ' ' + LH.esc(c.name) + '</td><td class="text-nowrap">' + LH.fmtDate(e.date) + '</td>' +
        '<td><div class="small mb-1">' + e.progress + '%</div><div class="progress thin"><div class="progress-bar ' + (e.progress >= 100 ? 'bg-success' : 'bg-info') + '" style="width:' + e.progress + '%"></div></div></td>' +
        '<td>' + payChip(e) + '</td>' +
        '<td class="text-end text-nowrap"><button class="btn btn-sm btn-outline-primary" data-view="' + e.id + '" title="View"><i class="bi bi-eye"></i></button> ' +
          '<button class="btn btn-sm btn-outline-secondary" data-edit="' + e.id + '" title="Edit"><i class="bi bi-pencil-square"></i></button> ' +
          '<button class="btn btn-sm btn-outline-danger" data-del="' + e.id + '" title="Delete"><i class="bi bi-trash"></i></button></td></tr>';
    }).join('');
  }
  function refresh() { tabs(); stats(); courseFilter(); list(); }

  $('lvTabs').addEventListener('click', function (e) { var b = e.target.closest('[data-lv]'); if (b) { curLv = b.getAttribute('data-lv'); $('fCourse').value = ''; refresh(); } });
  ['fSearch', 'fCourse', 'fPaid', 'fSort'].forEach(function (id) { $(id).addEventListener('input', list); });
  function byId(id) { return rows.filter(function (e) { return e.id === id; })[0]; }
  $('rows').addEventListener('click', function (e) {
    var v = e.target.closest('[data-view]'), ed = e.target.closest('[data-edit]'), d = e.target.closest('[data-del]');
    if (v) openView(+v.getAttribute('data-view'));
    if (ed) openForm(byId(+ed.getAttribute('data-edit')));
    if (d) askDelete(+d.getAttribute('data-del'));
  });

  /* ---------- view ---------- */
  function openView(id) {
    var en = byId(id); if (!en) return; viewId = id;
    var s = stu(en.sid) || {name: 'Unknown student', email: '-', lv: '', detail: '', member: '-'}, c = COURSES[en.cid] || {name: en.cid, teacher: '-', schedule: '-', weeks: '-', fee: 0, diff: '-'};
    function row(k, v) { return '<div class="d-flex justify-content-between gap-3 py-2 border-bottom"><span class="text-muted">' + k + '</span><strong class="text-end">' + v + '</strong></div>'; }
    $('viewBody').innerHTML =
      '<div class="d-flex align-items-center gap-3 mb-3"><div class="avatar-chip" style="background:' + LH.colorFor(s.name) + ';width:52px;height:52px">' + LH.esc(LH.initials(s.name)) + '</div>' +
        '<div><div class="fw-bold fs-5">' + LH.esc(s.name) + '</div><div class="small text-muted">' + LH.esc(en.sid) + ' &middot; ' + LH.esc(s.email) + '</div></div></div>' +
      row('Learner level', LH.esc(lvInfo(s.lv).tab) + (s.detail ? ' (' + LH.esc(s.detail) + ')' : '')) + row('Membership', LH.esc(s.member)) +
      row('Course', (c.icon || '') + ' ' + LH.esc(c.name)) + row('Instructor', LH.esc(c.teacher)) + row('Schedule', LH.esc(c.schedule)) +
      row('Course fee', c.fee ? LH.money(c.fee) : 'FREE') + row('Enrolled on', LH.fmtDate(en.date)) + row('Payment', payChip(en)) +
      '<div class="pt-3"><div class="d-flex justify-content-between small mb-1"><span>Progress</span><strong>' + en.progress + '%</strong></div><div class="progress thin"><div class="progress-bar bg-success" style="width:' + en.progress + '%"></div></div></div>';
    LH.modal('viewModal').show();
  }
  $('viewEdit').addEventListener('click', function () { var en = byId(viewId); LH.modal('viewModal').hide(); setTimeout(function () { openForm(en); }, 250); });
  $('viewDel').addEventListener('click', function () { var id = viewId; LH.modal('viewModal').hide(); setTimeout(function () { askDelete(id); }, 250); });

  /* ---------- create / edit ---------- */
  function fillStudents(lv, keepId) {
    var list = ROSTER.filter(function (r) { return (!lv || r.lv === lv) && (r.status !== 'INACTIVE' || r.id === keepId); });
    $('fStudent').innerHTML = list.length ? list.map(function (r) { return '<option value="' + LH.esc(r.id) + '">' + LH.esc(r.id + ' - ' + r.name + (r.status === 'INACTIVE' ? ' (inactive)' : '')) + '</option>'; }).join('') : '<option value="">No students at this level</option>';
    if (keepId) $('fStudent').value = keepId;
  }
  function fillCourses(keepCid) {
    var s = stu($('fStudent').value), list = s ? LH.coursesFor(s.lv, s.detail) : [];
    if (keepCid && !list.some(function (c) { return c.id === keepCid; }) && COURSES[keepCid]) list = list.concat([COURSES[keepCid]]);
    $('fCourseSel').innerHTML = list.length ? list.map(function (c) { return '<option value="' + c.id + '">' + LH.esc(c.name) + (c.fee ? ' - ' + LH.money(c.fee) : ' - FREE') + '</option>'; }).join('') : '<option value="">No courses</option>';
    if (keepCid) $('fCourseSel').value = keepCid;
    $('fStuNote').textContent = s ? s.member + ' member - course limit ' + s.max + (s.detail ? ' - ' + s.detail : '') : '';
  }
  function syncPay() {                               // a free course is always "Free course"; a paid course cannot be "Free course"
    var c = COURSES[$('fCourseSel').value], free = c && c.fee === 0;
    Array.prototype.forEach.call($('fPay').options, function (o) { o.disabled = free ? o.value !== 'free' : o.value === 'free'; });
    if ($('fPay').selectedOptions[0] && $('fPay').selectedOptions[0].disabled) $('fPay').value = free ? 'free' : 'true';
  }
  $('fLevel').innerHTML = LH.LEVELS.map(function (l) { return '<option value="' + l.code + '">' + l.icon + ' ' + l.name + '</option>'; }).join('');
  $('fLevel').addEventListener('change', function () { fillStudents($('fLevel').value); fillCourses(); syncPay(); });
  $('fStudent').addEventListener('change', function () { fillCourses(); syncPay(); });
  $('fCourseSel').addEventListener('change', syncPay);
  function openForm(en) {
    $('enrForm').reset(); $('fErr').textContent = ''; $('fId').value = en ? en.id : '';
    var lv = en ? lvOf(en) : (curLv === 'ALL' ? 'UNDERGRAD' : curLv);
    $('fTitle').textContent = en ? 'Edit enrollment #' + en.id : 'New enrollment';
    $('fSave').innerHTML = en ? '<i class="bi bi-check2-circle"></i> Save changes' : '<i class="bi bi-plus-circle"></i> Enroll student';
    $('fLevel').value = lv; $('fLevel').disabled = !!en; $('fStudent').disabled = !!en;   // the student of an enrollment cannot be swapped: delete + create instead
    fillStudents(lv, en ? en.sid : null); fillCourses(en ? en.cid : null);
    $('fDate').value = en ? en.date : LH.today(); $('fProg').value = en ? en.progress : 0;
    syncPay(); if (en) $('fPay').value = String(en.paid);
    LH.modal('formModal').show();
  }
  $('btnAdd').addEventListener('click', function () { openForm(null); });
  $('enrForm').addEventListener('submit', function (ev) {
    ev.preventDefault();
    var id = +$('fId').value, sid = $('fStudent').value, cid = $('fCourseSel').value, prog = parseInt($('fProg').value, 10), paid = $('fPay').value, date = $('fDate').value;
    var s = stu(sid), c = COURSES[cid];
    if (!s) return $('fErr').textContent = 'Please choose a student.';
    if (!c) return $('fErr').textContent = 'Please choose a course.';
    if (!date) return $('fErr').textContent = 'Please choose the enrollment date.';
    if (isNaN(prog) || prog < 0 || prog > 100) return $('fErr').textContent = 'Progress must be between 0 and 100.';
    if (rows.some(function (x) { return x.sid === sid && x.cid === cid && x.id !== id; })) return $('fErr').textContent = s.name + ' is already enrolled in this course.';
    if (!id && rows.filter(function (x) { return x.sid === sid; }).length >= s.max) return $('fErr').textContent = s.name + ' has reached the enrollment limit (' + s.max + ' for ' + s.member + ' members).';
    if (paid === 'false' && rows.filter(function (x) { return x.sid === sid && x.paid === false && x.id !== id; }).length >= FREE_LIMIT) return $('fErr').textContent = 'This student has already used the ' + FREE_LIMIT + ' free enrollments.';
    if (!id && c.seats - c.taken - rows.filter(function (x) { return x.cid === cid; }).length <= 0) return $('fErr').textContent = 'This course is full.';
    var val = paid === 'free' ? 'free' : paid === 'false' ? false : true;
    if (id) { var en = byId(id); en.cid = cid; en.date = date; en.progress = prog; en.paid = val; }
    else rows.push({id: rows.reduce(function (m, x) { return Math.max(m, x.id); }, 0) + 1, sid: sid, cid: cid, date: date, progress: prog, paid: val});
    persist(); LH.modal('formModal').hide(); refresh(); LH.toast(id ? 'Enrollment updated' : 'Student enrolled');
  });

  /* ---------- delete ---------- */
  function askDelete(id) {
    var en = byId(id); if (!en) return; delId = id;
    var s = stu(en.sid) || {name: en.sid}, c = COURSES[en.cid] || {name: en.cid};
    $('delBody').innerHTML = '<p>Delete the enrollment of <strong>' + LH.esc(s.name) + '</strong> (' + LH.esc(en.sid) + ') in <strong>' + LH.esc(c.name) + '</strong>?</p><ul class="mb-0"><li>Their progress (' + en.progress + '%) will be lost.</li><li>The student can be enrolled again later.</li></ul>';
    LH.modal('delModal').show();
  }
  $('delOk').addEventListener('click', function () {
    rows = rows.filter(function (x) { return x.id !== delId; }); delId = null; persist(); LH.modal('delModal').hide(); refresh(); LH.toast('Enrollment deleted', 'info');
  });
  refresh();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
