<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Course Feedback / Reviews"/></jsp:include>

<div class="glass-bar mod-hero">
  <div class="mod-title">
    <div class="mod-ico">&#11088;</div>
    <div><h3>Course Feedback / Reviews</h3><p>Read what other learners think and share your own experience.</p></div>
  </div>
  <c:if test="${not currentUser.canManageUsers()}">
    <button class="btn btn-primary" id="btnWrite"><i class="bi bi-pencil-square"></i> Write a review</button>
  </c:if>
</div>

<div class="row g-3 mb-3">
  <div class="col-lg-4">
    <div class="card h-100"><div class="card-body text-center">
      <div class="text-muted small">Average rating</div>
      <div class="display-4 fw-bold" id="avgNum">0.0</div>
      <div id="avgStars" class="fs-4"></div>
      <div class="text-muted small mt-1" id="totalNum"></div>
    </div></div>
  </div>
  <div class="col-lg-8">
    <div class="card h-100"><div class="card-body" id="dist"></div></div>
  </div>
</div>

<div class="card mb-3"><div class="card-body">
  <c:if test="${currentUser.canManageUsers()}">
    <div class="small text-muted mb-2"><i class="bi bi-diagram-3"></i> Admin: reviews are split by the learner level of the course. You can view and delete any review.</div>
    <div class="mod-tabs mb-3" id="lvTabs"></div>
  </c:if>
  <div class="mod-filter">
    <input type="search" id="fSearch" class="form-control grow" placeholder="Search reviews...">
    <select id="fCourse" class="form-select"></select>
    <select id="fRating" class="form-select">
      <option value="0">All ratings</option><option value="5">5 stars</option><option value="4">4 stars</option>
      <option value="3">3 stars</option><option value="2">2 stars</option><option value="1">1 star</option>
    </select>
    <select id="fSort" class="form-select">
      <option value="new">Newest first</option><option value="high">Highest rated</option>
      <option value="low">Lowest rated</option><option value="help">Most helpful</option>
    </select>
  </div>
</div></div>

<div id="list" class="row g-3"></div>

<!-- View review (admin) -->
<div class="modal fade" id="viewModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Review details</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body" id="viewBody"></div>
      <div class="modal-footer justify-content-between">
        <button class="btn btn-outline-danger" id="viewDel"><i class="bi bi-trash"></i> Delete review</button>
        <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<!-- Write review -->
<div class="modal fade" id="reviewModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <form class="modal-content" id="reviewForm" novalidate>
      <div class="modal-header"><h5 class="modal-title">Write a review</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-3"><label class="form-label">Course</label><select id="rCourse" class="form-select" required></select></div>
        <div class="mb-3"><label class="form-label d-block">Your rating</label>
          <div class="star-pick" id="rStars">
            <input type="radio" name="rate" id="s5" value="5"><label for="s5">&#9733;</label>
            <input type="radio" name="rate" id="s4" value="4"><label for="s4">&#9733;</label>
            <input type="radio" name="rate" id="s3" value="3"><label for="s3">&#9733;</label>
            <input type="radio" name="rate" id="s2" value="2"><label for="s2">&#9733;</label>
            <input type="radio" name="rate" id="s1" value="1"><label for="s1">&#9733;</label>
          </div>
        </div>
        <div class="mb-3"><label class="form-label">Title</label><input id="rTitle" class="form-control" maxlength="80" placeholder="Sum it up in a few words" required></div>
        <div class="mb-3"><label class="form-label">Your feedback</label><textarea id="rText" class="form-control" rows="4" maxlength="600" placeholder="What did you like? What could be better?" required></textarea>
          <div class="form-text"><span id="rCount">0</span>/600</div></div>
        <div class="form-check"><input class="form-check-input" type="checkbox" id="rAnon"><label class="form-check-label" for="rAnon">Post anonymously</label></div>
        <div class="text-danger small mt-2" id="rErr"></div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary"><i class="bi bi-send"></i> Submit review</button></div>
    </form>
  </div>
</div>

