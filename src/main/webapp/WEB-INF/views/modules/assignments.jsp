<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Assignments"/></jsp:include>

<%-- STUDENT view. The assignments are created by the admin for each learner level (admin-assignments.jsp);
     a student sees the ones for his / her own level, submits a file, and later sees the marks the admin gave. --%>
<div class="glass-bar mod-hero">
  <div class="mod-title">
    <div class="mod-ico">&#128203;</div>
    <div><h3>Assignments</h3><p>Track deadlines, submit your work and see your marks.</p></div>
  </div>
</div>

<div class="row g-3 mb-3" id="stats"></div>

<div class="card mb-3"><div class="card-body">
  <div class="mod-filter mb-3">
    <input type="search" id="fSearch" class="form-control grow" placeholder="Search assignments...">
    <select id="fCourse" class="form-select"></select>
  </div>
  <div class="mod-tabs" id="tabs"></div>
</div></div>

<div id="list" class="row g-3"></div>

<!-- Submit (student) -->
<div class="modal fade" id="submitModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <form class="modal-content" id="submitForm" novalidate>
      <div class="modal-header"><h5 class="modal-title">Submit assignment</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mod-tile mb-3"><div class="fw-bold" id="sTitle"></div><div class="small text-muted" id="sMeta"></div></div>
        <div class="mb-3"><label class="form-label">Your file</label><input type="file" id="sFile" class="form-control" accept=".pdf,.doc,.docx,.zip,.txt,.py,.java,.png,.jpg,.jpeg"><div class="form-text">PDF, Word, ZIP, source code or a photo (JPG / PNG). Max 10 MB. You can open your file again after submitting.</div></div>
        <div class="mb-3"><label class="form-label">Comment for the teacher (optional)</label><textarea id="sNote" class="form-control" rows="3" maxlength="300"></textarea></div>
        <div class="alert alert-warning py-2 small d-none" id="sLate"><i class="bi bi-exclamation-triangle"></i> This assignment is past its deadline. Late work may lose marks.</div>
        <div class="text-danger small" id="sErr"></div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary"><i class="bi bi-send-check"></i> Submit</button></div>
    </form>
  </div>
</div>

