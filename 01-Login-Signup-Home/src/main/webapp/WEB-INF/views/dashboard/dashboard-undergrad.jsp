<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="My Campus"/><jsp:param name="frosted" value="true"/></jsp:include>

<%-- Undergraduate home: same family as the Grade 1-11 / A/L pages (banner + toolkit tiles + course cards) --%>
<div class="school-banner mb-4">
  <div class="d-flex align-items-center gap-3 flex-wrap">
    <div class="grade-badge"><small>DEGREE</small><span>&#127891;</span></div>
    <div class="flex-grow-1">
      <h2 class="mb-1"><c:out value="${greeting}"/></h2>
      <div>Student ID: <strong><c:out value="${currentUser.id}"/></strong>
        <span class="badge text-bg-warning ms-2"><c:out value="${currentUser.membershipLabel}"/> member</span>
      </div>
      <div class="opacity-75 small mt-1"><c:out value="${currentUser.levelDisplay}"/></div>
    </div>
    <div class="text-end small"><div>Last login</div><strong>${currentUser.lastLoginText}</strong></div>
  </div>
</div>

<h4 class="school-heading">&#128295; Study toolkit</h4>
<div class="row g-3 mb-4">
  <div class="col-6 col-md-3"></div>
  <div class="col-6 col-md-3"></div>
  <div class="col-6 col-md-3"></div>
  <div class="col-6 col-md-3"></div>
</div>

<div class="row g-4">
  <div class="col-lg-8">
    <div class="d-flex justify-content-between align-items-end flex-wrap gap-2">
      <h4 class="school-heading mb-2" id="coursesHeading">&#128211; My courses</h4>
      
    </div>
    <div class="row g-3" id="myCourses"></div>
  </div>
  <div class="col-lg-4">
    <h4 class="school-heading">&#9989; My account</h4>
    <div class="card mb-3">
      <div class="card-body">
        <div class="d-flex justify-content-between small mb-1"><span>Profile completeness</span><strong>${currentUser.profileCompleteness}%</strong></div>
        <div class="progress mb-3" style="height:10px"><div class="progress-bar bg-success" style="width: ${currentUser.profileCompleteness}%"></div></div>
        <div class="d-flex justify-content-between small py-1"><span class="text-muted">Course limit</span><strong id="limitTxt">${currentUser.maxEnrollments}</strong></div>
        <div class="d-flex justify-content-between small py-1"><span class="text-muted">Member since</span><strong>${currentUser.registeredDate}</strong></div>
      </div>
    </div>
    <div class="card">
      <div class="card-header"><i class="bi bi-lightning"></i> Quick links</div>
      <div class="card-body d-grid gap-2">
        <a class="btn btn-outline-primary" href="${ctx}/profile"><i class="bi bi-person-circle"></i> My profile</a>
        <a class="btn btn-outline-primary" href="${ctx}/profile/edit"><i class="bi bi-pencil-square"></i> Edit profile</a>
        
        <a class="btn btn-outline-primary" href="${ctx}/change-password"><i class="bi bi-key"></i> Change password</a>
      </div>
    </div>
  </div>
</div>

<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="false" data-level="${currentUser.level.code}" data-detail="<c:out value='${currentUser.levelDetail}'/>" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var CTX = document.getElementById('meData').dataset.ctx, MAX = ${currentUser.maxEnrollments};
  var courses = LH.courses(), enrolled = LH.keep(LH.load('enrolled', LH.defaultEnrolled()), 'id');
  function byId(id) { return courses.filter(function (c) { return c.id === id; })[0]; }
  var mine = enrolled.filter(function (e) { return byId(e.id); });
  var box = document.getElementById('myCourses'), html = '';
  document.getElementById('enrSmall').textContent = mine.length + ' of ' + MAX + ' courses joined';
  document.getElementById('limitTxt').textContent = mine.length + ' / ' + MAX;

  mine.slice(0, 6).forEach(function (en, i) {
    var c = byId(en.id);
    html += '<div class="col-6 col-md-4"><a class="subject-card sc-' + (i % 6) + '" href="' + CTX + '/course-enrollment#learn-' + c.id + '">' +
      '<span class="sc-icon">' + c.icon + '</span><span class="sc-name">' + LH.esc(c.name) + '</span>' +
      '<span class="progress thin w-100 my-1"><span class="progress-bar bg-success" style="width:' + en.progress + '%"></span></span>' +
      '<span class="sc-open">' + en.progress + '% complete &middot; Continue &rarr;</span></a></div>';
  });
  if (mine.length < 6) {                       // fill the rest with suggestions for this degree
    var left = 6 - mine.length;
    courses.filter(function (c) { return !c.free && !mine.some(function (e) { return e.id === c.id; }); }).slice(0, left).forEach(function (c, i) {
      html += '<div class="col-6 col-md-4"><a class="subject-card sc-' + ((mine.length + i) % 6) + '" href="' + CTX + '/course-details#' + c.id + '">' +
        '<span class="sc-icon">' + c.icon + '</span><span class="sc-name">' + LH.esc(c.name) + '</span>' +
        '<span class="sc-open">Suggested &middot; ' + LH.price(c) + ' &rarr;</span></a></div>';
    });
  }
  if (!mine.length) document.getElementById('coursesHeading').innerHTML = '&#128211; Courses for your degree';
  box.innerHTML = html || '<div class="col-12"><div class="card"><div class="empty-state"><i class="bi bi-journal-x"></i>No courses yet.</div></div></div>';
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
