<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Admin Dashboard"/><jsp:param name="frosted" value="true"/></jsp:include>

<div class="glass-bar p-3 d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
  <div>
    <h3 class="mb-0"><i class="bi bi-speedometer2 text-brand"></i> Admin Dashboard</h3>
    <div class="text-muted">Student account overview</div>
  </div>
  <div class="d-flex gap-2">
    <a href="${ctx}/admin/students/form" class="btn btn-primary"><i class="bi bi-person-plus"></i> Add student</a>
    <a href="${ctx}/admin/students" class="btn btn-outline-primary"><i class="bi bi-people"></i> Manage students</a>
    <a href="${ctx}/admin/students/export" class="btn btn-outline-secondary"><i class="bi bi-download"></i> Export CSV</a>
    <a href="${ctx}/admin/database" class="btn btn-outline-secondary"><i class="bi bi-table"></i> Database</a>
    <a href="${ctx}/admin/phpmyadmin" target="_blank" rel="noopener" class="btn btn-outline-secondary"><i class="bi bi-database"></i> phpMyAdmin</a>
  </div>
</div>

<section class="row g-3 mb-4" aria-label="Student administration actions">
  <div class="col-md-6">
    <div class="card h-100 p-4">
      <div class="d-flex align-items-center gap-3 mb-2"><i class="bi bi-person-plus-fill fs-2 text-primary"></i><h4 class="mb-0">Add Student</h4></div>
      <p class="text-muted">Register a new student account with student details, membership and level.</p>
      <a class="btn btn-primary mt-auto align-self-start" href="${ctx}/admin/students/form"><i class="bi bi-plus-circle"></i> Add Student</a>
    </div>
  </div>
  <div class="col-md-6">
    <div class="card h-100 p-4">
      <div class="d-flex align-items-center gap-3 mb-2"><i class="bi bi-people-fill fs-2 text-primary"></i><h4 class="mb-0">Student Management</h4></div>
      <p class="text-muted">Search, view, edit, activate, deactivate or delete existing students.</p>
      <a class="btn btn-outline-primary mt-auto align-self-start" href="${ctx}/admin/students"><i class="bi bi-people"></i> Manage Students</a>
    </div>
  </div>
</section>

<div class="row g-3 mb-4">
  <div class="col-md col-6"><div class="card stat-card p-3"><span class="gicon"><i class="bi bi-people-fill"></i></span><div><div class="text-muted small">Total students</div><div class="stat-number">${stats.total}</div></div></div></div>
  <div class="col-md col-6"><div class="card stat-card green p-3"><span class="gicon"><i class="bi bi-person-check-fill"></i></span><div><div class="text-muted small">Active</div><div class="stat-number">${stats.active}</div></div></div></div>
  <div class="col-md col-6"><div class="card stat-card red p-3"><span class="gicon"><i class="bi bi-person-slash"></i></span><div><div class="text-muted small">Inactive</div><div class="stat-number">${stats.inactive}</div></div></div></div>
  <div class="col-md col-6"><div class="card stat-card amber p-3"><span class="gicon"><i class="bi bi-star-fill"></i></span><div><div class="text-muted small">Premium</div><div class="stat-number">${stats.premium}</div></div></div></div>
  <div class="col-md col-6"><div class="card stat-card cyan p-3"><span class="gicon"><i class="bi bi-person-plus-fill"></i></span><div><div class="text-muted small">New this month</div><div class="stat-number">${stats.newThisMonth}</div></div></div></div>
</div>

<div class="row g-3 mb-4">
  <div class="col-md-3 col-6"><div class="card p-3 text-center"><div style="font-size:1.8rem">&#129490;</div><div class="text-muted small">Child</div><div class="stat-number">${stats.child}</div></div></div>
  <div class="col-md-3 col-6"><div class="card p-3 text-center"><div style="font-size:1.8rem">&#127890;</div><div class="text-muted small">Grade 1 - 11</div><div class="stat-number">${stats.school}</div></div></div>
  <div class="col-md-3 col-6"><div class="card p-3 text-center"><div style="font-size:1.8rem">&#128218;</div><div class="text-muted small">A/L</div><div class="stat-number">${stats.al}</div></div></div>
  <div class="col-md-3 col-6"><div class="card p-3 text-center"><div style="font-size:1.8rem">&#127891;</div><div class="text-muted small">Undergraduate</div><div class="stat-number">${stats.undergrad}</div></div></div>
</div>

<div class="card">
  <div class="card-header"><i class="bi bi-clock-history"></i> Newest students</div>
  <div class="table-responsive">
    <table class="table table-hover mb-0">
      <thead class="table-light"><tr><th>ID</th><th>Name</th><th>Email</th><th>Membership</th><th>Registered</th><th>Status</th></tr></thead>
      <tbody>
        <c:forEach var="s" items="${recent}">
          <tr>
            <td><c:out value="${s.id}"/></td>
            <td><c:out value="${s.name}"/></td>
            <td><c:out value="${s.email}"/></td>
            <td><c:out value="${s.membershipLabel}"/></td>
            <td>${s.registeredDate}</td>
            <td><span class="badge ${s.active ? 'text-bg-success' : 'text-bg-danger'}"><c:out value="${s.status}"/></span></td>
          </tr>
        </c:forEach>
        <c:if test="${empty recent}"><tr><td colspan="6" class="text-center text-muted py-4">No students registered yet.</td></tr></c:if>
      </tbody>
    </table>
  </div>
</div>

<%-- Opening the dashboard also makes sure every student has enrollment + payment rows (saved in the database) --%>
<jsp:include page="/WEB-INF/views/common/roster.jsp"/>
<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="true" data-level="" data-detail="" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  try { if (window.LH && LH.syncAdminSeed) LH.syncAdminSeed(getRoster()); } catch (e) { console.warn('sync skipped', e); }
});
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