<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="${currentUser.canManageUsers()}" data-level="${currentUser.level.code}" data-detail="<c:out value='${currentUser.levelDetail}'/>" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var $ = function (id) { return document.getElementById(id); };
  var LEVEL = $('meData').dataset.level;
  var tab = 'all', current = null, items = [];

  /* assignments of MY level (created by the admin) + my own submission (asg-s-ID) + the marks the admin gave (asg-g-ID).
     status: todo | submitted | graded.  "Overdue" is worked out from the due date. */
  function build() {
    var defs = LH.load('adm-asg', null) || LH.seedLevelAssignments(), mine = LH.names();
    items = defs.filter(function (d) { return d.lv === LEVEL && mine.indexOf(d.course) >= 0; }).map(function (d) {
      var a = Object.assign({}, d), sub = LH.load('asg-s-' + d.id, null), g = LH.load('asg-g-' + d.id, null);
      a.status = 'todo';
      if (sub) { a.status = 'submitted'; a.submitted = sub.submitted; a.file = sub.file; a.fileId = sub.fileId; a.note = sub.note; }
      if (sub && g) { a.status = 'graded'; a.score = g.score; a.feedback = g.feedback; }
      return a;
    });
  }
  function fillCourses() {
    var cur = $('fCourse').value, names = {};
    items.forEach(function (a) { names[a.course] = 1; });
    $('fCourse').innerHTML = '<option value="">All courses</option>' + Object.keys(names).sort().map(function (c) { return '<option>' + LH.esc(c) + '</option>'; }).join('');
    $('fCourse').value = names[cur] ? cur : '';
  }

  function state(a) { return a.status === 'todo' && LH.daysFrom(a.due) < 0 ? 'overdue' : a.status; }
  function chip(a) {
    var s = state(a);
    return s === 'graded' ? '<span class="chip green">Graded</span>' : s === 'submitted' ? '<span class="chip blue">Submitted</span>' :
           s === 'overdue' ? '<span class="chip red">Overdue</span>' : '<span class="chip amber">Pending</span>';
  }
  function due(a) {
    var d = LH.daysFrom(a.due);
    if (a.status !== 'todo') return '<span class="text-muted small"><i class="bi bi-calendar-event"></i> Due ' + LH.fmtDate(a.due) + '</span>';
    var txt = d < 0 ? Math.abs(d) + ' day' + (d === -1 ? '' : 's') + ' late' : d === 0 ? 'Due today' : d + ' day' + (d === 1 ? '' : 's') + ' left';
    return '<span class="small ' + (d < 0 ? 'text-danger' : d <= 3 ? 'text-warning' : 'text-muted') + ' fw-bold"><i class="bi bi-alarm"></i> ' + txt + ' &middot; ' + LH.fmtDate(a.due) + '</span>';
  }
  /* the student's own submitted file: View (opens it again) and Download (saves it to the device) */
  function fileRow(a) {
    if (!a.fileId) return '';
    return '<div class="mod-tile mt-2 small"><div class="d-flex justify-content-between align-items-center gap-2 flex-wrap"><span><i class="bi bi-paperclip"></i> <strong>' + LH.esc(a.file) + '</strong> &middot; submitted ' + LH.fmtDate(a.submitted) + '</span>' +
      '<span class="d-flex gap-1"><button type="button" class="btn btn-sm btn-outline-primary" data-view="' + a.id + '"><i class="bi bi-eye"></i> View</button>' +
      '<button type="button" class="btn btn-sm btn-outline-primary" data-dlf="' + a.id + '"><i class="bi bi-download"></i> Download</button></span></div>' +
      (a.note ? '<div class="text-muted mt-1"><i class="bi bi-chat-left-text"></i> ' + LH.esc(a.note) + '</div>' : '') + '</div>';
  }
  function fileUrlOf(a, dl) { return LH.fileUrl('submission', a.fileId, a.file, dl); }
  function stats() {
    var cnt = function (s) { return items.filter(function (a) { return state(a) === s; }).length; };
    var graded = items.filter(function (a) { return a.status === 'graded'; });
    var avg = graded.length ? Math.round(graded.reduce(function (t, a) { return t + a.score * 100 / a.marks; }, 0) / graded.length) + '%' : '-';
    var cards = [['Pending', cnt('todo'), 'bi-hourglass-split', 'amber'], ['Overdue', cnt('overdue'), 'bi-exclamation-triangle-fill', 'red'],
                 ['Submitted', cnt('submitted'), 'bi-send-check-fill', 'cyan'], ['Average score', avg, 'bi-award-fill', 'green']];
    $('stats').innerHTML = cards.map(function (c) {
      return '<div class="col-md-3 col-6"><div class="card stat-card ' + c[3] + ' p-3"><span class="gicon"><i class="bi ' + c[2] + '"></i></span><div><div class="text-muted small">' + c[0] + '</div><div class="stat-number">' + c[1] + '</div></div></div></div>';
    }).join('');
  }
  function tabs() {
    var defs = [['all', 'All'], ['todo', 'Pending'], ['overdue', 'Overdue'], ['submitted', 'Submitted'], ['graded', 'Graded']];
    $('tabs').innerHTML = defs.map(function (d) {
      var n = d[0] === 'all' ? items.length : items.filter(function (a) { return state(a) === d[0]; }).length;
      return '<button type="button" class="mod-tab ' + (tab === d[0] ? 'active' : '') + '" data-tab="' + d[0] + '">' + d[1] + '<span class="cnt">' + n + '</span></button>';
    }).join('');
  }
  function render() {
    var q = $('fSearch').value.toLowerCase(), co = $('fCourse').value;
    var rows = items.filter(function (a) { return (tab === 'all' || state(a) === tab) && (!co || a.course === co) && (!q || (a.title + ' ' + a.desc + ' ' + a.course).toLowerCase().indexOf(q) >= 0); });
    rows.sort(function (a, b) { return a.due < b.due ? -1 : a.due > b.due ? 1 : 0; });
    stats(); tabs();
    if (!rows.length) { $('list').innerHTML = '<div class="col-12"><div class="card"><div class="empty-state"><i class="bi bi-clipboard-check"></i>' + (items.length ? 'No assignments here. Nice and clear!' : 'No assignments for you yet. Your teacher will add them here.') + '</div></div></div>'; return; }
    $('list').innerHTML = rows.map(function (a) {
      var s = state(a), body = '';
      if (s === 'graded') {
        var pct = Math.round(a.score * 100 / a.marks);
        body = fileRow(a) + '<div class="mod-tile mt-2"><div class="d-flex justify-content-between"><strong>Score: ' + a.score + ' / ' + a.marks + '</strong><span class="chip ' + (pct >= 75 ? 'green' : pct >= 50 ? 'amber' : 'red') + '">' + pct + '%</span></div>' +
               '<div class="progress thin my-2"><div class="progress-bar ' + (pct >= 75 ? 'bg-success' : pct >= 50 ? 'bg-warning' : 'bg-danger') + '" style="width:' + pct + '%"></div></div>' +
               '<div class="small"><i class="bi bi-chat-left-text"></i> ' + LH.esc(a.feedback || 'No feedback.') + '</div></div>';
      } else if (s === 'submitted') {
        body = fileRow(a) + '<div class="small text-muted mt-1">Waiting for the teacher to grade.</div>';
      }
      var actions = s === 'todo' || s === 'overdue' ? '<button class="btn btn-sm btn-primary" data-submit="' + a.id + '"><i class="bi bi-upload"></i> Submit</button>'
          : s === 'submitted' ? '<button class="btn btn-sm btn-outline-secondary" data-undo="' + a.id + '"><i class="bi bi-arrow-counterclockwise"></i> Unsubmit</button>' : '';
      return '<div class="col-lg-6"><div class="card h-100"><div class="card-body d-flex flex-column">' +
        '<div class="d-flex justify-content-between align-items-start gap-2"><div><h6 class="fw-bold mb-1">' + LH.esc(a.title) + '</h6><span class="chip">' + LH.esc(a.course) + '</span></div>' + chip(a) + '</div>' +
        '<p class="small mt-2 mb-2">' + LH.esc(a.desc) + '</p>' +
        '<div class="d-flex justify-content-between align-items-center">' + due(a) + '<span class="small text-muted">' + a.marks + ' marks</span></div>' + body +
        '<div class="flex-fill"></div><div class="d-flex justify-content-end gap-2 mt-3">' + actions + '</div></div></div></div>';
    }).join('');
  }
  function find(id) { return items.filter(function (a) { return a.id === +id; })[0]; }

  ['fSearch', 'fCourse'].forEach(function (id) { $(id).addEventListener('input', render); });
  $('tabs').addEventListener('click', function (e) { var b = e.target.closest('[data-tab]'); if (b) { tab = b.getAttribute('data-tab'); render(); } });
  $('list').addEventListener('click', function (e) {
    var su = e.target.closest('[data-submit]'), un = e.target.closest('[data-undo]'), vw = e.target.closest('[data-view]'), dw = e.target.closest('[data-dlf]');
    if (vw) window.open(fileUrlOf(find(vw.getAttribute('data-view')), false), '_blank');
    if (dw) {
      var da = find(dw.getAttribute('data-dlf')), l = document.createElement('a');
      l.href = fileUrlOf(da, true); l.download = da.file; document.body.appendChild(l); l.click(); l.remove();
      LH.toast('Downloading: ' + da.file, 'info');
    }
    if (su) {
      current = find(su.getAttribute('data-submit')); $('submitForm').reset(); $('sErr').textContent = '';
      $('sTitle').textContent = current.title; $('sMeta').textContent = current.course + ' - due ' + LH.fmtDate(current.due);
      $('sLate').classList.toggle('d-none', LH.daysFrom(current.due) >= 0); LH.modal('submitModal').show();
    }
    if (un) {
      var a = find(un.getAttribute('data-undo'));
      if (a.status === 'graded') return;                       // marks were given: the work can no longer be withdrawn
      if (a.fileId) LH.removeFile('submission', a.fileId);
      LH.remove('asg-s-' + a.id); build(); render(); LH.toast('Submission withdrawn', 'info');
    }
  });
  $('submitForm').addEventListener('submit', function (e) {
    e.preventDefault();
    var f = $('sFile').files[0], btn = e.submitter || $('submitForm').querySelector('[type=submit]');
    if (!f) return $('sErr').textContent = 'Please choose a file to upload.';
    if (f.size > 10 * 1024 * 1024) return $('sErr').textContent = 'File is larger than 10 MB.';
    btn.disabled = true; $('sErr').textContent = 'Uploading...';
    Promise.resolve().then(function () { return LH.upload('submission', f); }).then(function (r) {
      LH.save('asg-s-' + current.id, {submitted: LH.today(), file: r.name, fileId: r.id, note: $('sNote').value.trim()});
      LH.modal('submitModal').hide(); build(); render(); LH.toast('Assignment submitted');
    }).catch(function (err) { $('sErr').textContent = err.message; })
      .then(function () { btn.disabled = false; });
  });
  build(); fillCourses(); render();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
