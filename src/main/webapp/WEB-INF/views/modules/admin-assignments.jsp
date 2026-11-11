<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Manage Assignments"/></jsp:include>

<%-- ADMIN view. Assignments are split by learner level (Child / Grade 1-11 / A/L / Undergraduate), the same four parts as
     Course Details and Enrollment. The admin sees what every student submitted, opens the file and gives the marks. --%>
<div class="glass-bar mod-hero">
  <div class="mod-title">
    <div class="mod-ico">&#128203;</div>
    <div><h3>Assignments</h3><p>Admin: create assignments for each learner level, open the students' submissions and give marks.</p></div>
  </div>
  <button class="btn btn-primary" id="btnNew"><i class="bi bi-plus-circle"></i> New assignment</button>
</div>

<div class="card mb-3"><div class="card-body">
  <div class="small text-muted mb-2"><i class="bi bi-diagram-3"></i> Assignments are split by learner level. Students only see the assignments of their own level.</div>
  <div class="mod-tabs" id="lvTabs"></div>
</div></div>

<div class="row g-3 mb-3" id="stats"></div>

<div class="card mb-3"><div class="card-body"><div class="mod-filter">
  <input type="search" id="fSearch" class="form-control grow" placeholder="Search assignments...">
  <select id="fCourse" class="form-select"></select>
  <select id="fState" class="form-select">
    <option value="">All assignments</option><option value="wait">Needs marking</option><option value="done">All marked</option><option value="none">No submissions yet</option>
  </select>
</div></div></div>

<div id="list" class="row g-3"></div>

<!-- Submissions of one assignment (list of students) / marking one student -->
<div class="modal fade" id="subModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title" id="subTitle">Submissions</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body" id="subBody"></div>
    </div>
  </div>
</div>

<!-- Create / edit assignment -->
<div class="modal fade" id="formModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <form class="modal-content" id="asgForm" novalidate>
      <div class="modal-header"><h5 class="modal-title" id="fHead">Create assignment</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <input type="hidden" id="fId">
        <div class="mb-3"><label class="form-label">Learner level</label><select id="fLevel" class="form-select"></select></div>
        <div class="mb-3"><label class="form-label">Course</label><select id="fCourseSel" class="form-select"></select></div>
        <div class="mb-3"><label class="form-label">Title</label><input id="fTitle" class="form-control" maxlength="90"></div>
        <div class="row g-2 mb-3">
          <div class="col-6"><label class="form-label">Due date</label><input type="date" id="fDue" class="form-control"></div>
          <div class="col-6"><label class="form-label">Total marks</label><input type="number" id="fMarks" class="form-control" value="100" min="1" max="1000"></div>
        </div>
        <div class="mb-3"><label class="form-label">Instructions</label><textarea id="fDesc" class="form-control" rows="3" maxlength="400"></textarea></div>
        <div class="alert alert-info py-2 small d-none" id="fLock"></div>
        <div class="text-danger small" id="fErr"></div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary" id="fSave">Create</button></div>
    </form>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/roster.jsp"/>