<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="${currentUser.canManageUsers()}" data-level="${currentUser.level.code}" data-detail="<c:out value='${currentUser.levelDetail}'/>" data-max="${currentUser.maxEnrollments}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var meEl = document.getElementById('meData');
  var ME = { id: meEl.dataset.id, name: meEl.dataset.name, admin: meEl.dataset.admin === 'true' };
  var COURSES = LH.names(), curLv = 'ALL', viewId = null;
  var LVOF = {}; LH.allCourses().forEach(function (c) { LVOF[c.name] = c.lv; });
  /* admin: sample reviews are spread over all four learner levels (2 per level), learners: reviews of their own courses */
  function spread(shift) {
    var per = LH.LEVELS.map(function (l) { return LH.allCourses().filter(function (c) { return c.lv === l.code && !c.free; }); }), out = [];
    for (var k = 0; k < 8; k++) { var list = per[k % 4]; if (list.length) out.push(list[(Math.floor(k / 4) * 2 + shift) % list.length]); }
    return out;
  }
  var SEED = ME.admin ? LH.seedReviews(spread(0)).concat(LH.seedReviews(spread(3)).map(function (r, i) { r.id = 9 + i; r.uid = 'Y' + i; r.date = LH.addDays(-5 - i * 5); r.helpful += 2; return r; })) : LH.seedReviews(LH.courses());
  var reviews = LH.keep(LH.load('reviews', SEED), 'course'), liked = LH.load('liked', []);
  function scope() { return ME.admin && curLv !== 'ALL' ? reviews.filter(function (r) { return LVOF[r.course] === curLv; }) : reviews; }
  function lvTabs() {
    if (!ME.admin) return;
    var defs = [{code: 'ALL', tab: 'All', icon: '&#128450;'}].concat(LH.LEVELS);
    $('lvTabs').innerHTML = defs.map(function (l) {
      var n = l.code === 'ALL' ? reviews.length : reviews.filter(function (r) { return LVOF[r.course] === l.code; }).length;
      return '<button type="button" class="mod-tab ' + (curLv === l.code ? 'active' : '') + '" data-lv="' + l.code + '">' + l.icon + ' ' + l.tab + '<span class="cnt">' + n + '</span></button>';
    }).join('');
  }
  var $ = function (id) { return document.getElementById(id); };

  var courseOpts = '<option value="">All courses</option>' + COURSES.map(function (c) { return '<option>' + LH.esc(c) + '</option>'; }).join('');
  $('fCourse').innerHTML = courseOpts;
  $('rCourse').innerHTML = '<option value="">Choose a course...</option>' + COURSES.map(function (c) { return '<option>' + LH.esc(c) + '</option>'; }).join('');

  function summary() {
    var sc = scope(), n = sc.length, sum = sc.reduce(function (a, r) { return a + r.rating; }, 0);
    $('avgNum').textContent = n ? (sum / n).toFixed(1) : '0.0';
    $('avgStars').innerHTML = LH.stars(n ? sum / n : 0);
    $('totalNum').textContent = 'Based on ' + n + ' review' + (n === 1 ? '' : 's');
    var html = '';
    for (var s = 5; s >= 1; s--) {
      var c = sc.filter(function (r) { return r.rating === s; }).length, pct = n ? Math.round(c * 100 / n) : 0;
      html += '<div class="bar-row mb-2"><span style="width:44px">' + s + ' &#9733;</span><div class="bar"><i style="width:' + pct + '%"></i></div><span style="width:70px" class="text-end text-muted">' + c + ' (' + pct + '%)</span></div>';
    }
    $('dist').innerHTML = '<div class="fw-bold mb-2">Rating breakdown</div>' + html;
  }

  function render() {
    var q = $('fSearch').value.toLowerCase(), co = $('fCourse').value, ra = +$('fRating').value, so = $('fSort').value;
    var rows = scope().filter(function (r) {
      return (!co || r.course === co) && (!ra || r.rating === ra) &&
             (!q || (r.title + ' ' + r.text + ' ' + r.name + ' ' + r.course).toLowerCase().indexOf(q) >= 0);
    });
    rows.sort(function (a, b) {
      if (so === 'high') return b.rating - a.rating;
      if (so === 'low') return a.rating - b.rating;
      if (so === 'help') return b.helpful - a.helpful;
      return b.date < a.date ? -1 : b.date > a.date ? 1 : b.id - a.id;
    });
    if (!rows.length) { $('list').innerHTML = '<div class="col-12"><div class="card"><div class="empty-state"><i class="bi bi-chat-square-text"></i>No reviews match your filters.</div></div></div>'; return; }
    $('list').innerHTML = rows.map(function (r) {
      var mine = r.uid === ME.id, nm = r.anon ? 'Anonymous' : r.name, isLiked = liked.indexOf(r.id) >= 0;
      return '<div class="col-lg-6"><div class="card h-100"><div class="card-body">' +
        '<div class="d-flex gap-3 mb-2"><div class="avatar-chip" style="background:' + LH.colorFor(nm) + '">' + (r.anon ? '?' : LH.esc(LH.initials(nm))) + '</div>' +
        '<div class="flex-fill"><div class="fw-bold">' + LH.esc(nm) + (mine ? ' <span class="chip blue">You</span>' : '') + '</div>' +
        '<div class="small text-muted">' + LH.fmtDate(r.date) + '</div></div><div class="text-end">' + LH.stars(r.rating) + '</div></div>' +
        '<span class="chip mb-2">' + LH.esc(r.course) + '</span>' +
        '<h6 class="fw-bold mt-1">' + LH.esc(r.title) + '</h6><p class="mb-3">' + LH.esc(r.text) + '</p>' +
        '<div class="d-flex justify-content-between align-items-center">' +
        '<button class="btn btn-sm ' + (isLiked ? 'btn-primary' : 'btn-outline-primary') + '" data-like="' + r.id + '"><i class="bi bi-hand-thumbs-up"></i> Helpful (' + r.helpful + ')</button>' +
        (ME.admin ? '<span class="d-flex gap-2"><button class="btn btn-sm btn-outline-secondary" data-view="' + r.id + '" title="View"><i class="bi bi-eye"></i> View</button>' +
          '<button class="btn btn-sm btn-outline-danger" data-del="' + r.id + '" title="Delete"><i class="bi bi-trash"></i> Delete</button></span>'
         : mine ? '<button class="btn btn-sm btn-outline-danger" data-del="' + r.id + '" title="Delete"><i class="bi bi-trash"></i> Delete</button>' : '') +
        '</div></div></div></div>';
    }).join('');
  }
  function refresh() { lvTabs(); summary(); render(); }

  ['fSearch', 'fCourse', 'fRating', 'fSort'].forEach(function (id) { $(id).addEventListener('input', render); });

  $('list').addEventListener('click', function (e) {
    var l = e.target.closest('[data-like]'), d = e.target.closest('[data-del]'), v = e.target.closest('[data-view]');
    if (v) openView(+v.getAttribute('data-view'));
    if (l) {
      var id = +l.getAttribute('data-like'), r = reviews.filter(function (x) { return x.id === id; })[0], i = liked.indexOf(id);
      if (i >= 0) { liked.splice(i, 1); r.helpful--; } else { liked.push(id); r.helpful++; }
      LH.save('reviews', reviews); LH.save('liked', liked); render();
    }
    if (d && confirm('Delete this review?')) {
      var did = +d.getAttribute('data-del');
      reviews = reviews.filter(function (x) { return x.id !== did; });
      LH.save('reviews', reviews); refresh(); LH.toast('Review deleted', 'info');
    }
  });

  /* ---------- admin: view one review in full ---------- */
  function openView(id) {
    var r = reviews.filter(function (x) { return x.id === id; })[0]; if (!r) return; viewId = id;
    var lv = LH.LEVELS.filter(function (l) { return l.code === LVOF[r.course]; })[0], nm = r.anon ? 'Anonymous (' + r.name + ')' : r.name;
    $('viewBody').innerHTML = '<div class="d-flex gap-3 mb-3"><div class="avatar-chip" style="background:' + LH.colorFor(r.name) + '">' + LH.esc(LH.initials(r.name)) + '</div>' +
      '<div class="flex-fill"><div class="fw-bold">' + LH.esc(nm) + '</div><div class="small text-muted">' + (/^[SPA]\d+$/.test(r.uid) ? 'Student ID ' + LH.esc(r.uid) + ' &middot; ' : '') + LH.fmtDate(r.date) + '</div></div><div class="text-end">' + LH.stars(r.rating) + '</div></div>' +
      '<div class="d-flex gap-1 flex-wrap mb-2"><span class="chip blue">' + LH.esc(r.course) + '</span>' + (lv ? '<span class="chip">' + lv.icon + ' ' + lv.tab + '</span>' : '') + '<span class="chip green">' + r.helpful + ' found helpful</span></div>' +
      '<h6 class="fw-bold">' + LH.esc(r.title) + '</h6><p class="mb-0">' + LH.esc(r.text) + '</p>';
    LH.modal('viewModal').show();
  }
  function removeReview(id) {
    reviews = reviews.filter(function (x) { return x.id !== id; }); LH.save('reviews', reviews); refresh(); LH.toast('Review deleted', 'info');
  }
  if (ME.admin) {
    $('lvTabs').addEventListener('click', function (e) { var b = e.target.closest('[data-lv]'); if (b) { curLv = b.getAttribute('data-lv'); refresh(); } });
    $('viewDel').addEventListener('click', function () { if (confirm('Delete this review?')) { LH.modal('viewModal').hide(); removeReview(viewId); } });
  }
  var btn = $('btnWrite');
  if (btn) {
    btn.addEventListener('click', function () { $('reviewForm').reset(); $('rErr').textContent = ''; $('rCount').textContent = '0'; LH.modal('reviewModal').show(); });
    $('rText').addEventListener('input', function () { $('rCount').textContent = this.value.length; });
    $('reviewForm').addEventListener('submit', function (e) {
      e.preventDefault();
      var rate = document.querySelector('input[name=rate]:checked'), course = $('rCourse').value, title = $('rTitle').value.trim(), text = $('rText').value.trim();
      if (!course) return $('rErr').textContent = 'Please choose a course.';
      if (!rate) return $('rErr').textContent = 'Please give a star rating.';
      if (title.length < 3) return $('rErr').textContent = 'Please add a short title.';
      if (text.length < 10) return $('rErr').textContent = 'Please write at least 10 characters.';
      var nextId = reviews.reduce(function (m, r) { return Math.max(m, r.id); }, 0) + 1;
      reviews.unshift({id: nextId, uid: ME.id, name: ME.name, anon: $('rAnon').checked, course: course, rating: +rate.value, title: title, text: text, date: LH.today(), helpful: 0});
      LH.save('reviews', reviews); LH.modal('reviewModal').hide(); refresh(); LH.toast('Thank you! Your review was posted.');
    });
  }
  refresh();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
