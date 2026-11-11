<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Course Details"/></jsp:include>

<!-- ============ LIST VIEW ============ -->
<div id="listView">
  <div class="glass-bar mod-hero">
    <div class="mod-title">
      <div class="mod-ico">&#128214;</div>
      <div><h3>Course Details</h3><p>Explore every course: syllabus, instructor, schedule and fees.</p></div>
    </div>
    <c:if test="${currentUser.canManageUsers()}">
      <button class="btn btn-primary" id="btnAdd"><i class="bi bi-plus-circle"></i> Add course</button>
    </c:if>
  </div>

  <c:if test="${currentUser.canManageUsers()}">
    <div class="card mb-3"><div class="card-body">
      <div class="small text-muted mb-2"><i class="bi bi-diagram-3"></i> Courses are managed in four separate parts &ndash; one for each learner level.</div>
      <div class="mod-tabs" id="lvTabs"></div>
    </div></div>
  </c:if>

  <div class="row g-3 mb-3" id="stats"></div>

  <div class="card mb-3"><div class="card-body"><div class="mod-filter">
    <input type="search" id="fSearch" class="form-control grow" placeholder="Search by course name or instructor...">
    <select id="fCat" class="form-select"></select>
    <select id="fLevel" class="form-select"><option value="">All difficulty</option><option>Beginner</option><option>Intermediate</option><option>Advanced</option></select>
    <select id="fPrice" class="form-select"><option value="">Free &amp; paid</option><option value="free">Free courses</option><option value="paid">Paid courses</option></select>
    <select id="fSort" class="form-select"><option value="name">Name A - Z</option><option value="rating">Top rated</option><option value="fee">Lowest fee</option><option value="seats">Most seats left</option></select>
  </div></div></div>

  <div class="row g-3" id="grid"></div>
</div>

<!-- ============ DETAIL VIEW ============ -->
<div id="detailView" hidden></div>

<!-- Add / edit course (admin) -->
<c:if test="${currentUser.canManageUsers()}">
<div class="modal fade" id="addModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg modal-dialog-scrollable">
    <form class="modal-content" id="addForm" novalidate>
      <div class="modal-header"><h5 class="modal-title" id="aTitle">Add a course</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <input type="hidden" id="aId">
        <div class="row g-3">
          <div class="col-md-8"><label class="form-label">Course name</label><input id="aName" class="form-control" maxlength="70"></div>
          <div class="col-md-4"><label class="form-label">Learner level</label><select id="aLv" class="form-select"><option value="CHILD">Child (3 - 7)</option><option value="SCHOOL">Grade 1 - 11</option><option value="AL">A/L</option><option value="UNDERGRAD">Undergraduate</option></select></div>
          <div class="col-md-4"><label class="form-label">Category</label><input id="aCat" class="form-control" maxlength="30" value="Technology"></div>
          <div class="col-md-4"><label class="form-label">Difficulty</label><select id="aLevel" class="form-select"><option>Beginner</option><option>Intermediate</option><option>Advanced</option></select></div>
          <div class="col-md-4"><label class="form-label">Language</label><input id="aLang" class="form-control" maxlength="40" value="English"></div>
          <div class="col-md-6"><label class="form-label">Instructor</label><input id="aTeacher" class="form-control" maxlength="50"></div>
          <div class="col-md-6"><label class="form-label">Instructor role</label><input id="aRole" class="form-control" maxlength="60" value="Instructor"></div>
          <div class="col-md-3 col-6"><label class="form-label">Weeks</label><input type="number" id="aWeeks" class="form-control" value="8" min="1" max="60"></div>
          <div class="col-md-3 col-6"><label class="form-label">Seats</label><input type="number" id="aSeats" class="form-control" value="30" min="1" max="500"></div>
          <div class="col-md-3 col-6"><label class="form-label">Fee (LKR)</label><input type="number" id="aFee" class="form-control" value="5000" min="0"></div>
          <div class="col-md-3 col-6"><label class="form-label">Schedule</label><input id="aSchedule" class="form-control" maxlength="60" value="To be announced"></div>
          <div class="col-12"><label class="form-label">Description</label><textarea id="aDesc" class="form-control" rows="3" maxlength="400"></textarea></div>
          <div class="col-md-6"><label class="form-label">What you will learn <span class="text-muted small">(one per line)</span></label><textarea id="aLearn" class="form-control" rows="4"></textarea></div>
          <div class="col-md-6"><label class="form-label">Requirements <span class="text-muted small">(one per line)</span></label><textarea id="aReqs" class="form-control" rows="4"></textarea></div>
          <div class="col-12"><label class="form-label">Syllabus parts <span class="text-muted small">(one per line: <code>Topic | short description</code>)</span></label><textarea id="aSyl" class="form-control" rows="4"></textarea></div>
        </div>
        <div class="text-danger small mt-2" id="aErr"></div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button><button type="submit" class="btn btn-primary" id="aSave">Add course</button></div>
    </form>
  </div>
