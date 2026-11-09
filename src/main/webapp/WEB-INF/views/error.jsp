<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Error"/></jsp:include>
<c:set var="code" value="${requestScope['javax.servlet.error.status_code']}"/>

<div class="glass-bar text-center p-5 mx-auto mt-4" style="max-width:640px">
  <div class="display-1 text-brand fw-bold"><c:out value="${empty code ? 'Error' : code}"/></div>
  <h3 class="mb-3">
    <c:choose>
      <c:when test="${code == 403}">Access denied</c:when>
      <c:when test="${code == 404}">Page not found</c:when>
      <c:otherwise>Something went wrong</c:otherwise>
    </c:choose>
  </h3>
  <p class="text-muted">
    <c:choose>
      <c:when test="${code == 403}">You do not have permission to open this page.</c:when>
      <c:when test="${code == 404}">The page you are looking for does not exist.</c:when>
      <c:otherwise>Please try again. If the problem continues contact the administrator.</c:otherwise>
    </c:choose>
  </p>
  <a href="${ctx}/" class="btn btn-primary"><i class="bi bi-house"></i> Back to home</a>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
