<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="My Fun Page"/><jsp:param name="frosted" value="true"/></jsp:include>

<div class="child-hero text-center mb-4">
  <div class="child-mascot">&#129412;</div>
  <h1 class="child-greeting"><c:out value="${greeting}"/></h1>
  <p class="child-sub">Ready to learn something fun today?</p>
  <div class="child-stars">&#11088; &#11088; &#11088;</div>
</div>

<h2 class="child-title text-center mb-3">What shall we learn? &#127775;</h2>
<div class="row g-4 mb-4">
  <c:forEach var="s" items="${subjects}" varStatus="st">
    <div class="col-6 col-md-4">
      
    </div>
  </c:forEach>
</div>

<div class="row g-4 justify-content-center">
  <div class="col-12 col-md-5">
    <a class="child-big-btn pink" href="${ctx}/profile"><span>&#128522;</span> My Profile</a>
  </div>
  <div class="col-12 col-md-5">
    <a class="child-big-btn blue" href="${ctx}/change-password"><span>&#128273;</span> My Secret Password</a>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
