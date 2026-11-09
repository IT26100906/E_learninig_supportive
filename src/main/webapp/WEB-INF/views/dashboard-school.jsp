<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="My Classroom"/><jsp:param name="frosted" value="true"/></jsp:include>

<div class="school-banner mb-4">
  <div class="d-flex align-items-center gap-3 flex-wrap">
    <div class="grade-badge"><small>GRADE</small><span><c:out value="${currentUser.levelDetail}"/></span></div>
    <div class="flex-grow-1">
      <h2 class="mb-1"><c:out value="${greeting}"/></h2>
      <div>Student ID: <strong><c:out value="${currentUser.id}"/></strong>
        <c:if test="${not empty highlight}"><span class="badge text-bg-warning ms-2"><c:out value="${highlight}"/></span></c:if>
      </div>
    </div>
    <div class="text-end small"><div>Last login</div><strong>${currentUser.lastLoginText}</strong></div>
  </div>
</div>

<div class="row g-4">
  <div class="col-lg-8">
    <h4 class="school-heading">&#128211; My Subjects</h4>
    <div class="row g-3">
      <c:forEach var="s" items="${subjects}" varStatus="st">
        <div class="col-6 col-md-4">
          <a class="subject-card sc-${st.index % 6}" href="${ctx}/course-details">
            <span class="sc-icon"><c:out value="${s.icon}"/></span>
            <span class="sc-name"><c:out value="${s.name}"/></span>
            <span class="sc-open">Open &rarr;</span>
          </a>
        </div>
      </c:forEach>
    </div>
  </div>
  <div class="col-lg-4">
    <h4 class="school-heading">&#9989; Today</h4>
    <div class="card mb-3">
      <div class="card-body">
        <div class="d-flex align-items-center gap-3 mb-3"><span class="fs-3">&#128221;</span>
          <div><strong>Homework &amp; assignments</strong><div class="small text-muted">Open the Assignment page to see your tasks</div></div></div>
        <a href="${ctx}/assignments" class="btn btn-primary w-100">View assignments</a>
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

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