<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="true" data-level="" data-detail="" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var $ = function (id) { return document.getElementById(id); };
  var ROSTER = getRoster();
  var defs = LH.load('adm-asg', null);
  if (!defs) { defs = LH.seedLevelAssignments(); LH.save('adm-asg', defs); }   // first visit: the starter assignments become the admin's list
  var subs = {}, grades = {};                  // subs[studentId][assignmentId] = {submitted, file, fileId, note};  grades[studentId][assignmentId] = {score, feedback, on}
  var curLv = 'ALL', openId = null;
  function persist() { LH.save('adm-asg', defs); }
  function lvInfo(code) { return LH.LEVELS.filter(function (l) { return l.code === code; })[0] || {tab: code, icon: '', name: code}; }
  function byId(id) { return defs.filter(function (d) { return d.id === +id; })[0]; }
  function stu(id) { return ROSTER.filter(function (r) { return r.id === id; })[0] || {id: id, name: id, lv: '', detail: ''}; }
  function sub(sid, aid) { return subs[sid] && subs[sid][aid]; }
  function grade(sid, aid) { return grades[sid] && grades[sid][aid]; }
  function inScope() { return defs.filter(function (d) { return curLv === 'ALL' || d.lv === curLv; }); }

  /* students that get this assignment: same level + a course that suits them (+ anybody who already submitted) */
  function students(d) {
    return ROSTER.filter(function (r) {
      if (r.lv !== d.lv) return false;
      if (sub(r.id, d.id)) return true;
      if (r.status === 'INACTIVE') return false;
      return LH.coursesFor(r.lv, r.detail).some(function (c) { return c.name === d.course; });
    }).sort(function (a, b) { return a.name.localeCompare(b.name); });
  }
  function counts(d) {
    var st = students(d), n = 0, g = 0;
    st.forEach(function (r) { if (sub(r.id, d.id)) { n++; if (grade(r.id, d.id)) g++; } });
    return {total: st.length, sub: n, graded: g, wait: n - g};
  }
  function loadSubmissions() {
    return fetch(LH.ctx() + '/store?action=submissions', {credentials: 'same-origin'}).then(function (r) { return r.json(); }).then(function (j) {
      subs = {}; grades = {};
      Object.keys(j.sub || {}).forEach(function (sid) { Object.keys(j.sub[sid]).forEach(function (k) { (subs[sid] = subs[sid] || {})[+k.replace('asg-s-', '')] = j.sub[sid][k]; }); });
      Object.keys(j.grade || {}).forEach(function (sid) { Object.keys(j.grade[sid]).forEach(function (k) { (grades[sid] = grades[sid] || {})[+k.replace('asg-g-', '')] = j.grade[sid][k]; }); });
    }).catch(function () { LH.toast('Could not load the submissions. Please refresh the page.', 'err'); });
  }

  /* ---------- page ---------- */
  function tabs() {
    var all = [{code: 'ALL', tab: 'All', icon: '&#128450;'}].concat(LH.LEVELS);
    $('lvTabs').innerHTML = all.map(function (l) {
      var n = l.code === 'ALL' ? defs.length : defs.filter(function (d) { return d.lv === l.code; }).length;
      return '<button type="button" class="mod-tab ' + (curLv === l.code ? 'active' : '') + '" data-lv="' + l.code + '">' + l.icon + ' ' + l.tab + '<span class="cnt">' + n + '</span></button>';
    }).join('');
  }
  function stats() {
    var sc = inScope(), sub = 0, wait = 0, gr = 0;
    sc.forEach(function (d) { var c = counts(d); sub += c.sub; wait += c.wait; gr += c.graded; });
    var cards = [['Assignments', sc.length, 'bi-clipboard-check-fill', ''], ['Submissions received', sub, 'bi-inbox-fill', 'cyan'],
                 ['Waiting for marks', wait, 'bi-hourglass-split', 'amber'], ['Marked', gr, 'bi-award-fill', 'green']];
    $('stats').innerHTML = cards.map(function (c) {
      return '<div class="col-md-3 col-6"><div class="card stat-card ' + c[3] + ' p-3"><span class="gicon"><i class="bi ' + c[2] + '"></i></span><div><div class="text-muted small">' + c[0] + '</div><div class="stat-number">' + c[1] + '</div></div></div></div>';
    }).join('');
  }
  function courseFilter() {
    var cur = $('fCourse').value, names = {};
    inScope().forEach(function (d) { names[d.course] = 1; });
    $('fCourse').innerHTML = '<option value="">All courses</option>' + Object.keys(names).sort().map(function (c) { return '<option>' + LH.esc(c) + '</option>'; }).join('');
    $('fCourse').value = names[cur] ? cur : '';
  }
  function list() {
    var q = $('fSearch').value.toLowerCase(), co = $('fCourse').value, st = $('fState').value;
    var rows = inScope().filter(function (d) {
      var c = counts(d);
      return (!co || d.course === co) && (!q || (d.title + ' ' + d.desc + ' ' + d.course).toLowerCase().indexOf(q) >= 0) &&
             (!st || (st === 'wait' ? c.wait > 0 : st === 'none' ? c.sub === 0 : (c.sub > 0 && c.wait === 0)));
    });
    rows.sort(function (a, b) { return a.due < b.due ? 1 : a.due > b.due ? -1 : b.id - a.id; });
    if (!rows.length) { $('list').innerHTML = '<div class="col-12"><div class="card"><div class="empty-state"><i class="bi bi-clipboard-x"></i>No assignments in this part. Use <strong>New assignment</strong> to add one.</div></div></div>'; return; }
    $('list').innerHTML = rows.map(function (d) {
      var c = counts(d), li = lvInfo(d.lv), overdue = LH.daysFrom(d.due) < 0;
      return '<div class="col-lg-6"><div class="card h-100"><div class="card-body d-flex flex-column">' +
        '<div class="d-flex justify-content-between align-items-start gap-2"><div><h6 class="fw-bold mb-1">' + LH.esc(d.title) + '</h6><span class="chip">' + LH.esc(d.course) + '</span> <span class="chip blue">' + li.icon + ' ' + LH.esc(li.tab) + '</span></div>' +
          (c.wait > 0 ? '<span class="chip amber">' + c.wait + ' to mark</span>' : c.sub > 0 ? '<span class="chip green">All marked</span>' : '<span class="chip">No submissions</span>') + '</div>' +
        '<p class="small mt-2 mb-2">' + LH.esc(d.desc) + '</p>' +
        '<div class="d-flex justify-content-between align-items-center small"><span class="' + (overdue ? 'text-muted' : 'fw-bold') + '"><i class="bi bi-calendar-event"></i> Due ' + LH.fmtDate(d.due) + (overdue ? ' (closed)' : '') + '</span><span class="text-muted">' + d.marks + ' marks</span></div>' +
        '<div class="mod-tile mt-2 small d-flex justify-content-between flex-wrap gap-2"><span><i class="bi bi-people"></i> ' + c.total + ' student' + (c.total === 1 ? '' : 's') + '</span><span><i class="bi bi-inbox"></i> ' + c.sub + ' submitted</span><span><i class="bi bi-award"></i> ' + c.graded + ' marked</span></div>' +
        '<div class="flex-fill"></div><div class="d-flex justify-content-end gap-2 mt-3">' +
          '<button class="btn btn-sm btn-primary" data-open="' + d.id + '"><i class="bi bi-check2-square"></i> Submissions &amp; marks</button>' +
          '<button class="btn btn-sm btn-outline-secondary" data-edit="' + d.id + '" title="Edit"><i class="bi bi-pencil-square"></i></button>' +
          '<button class="btn btn-sm btn-outline-danger" data-del="' + d.id + '" title="Delete"><i class="bi bi-trash"></i></button></div>' +
        '</div></div></div>';
    }).join('');
  }
  function refresh() { tabs(); stats(); courseFilter(); list(); }

  $('lvTabs').addEventListener('click', function (e) { var b = e.target.closest('[data-lv]'); if (b) { curLv = b.getAttribute('data-lv'); $('fCourse').value = ''; refresh(); } });
  ['fSearch', 'fCourse', 'fState'].forEach(function (id) { $(id).addEventListener('input', list); });
  $('list').addEventListener('click', function (e) {
    var o = e.target.closest('[data-open]'), ed = e.target.closest('[data-edit]'), de = e.target.closest('[data-del]');
    if (o) openSubs(+o.getAttribute('data-open'));
    if (ed) openForm(byId(ed.getAttribute('data-edit')));
    if (de) {
      var d = byId(de.getAttribute('data-del')), c = counts(d);
      if (confirm('Delete "' + d.title + '"?' + (c.sub ? '\n\n' + c.sub + ' student submission(s) will no longer be shown.' : ''))) {
        defs = defs.filter(function (x) { return x.id !== d.id; }); persist(); refresh(); LH.toast('Assignment deleted', 'info');
      }
    }
  });

  /* ---------- submissions + marking ---------- */
  function fileUrl(sid, s, dl) {
    return LH.ctx() + '/files?kind=submission&id=' + encodeURIComponent(s.fileId) + '&name=' + encodeURIComponent(s.file || '') + '&uid=' + encodeURIComponent(sid) + (dl ? '&dl=1' : '');
  }
  function fileBtns(sid, s) {
    if (!s || !s.fileId) return '<span class="text-muted small">no file</span>';
    return '<a class="btn btn-sm btn-outline-primary" href="' + fileUrl(sid, s, false) + '" target="_blank" rel="noopener"><i class="bi bi-eye"></i> View</a> ' +
           '<a class="btn btn-sm btn-outline-primary" href="' + fileUrl(sid, s, true) + '" download><i class="bi bi-download"></i></a>';
  }
  function openSubs(id) {
    openId = id; $('subBody').innerHTML = '<div class="text-center text-muted py-4">Loading...</div>';
    LH.modal('subModal').show();
    loadSubmissions().then(function () { subList(); refresh(); });
  }
  function subList() {
    var d = byId(openId); if (!d) return;
    var li = lvInfo(d.lv), st = students(d);
    $('subTitle').textContent = d.title;
    var head = '<div class="mod-tile mb-3 small d-flex justify-content-between flex-wrap gap-2"><span><strong>' + LH.esc(d.course) + '</strong> &middot; ' + li.icon + ' ' + LH.esc(li.tab) + '</span><span>Due ' + LH.fmtDate(d.due) + ' &middot; ' + d.marks + ' marks</span></div>';
    if (!st.length) { $('subBody').innerHTML = head + '<div class="empty-state"><i class="bi bi-people"></i>No students at this level have this course yet.</div>'; return; }
    $('subBody').innerHTML = head + '<div class="table-responsive"><table class="table table-hover align-middle mb-0"><thead class="table-light"><tr><th>Student</th><th>Status</th><th>Submitted</th><th>File</th><th>Marks</th><th class="text-end">Action</th></tr></thead><tbody>' +
      st.map(function (r) {
        var s = sub(r.id, d.id), g = s && grade(r.id, d.id);
        var chip = !s ? '<span class="chip">Not submitted</span>' : g ? '<span class="chip green">Marked</span>' : '<span class="chip blue">Submitted</span>';
        var late = s && s.submitted && s.submitted > d.due ? ' <span class="chip red">late</span>' : '';
        return '<tr><td><div class="d-flex align-items-center gap-2"><div class="avatar-chip" style="background:' + LH.colorFor(r.name) + ';width:34px;height:34px;font-size:.8rem">' + LH.esc(LH.initials(r.name)) + '</div>' +
            '<div><div class="fw-bold">' + LH.esc(r.name) + '</div><div class="small text-muted">' + LH.esc(r.id) + (r.detail ? ' &middot; ' + LH.esc(r.detail) : '') + '</div></div></div></td>' +
          '<td>' + chip + late + '</td><td class="text-nowrap">' + (s ? LH.fmtDate(s.submitted) : '-') + '</td><td class="text-nowrap">' + (s ? fileBtns(r.id, s) : '-') + '</td>' +
          '<td class="text-nowrap">' + (g ? '<strong>' + g.score + ' / ' + d.marks + '</strong>' : '-') + '</td>' +
          '<td class="text-end text-nowrap">' + (s ? '<button class="btn btn-sm btn-primary" data-grade="' + LH.esc(r.id) + '"><i class="bi bi-check2-square"></i> ' + (g ? 'Edit marks' : 'Give marks') + '</button>' : '') + '</td></tr>';
      }).join('') + '</tbody></table></div>';
  }
  function gradeView(sid) {
    var d = byId(openId), s = sub(sid, d.id), g = grade(sid, d.id), r = stu(sid); if (!s) return subList();
    $('subTitle').textContent = 'Marks - ' + r.name;
    $('subBody').innerHTML =
      '<button type="button" class="btn btn-sm btn-outline-secondary mb-3" id="gBack"><i class="bi bi-arrow-left"></i> All students</button>' +
      '<div class="mod-tile mb-3"><div class="fw-bold">' + LH.esc(d.title) + '</div><div class="small text-muted">' + LH.esc(d.course) + ' &middot; due ' + LH.fmtDate(d.due) + ' &middot; ' + d.marks + ' marks</div></div>' +
      '<div class="mod-tile mb-3 small"><div class="d-flex justify-content-between align-items-center gap-2 flex-wrap"><span><i class="bi bi-person"></i> <strong>' + LH.esc(r.name) + '</strong> (' + LH.esc(sid) + ') &middot; submitted ' + LH.fmtDate(s.submitted) +
        (s.submitted > d.due ? ' <span class="chip red">late</span>' : '') + '</span><span>' + fileBtns(sid, s) + '</span></div>' +
        (s.file ? '<div class="mt-1"><i class="bi bi-paperclip"></i> ' + LH.esc(s.file) + '</div>' : '') +
        (s.note ? '<div class="text-muted mt-1"><i class="bi bi-chat-left-text"></i> ' + LH.esc(s.note) + '</div>' : '') + '</div>' +
      '<div class="row g-3"><div class="col-sm-4"><label class="form-label">Marks (out of ' + d.marks + ')</label><input type="number" id="gScore" class="form-control" min="0" max="' + d.marks + '" step="0.5" value="' + (g ? g.score : '') + '"></div>' +
      '<div class="col-sm-8"><label class="form-label">Feedback for the student (optional)</label><textarea id="gFeed" class="form-control" rows="3" maxlength="500">' + LH.esc(g ? g.feedback : '') + '</textarea></div></div>' +
      '<div class="text-danger small mt-2" id="gErr"></div>' +
      '<div class="d-flex justify-content-end gap-2 mt-3"><button type="button" class="btn btn-outline-secondary" id="gCancel">Cancel</button><button type="button" class="btn btn-primary" id="gSave"><i class="bi bi-check2-circle"></i> Save marks</button></div>';
    $('gBack').onclick = $('gCancel').onclick = function () { $('subTitle').textContent = d.title; subList(); };
    $('gSave').onclick = function () {
      var v = $('gScore').value.trim(), n = parseFloat(v);
      if (v === '' || isNaN(n) || n < 0 || n > d.marks) return $('gErr').textContent = 'Enter marks between 0 and ' + d.marks + '.';
      var btn = $('gSave'); btn.disabled = true; $('gErr').textContent = 'Saving...';
      fetch(LH.ctx() + '/store', {method: 'POST', credentials: 'same-origin', headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
        body: new URLSearchParams({action: 'grade', owner: sid, aid: String(d.id), score: String(n), max: String(d.marks), feedback: $('gFeed').value.trim()}).toString()})
        .then(function (res) { return res.json().catch(function () { return {error: 'Could not save. Please log in again.'}; }); })
        .then(function (j) {
          if (j.error) throw new Error(j.error);
          (grades[sid] = grades[sid] || {})[d.id] = {score: n, feedback: $('gFeed').value.trim(), on: LH.today()};
          $('subTitle').textContent = d.title; subList(); refresh(); LH.toast('Marks saved for ' + r.name);
        })
        .catch(function (err) { $('gErr').textContent = err.message; btn.disabled = false; });
    };
  }
  $('subBody').addEventListener('click', function (e) { var g = e.target.closest('[data-grade]'); if (g) gradeView(g.getAttribute('data-grade')); });
  $('subModal').addEventListener('hidden.bs.modal', function () { openId = null; });

  /* ---------- create / edit ---------- */
  function fillCourses(lv, keep) {
    var cs = LH.levelCourses(lv);
    $('fCourseSel').innerHTML = cs.length ? cs.map(function (c) { return '<option>' + LH.esc(c.name) + '</option>'; }).join('') : '<option value="">No courses at this level</option>';
    if (keep) $('fCourseSel').value = keep;
  }
  $('fLevel').innerHTML = LH.LEVELS.map(function (l) { return '<option value="' + l.code + '">' + l.icon + ' ' + l.name + '</option>'; }).join('');
  $('fLevel').addEventListener('change', function () { fillCourses($('fLevel').value); });
  function openForm(d) {
    $('asgForm').reset(); $('fErr').textContent = ''; $('fId').value = d ? d.id : '';
    $('fHead').textContent = d ? 'Edit assignment' : 'Create assignment';
    $('fSave').innerHTML = d ? '<i class="bi bi-check2-circle"></i> Save changes' : '<i class="bi bi-plus-circle"></i> Create';
    var lv = d ? d.lv : (curLv === 'ALL' ? 'SCHOOL' : curLv);
    $('fLevel').value = lv; fillCourses(lv, d ? d.course : null);
    $('fLevel').disabled = $('fCourseSel').disabled = !!d;           // level + course of an existing assignment stay fixed (students may already have submitted)
    $('fLock').classList.toggle('d-none', !d); $('fLock').textContent = 'The level and the course stay the same, because students may already have submitted work. To move it to another level, create a new assignment.';
    $('fTitle').value = d ? d.title : ''; $('fDue').value = d ? d.due : LH.addDays(7); $('fMarks').value = d ? d.marks : 100; $('fDesc').value = d && d.desc !== 'No instructions.' ? d.desc : '';
    LH.modal('formModal').show();
  }
  $('btnNew').addEventListener('click', function () { openForm(null); });
  $('asgForm').addEventListener('submit', function (e) {
    e.preventDefault();
    var id = +$('fId').value, t = $('fTitle').value.trim(), m = parseInt($('fMarks').value, 10), lv = $('fLevel').value, co = $('fCourseSel').value;
    if (!co) return $('fErr').textContent = 'Please choose a course.';
    if (t.length < 3) return $('fErr').textContent = 'Please enter a title.';
    if (!$('fDue').value) return $('fErr').textContent = 'Please choose a due date.';
    if (!(m > 0) || m > 1000) return $('fErr').textContent = 'Total marks must be between 1 and 1000.';
    var desc = $('fDesc').value.trim() || 'No instructions.';
    if (id) { var d = byId(id); d.title = t; d.due = $('fDue').value; d.marks = m; d.desc = desc; }
    else {
      var nid = Math.floor((Date.now() - 1700000000000) / 1000);      // never re-used, so a deleted assignment can not mix with a new one
      while (byId(nid)) nid++;
      defs.push({id: nid, lv: lv, course: co, title: t, due: $('fDue').value, marks: m, desc: desc});
    }
    persist(); LH.modal('formModal').hide(); refresh(); LH.toast(id ? 'Assignment updated' : 'Assignment created');
  });

  refresh();
  loadSubmissions().then(refresh);
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
