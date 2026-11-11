<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="A/L Focus Zone"/><jsp:param name="frosted" value="true"/></jsp:include>

<div class="al-banner mb-4">
  <div class="d-flex align-items-center gap-3 flex-wrap">
    <div class="al-emblem">&#127919;</div>
    <div class="flex-grow-1">
      <div class="al-kicker">ADVANCED LEVEL &bull; <c:out value="${currentUser.levelDetail}"/></div>
      <h2 class="mb-1"><c:out value="${greeting}"/></h2>
      <div class="opacity-75">Student ID: <c:out value="${currentUser.id}"/> &bull; <c:out value="${highlight}"/></div>
    </div>
    <div class="text-end small"><div class="opacity-75">Last login</div><strong>${currentUser.lastLoginText}</strong></div>
  </div>
</div>

<h5 class="al-heading">STUDY TOOLKIT</h5>
<div class="row g-3 mb-4">
  <div class="col-6 col-md-3"></div>
  <div class="col-6 col-md-3"></div>
  <div class="col-6 col-md-3"></div>
  <div class="col-6 col-md-3"></div>
</div>

<div class="row g-4">
  <div class="col-lg-8">
    <h5 class="al-heading">MY SUBJECTS</h5>
    <div class="row g-3">
      <c:forEach var="s" items="${subjects}">
        <div class="col-sm-6">
          
        </div>
      </c:forEach>
    </div>
  </div>
  <div class="col-lg-4">
    <h5 class="al-heading">FOCUS TIPS</h5>
    <div class="card">
      <div class="card-body">
        <p class="mb-2">&#9201; Study in 45 minute blocks with 10 minute breaks.</p>
        <p class="mb-2">&#128260; Revise past papers every week.</p>
        <p class="mb-3">&#128564; Sleep well before exam days.</p>
        <a class="btn btn-primary w-100 mb-2" href="${ctx}/profile">My profile</a>
        <a class="btn btn-outline-secondary w-100" href="${ctx}/change-password">Change password</a>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