</div>
</c:if>

<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="${currentUser.canManageUsers()}" data-level="${currentUser.level.code}" data-detail="<c:out value='${currentUser.levelDetail}'/>" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var meEl = document.getElementById('meData'), ADMIN = meEl.dataset.admin === 'true', CTX = meEl.dataset.ctx;
  var $ = function (id) { return document.getElementById(id); };
  var G = ['linear-gradient(135deg,#2563eb,#38bdf8)', 'linear-gradient(135deg,#059669,#34d399)', 'linear-gradient(135deg,#7c3aed,#c084fc)', 'linear-gradient(135deg,#d97706,#fbbf24)'];
  /* students get the list made for their own category; the admin sees every course, split into 4 level parts */
  var courses = LH.courses(), curLv = 'CHILD';
  function scope() { return ADMIN ? courses.filter(function (c) { return c.lv === curLv; }) : courses; }
  function saveAll() { LH.saveCourses(courses); }
  var enrolled = ADMIN ? [] : LH.keep(LH.load('enrolled', LH.defaultEnrolled()), 'id');
  function isIn(id) { return enrolled.some(function (e) { return e.id === id; }); }
  function left(c) { return c.seats - c.taken - (isIn(c.id) ? 1 : 0); }
  function byId(id) { return courses.filter(function (c) { return c.id === id; })[0]; }

  function fillCats() {
    var cats = {}; scope().forEach(function (c) { cats[c.cat] = 1; }); var cur = $('fCat').value;
    $('fCat').innerHTML = '<option value="">All categories</option>' + Object.keys(cats).sort().map(function (c) { return '<option>' + LH.esc(c) + '</option>'; }).join('');
    $('fCat').value = cur;
  }
  function stats() {
    var sc = scope(), seats = sc.reduce(function (t, c) { return t + Math.max(0, left(c)); }, 0);
    var avg = sc.length ? (sc.reduce(function (t, c) { return t + c.rating; }, 0) / sc.length).toFixed(1) : '-';
    var cards = [['Courses', sc.length, 'bi-journal-bookmark-fill', ''], ['Instructors', new Set(sc.map(function (c) { return c.teacher; })).size, 'bi-person-video3', 'cyan'],
                 ['Seats available', seats, 'bi-people-fill', 'green'], ['Average rating', avg, 'bi-star-fill', 'amber']];
    $('stats').innerHTML = cards.map(function (c) {
      return '<div class="col-md-3 col-6"><div class="card stat-card ' + c[3] + ' p-3"><span class="gicon"><i class="bi ' + c[2] + '"></i></span><div><div class="text-muted small">' + c[0] + '</div><div class="stat-number">' + c[1] + '</div></div></div></div>';
    }).join('');
  }
  function lvTabs() {
    if (!ADMIN) return;
    $('lvTabs').innerHTML = LH.LEVELS.map(function (l) {
      var n = courses.filter(function (c) { return c.lv === l.code; }).length;
      return '<button type="button" class="mod-tab ' + (curLv === l.code ? 'active' : '') + '" data-lv="' + l.code + '">' + l.icon + ' ' + l.tab + '<span class="cnt">' + n + '</span></button>';
    }).join('');
  }
  function grid() {
    lvTabs();
    var q = $('fSearch').value.toLowerCase(), ca = $('fCat').value, lv = $('fLevel').value, so = $('fSort').value, pr = $('fPrice').value;
    var rows = scope().filter(function (c) { return (!pr || (pr === 'free' ? c.fee === 0 : c.fee > 0)) && (!ca || c.cat === ca) && (!lv || c.diff === lv) && (!q || (c.name + ' ' + c.teacher + ' ' + c.cat).toLowerCase().indexOf(q) >= 0); });
    rows.sort(function (a, b) {
      if (so === 'rating') return b.rating - a.rating; if (so === 'fee') return a.fee - b.fee; if (so === 'seats') return left(b) - left(a);
      return a.name.localeCompare(b.name);
    });
    stats();
    if (!rows.length) { $('grid').innerHTML = '<div class="col-12"><div class="card"><div class="empty-state"><i class="bi bi-search"></i>No courses found.</div></div></div>'; return; }
    $('grid').innerHTML = rows.map(function (c) {
      var l = left(c);
      return '<div class="col-md-6 col-xl-3"><div class="card h-100"><div class="card-body d-flex flex-column">' +
        '<div class="course-banner" style="background:' + c.color + '">' + c.icon + '</div>' +
        '<div class="d-flex gap-1 mb-1 flex-wrap"><span class="chip blue">' + LH.esc(c.cat) + '</span><span class="chip">' + LH.esc(c.diff) + '</span>' + (c.fee === 0 ? '<span class="chip green">FREE</span>' : '') + (isIn(c.id) ? '<span class="chip green">Enrolled</span>' : '') + '</div>' +
        '<h6 class="fw-bold">' + LH.esc(c.name) + '</h6>' +
        '<div class="small text-muted mb-2"><i class="bi bi-person-video3"></i> ' + LH.esc(c.teacher) + '</div>' +
        '<div class="d-flex align-items-center gap-2 small mb-2">' + LH.stars(c.rating) + '<strong>' + c.rating.toFixed(1) + '</strong><span class="text-muted">(' + c.reviews + ')</span></div>' +
        '<div class="flex-fill"></div>' +
        '<div class="d-flex justify-content-between small mb-3"><span>' + (l <= 0 ? '<span class="chip red">Full</span>' : l + ' seats left') + '</span><strong>' + LH.price(c) + '</strong></div>' +
        (ADMIN ? '<div class="d-flex gap-2"><a class="btn btn-primary flex-fill" href="#' + c.id + '" title="View"><i class="bi bi-eye"></i> View</a>' +
          '<button class="btn btn-outline-primary" data-edit="' + c.id + '" title="Edit course"><i class="bi bi-pencil-square"></i></button>' +
          '<button class="btn btn-outline-danger" data-del="' + c.id + '" title="Delete course"><i class="bi bi-trash"></i></button></div>'
         : '<a class="btn btn-primary w-100" href="#' + c.id + '"><i class="bi bi-eye"></i> View details</a>') + '</div></div></div>';
    }).join('');
  }

  function detail(c) {
    var l = left(c), mine = isIn(c.id), pct = Math.round((c.seats - l) * 100 / c.seats);
    var cta = ADMIN ? '<button class="btn btn-primary w-100 mb-2" id="btnEdit"><i class="bi bi-pencil-square"></i> Edit course</button><button class="btn btn-outline-danger w-100" id="btnDelete"><i class="bi bi-trash"></i> Delete course</button>'
      : (mine ? '<a class="btn btn-primary w-100" href="' + CTX + '/course-notes"><i class="bi bi-journal-text"></i> Open study materials</a>'
               : '<button class="btn btn-outline-secondary w-100" disabled title="Enroll in this course to unlock the study materials"><i class="bi bi-lock"></i> Study materials (enroll first)</button>') +
        '<a class="btn ' + (mine ? 'btn-outline-primary' : 'btn-primary') + ' w-100 mt-2" href="' + CTX + '/course-enrollment#' + (mine ? 'learn-' : '') + c.id + '"><i class="bi bi-mortarboard"></i> ' + (mine ? 'Open course' : (c.fee === 0 ? 'Enroll free' : 'Enroll now')) + '</a>';
    var facts = [['bi-bar-chart-steps', 'Level', c.diff], ['bi-clock', 'Duration', c.weeks + ' weeks'], ['bi-calendar-week', 'Schedule', c.schedule], ['bi-translate', 'Language', c.lang], ['bi-patch-check', 'Certificate', 'Yes, on completion']];
    $('detailView').innerHTML =
      '<a href="#" class="btn btn-outline-secondary mb-3"><i class="bi bi-arrow-left"></i> All courses</a>' +
      '<div class="card mb-3"><div class="card-body d-flex flex-wrap gap-3 align-items-center">' +
        '<div class="course-banner mb-0" style="background:' + c.color + ';width:130px;height:110px">' + c.icon + '</div>' +
        '<div class="flex-fill"><div class="d-flex gap-1 flex-wrap mb-1"><span class="chip blue">' + LH.esc(c.cat) + '</span><span class="chip">' + LH.esc(c.diff) + '</span>' + (mine ? '<span class="chip green">You are enrolled</span>' : '') + '</div>' +
        '<h3 class="fw-bold mb-1">' + LH.esc(c.name) + '</h3>' +
        '<div class="d-flex align-items-center gap-2 flex-wrap">' + LH.stars(c.rating) + '<strong>' + c.rating.toFixed(1) + '</strong><span class="text-muted">(' + c.reviews + ' reviews)</span>' +
        '<a class="small" href="' + CTX + '/course-feedback">Read reviews</a></div></div></div></div>' +
      '<div class="row g-3"><div class="col-lg-8">' +
        '<div class="card mb-3"><div class="card-header"><i class="bi bi-info-circle"></i> About this course</div><div class="card-body"><p class="mb-0">' + LH.esc(c.desc) + '</p></div></div>' +
        '<div class="card mb-3"><div class="card-header"><i class="bi bi-check2-circle"></i> What you will learn</div><div class="card-body"><div class="row g-2">' +
          c.learn.map(function (x) { return '<div class="col-md-6"><div class="mod-tile py-2"><i class="bi bi-check-lg"></i> ' + LH.esc(x) + '</div></div>'; }).join('') + '</div></div></div>' +
        '<div class="card mb-3"><div class="card-header"><i class="bi bi-list-ol"></i> Syllabus</div><div class="card-body">' +
          c.syllabus.map(function (s, i) { return '<details class="syl"' + (i === 0 ? ' open' : '') + '><summary>' + LH.esc(s[0]) + '</summary><div class="small">' + LH.esc(s[1]) + '</div></details>'; }).join('') + '</div></div>' +
        '<div class="card"><div class="card-header"><i class="bi bi-clipboard-check"></i> Requirements</div><div class="card-body"><ul class="mb-0">' +
          c.reqs.map(function (x) { return '<li>' + LH.esc(x) + '</li>'; }).join('') + '</ul></div></div>' +
      '</div><div class="col-lg-4">' +
        '<div class="card mb-3"><div class="card-body">' +
          '<div class="text-muted small">Course fee</div><div class="display-6 fw-bold mb-2">' + LH.price(c) + '</div>' +
          '<div class="d-flex justify-content-between small mb-1"><span>' + (l <= 0 ? 'No seats left' : l + ' of ' + c.seats + ' seats left') + '</span><span>' + pct + '% full</span></div>' +
          '<div class="progress thin mb-3"><div class="progress-bar ' + (l <= 5 ? 'bg-danger' : 'bg-info') + '" style="width:' + pct + '%"></div></div>' + cta +
          '</div></div>' +
        '<div class="card mb-3"><div class="card-header"><i class="bi bi-person-video3"></i> Instructor</div><div class="card-body d-flex gap-3 align-items-center">' +
          '<div class="avatar-chip" style="background:' + LH.colorFor(c.teacher) + ';width:52px;height:52px">' + LH.esc(LH.initials(c.teacher.replace(/^(Dr|Prof|Mr|Ms|Mrs)\.\s*/, ''))) + '</div>' +
          '<div><div class="fw-bold">' + LH.esc(c.teacher) + '</div><div class="small text-muted">' + LH.esc(c.role) + '</div></div></div></div>' +
        '<div class="card"><div class="card-header"><i class="bi bi-card-checklist"></i> Course facts</div><div class="card-body">' +
          facts.map(function (f) { return '<div class="d-flex gap-2 py-1"><i class="bi ' + f[0] + '"></i><span class="text-muted" style="width:90px">' + f[1] + '</span><strong>' + LH.esc(f[2]) + '</strong></div>'; }).join('') + '</div></div>' +
      '</div></div>';
    var d = $('btnDelete'), ed = $('btnEdit');
    if (d) d.addEventListener('click', function () { removeCourse(c); });
    if (ed) ed.addEventListener('click', function () { openForm(c); });
  }

  function route() {
    var id = location.hash.replace('#', ''), c = id && byId(id);
    $('listView').hidden = !!c; $('detailView').hidden = !c;
    if (c) { detail(c); window.scrollTo(0, 0); document.title = c.name + ' | LearnHub'; } else { fillCats(); grid(); document.title = 'Course Details | LearnHub'; }
  }
  var openForm = function () {};
  function removeCourse(c) {
    if (!confirm('Delete "' + c.name + '"? Learners will no longer see it.')) return;
    courses = courses.filter(function (x) { return x.id !== c.id; }); saveAll();
    if (location.hash) location.hash = ''; else route();
    LH.toast('Course deleted', 'info');
  }
  window.addEventListener('hashchange', route);
  ['fSearch', 'fCat', 'fLevel', 'fSort', 'fPrice'].forEach(function (id) { if ($(id)) $(id).addEventListener('input', grid); });

  if (ADMIN) {
    var lines = function (id) { return $(id).value.split('\n').map(function (x) { return x.trim(); }).filter(Boolean); };
    openForm = function (c) {                    // c = course to edit, or nothing = add a new one in the open level part
      var f = $('addForm'); f.reset(); $('aErr').textContent = ''; $('aId').value = c ? c.id : '';
      $('aTitle').textContent = c ? 'Edit course: ' + c.name : 'Add a course - ' + LH.LEVELS.filter(function (l) { return l.code === curLv; })[0].tab;
      $('aSave').innerHTML = c ? '<i class="bi bi-check2-circle"></i> Save changes' : 'Add course';
      var x = c || {lv: curLv, name: '', cat: 'General', diff: 'Beginner', lang: LH.levelPool(curLv).lang, teacher: '', role: 'Instructor', weeks: 8, seats: 30, fee: 5000, schedule: 'To be announced', desc: '', learn: [], reqs: [], topics: [], syllabus: []};
      $('aName').value = x.name; $('aLv').value = x.lv; $('aCat').value = x.cat; $('aLevel').value = x.diff; $('aLang').value = x.lang; $('aTeacher').value = x.teacher; $('aRole').value = x.role;
      $('aWeeks').value = x.weeks; $('aSeats').value = x.seats; $('aFee').value = x.fee; $('aSchedule').value = x.schedule; $('aDesc').value = x.desc;
      $('aLearn').value = x.learn.join('\n'); $('aReqs').value = x.reqs.join('\n');
      $('aSyl').value = x.topics.map(function (t, i) { return t + ' | ' + ((x.syllabus[i] || [])[1] || ''); }).join('\n');
      LH.modal('addModal').show();
    };
    $('btnAdd').addEventListener('click', function () { openForm(null); });
    $('lvTabs').addEventListener('click', function (e) { var b = e.target.closest('[data-lv]'); if (b) { curLv = b.getAttribute('data-lv'); $('fCat').value = ''; fillCats(); grid(); } });
    $('grid').addEventListener('click', function (e) {
      var ed = e.target.closest('[data-edit]'), dl = e.target.closest('[data-del]');
      if (ed) openForm(byId(ed.getAttribute('data-edit')));
      if (dl) removeCourse(byId(dl.getAttribute('data-del')));
    });
    $('addForm').addEventListener('submit', function (e) {
      e.preventDefault();
      var id = $('aId').value, old = id ? byId(id) : null;
      var n = $('aName').value.trim(), t = $('aTeacher').value.trim(), seats = parseInt($('aSeats').value, 10), fee = parseInt($('aFee').value, 10), wk = parseInt($('aWeeks').value, 10);
      if (n.length < 3) return $('aErr').textContent = 'Please enter the course name.';
      if (t.length < 3) return $('aErr').textContent = 'Please enter the instructor name.';
      if (!(seats > 0) || !(fee >= 0) || !(wk > 0)) return $('aErr').textContent = 'Weeks, seats and fee must be valid numbers.';
      if (old && seats < old.taken) return $('aErr').textContent = 'Seats cannot be less than the ' + old.taken + ' learners already enrolled.';
      var topics = [], descs = [];
      lines('aSyl').forEach(function (l) { var p = l.split('|'); topics.push(p[0].trim()); descs.push((p[1] || '').trim() || 'Lessons, practice activities and a short quiz.'); });
      if (!topics.length) { topics = ['Introduction']; descs = ['Lessons, practice activities and a short quiz.']; }
      var lv = $('aLv').value, c = old || {id: nextId(lv), rating: 0, reviews: 0, taken: 0, icon: '&#128218;', color: G[Math.floor(Math.random() * G.length)], free: false};
      Object.assign(c, {name: n, cat: $('aCat').value.trim() || 'General', diff: $('aLevel').value, lv: lv, teacher: t, role: $('aRole').value.trim() || 'Instructor', seats: seats, fee: fee, weeks: wk,
        lang: $('aLang').value.trim() || 'English', schedule: $('aSchedule').value.trim() || 'To be announced', desc: $('aDesc').value.trim() || 'Description coming soon.',
        learn: lines('aLearn').length ? lines('aLearn') : ['Details coming soon'], reqs: lines('aReqs').length ? lines('aReqs') : ['None'], topics: topics,
        syllabus: topics.map(function (x, i) { return ['Part ' + (i + 1) + ': ' + x, descs[i]]; })});
      if (!old || old.lv !== lv) {                                // a new course, or moved to another level part: set who it is for
        ['minA', 'maxA', 'minG', 'maxG', 'streams', 'g'].forEach(function (k) { delete c[k]; });
        Object.assign(c, LH.levelFields(lv));
      }
      if (!old) courses.push(c);
      curLv = lv; saveAll(); LH.modal('addModal').hide(); fillCats();
      if (location.hash === '#' + c.id) detail(c); else grid();
      LH.toast(old ? 'Course updated' : 'Course added');
    });
    function nextId(lv) {
      var pfx = {CHILD: 'K', SCHOOL: 'S', AL: 'A', UNDERGRAD: 'U'}[lv] || 'C';
      var num = courses.filter(function (c) { return c.id.charAt(0) === pfx; }).reduce(function (m, c) { return Math.max(m, parseInt(c.id.slice(1), 10) || 0); }, 500) + 1;
      return pfx + num;
    }
  }
  route();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
