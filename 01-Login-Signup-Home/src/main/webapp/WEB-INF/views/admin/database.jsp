<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Database"/></jsp:include>

<div class="glass-bar p-3 d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
  <div>
    <h3 class="mb-0"><i class="bi bi-database text-brand"></i> Database</h3>
    <div class="text-muted"><c:out value="${dbKind}"/> &ndash; <c:out value="${dbName}"/> &middot; read-only view (passwords and hashes are hidden)</div>
  </div>
  <a href="${ctx}/admin/dashboard" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Dashboard</a>
</div>

<c:if test="${not empty dbError}">
  <div class="alert alert-danger"><c:out value="${dbError}"/></div>
</c:if>

<div class="row g-3">
  <div class="col-lg-3">
    <div class="card">
      <div class="card-header"><i class="bi bi-table"></i> Tables <span class="badge db-count">${tables.size()}</span></div>
      <div class="list-group list-group-flush">
        <c:forEach var="t" items="${tables}">
          <a class="list-group-item list-group-item-action db-table-link d-flex justify-content-between align-items-center ${t.name == selected ? 'active' : ''}"
             href="${ctx}/admin/database?table=<c:out value='${t.name}'/>">
            <span><i class="bi bi-table"></i> <c:out value="${t.name}"/></span>
            <span class="badge db-count">${t.count}</span>
          </a>
        </c:forEach>
      </div>
    </div>
  </div>

  <div class="col-lg-9">
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
        <span><i class="bi bi-table"></i> <c:out value="${selected}"/>
          <span class="text-muted fw-normal small">&middot; showing ${from}&ndash;${to} of ${total} rows</span></span>
        <c:if test="${not empty pk}">
          <span class="small text-muted"><i class="bi bi-key"></i> key: <c:forEach var="k" items="${pk}" varStatus="s"><c:out value="${k}"/><c:if test="${!s.last}">, </c:if></c:forEach></span>
        </c:if>
      </div>
      <div class="table-responsive">
        <table class="table table-hover table-sm mb-0 db-grid">
          <thead class="table-light">
            <tr><c:forEach var="col" items="${cols}"><th class="text-nowrap"><c:out value="${col}"/></th></c:forEach></tr>
          </thead>
          <tbody>
            <c:forEach var="row" items="${rows}">
              <tr>
                <c:forEach var="v" items="${row}">
                  <td><c:choose>
                    <c:when test="${v == null}"><span class="text-muted fst-italic">NULL</span></c:when>
                    <c:otherwise><c:out value="${v}"/></c:otherwise>
                  </c:choose></td>
                </c:forEach>
              </tr>
            </c:forEach>
            <c:if test="${empty rows}">
              <tr><td colspan="${empty cols ? 1 : cols.size()}" class="text-center text-muted py-4">This table has no rows yet.</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
      <c:if test="${pages > 1}">
        <div class="card-footer d-flex justify-content-between align-items-center">
          <span class="small text-muted">Page ${page} of ${pages}</span>
          <div class="btn-group">
            <a class="btn btn-sm btn-outline-primary ${page <= 1 ? 'disabled' : ''}" href="${ctx}/admin/database?table=<c:out value='${selected}'/>&page=${page - 1}"><i class="bi bi-chevron-left"></i> Prev</a>
            <a class="btn btn-sm btn-outline-primary ${page >= pages ? 'disabled' : ''}" href="${ctx}/admin/database?table=<c:out value='${selected}'/>&page=${page + 1}">Next <i class="bi bi-chevron-right"></i></a>
          </div>
        </div>
      </c:if>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
