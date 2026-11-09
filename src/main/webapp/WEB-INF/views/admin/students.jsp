<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Manage Students"/></jsp:include>

<div class="glass-bar p-3 d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
  <h3 class="mb-0"><i class="bi bi-people text-brand"></i> Students <span class="badge text-bg-secondary">${result.totalItems}</span></h3>
  <div class="d-flex gap-2">
    <a href="${ctx}/admin/students/form" class="btn btn-primary"><i class="bi bi-person-plus"></i> Add student</a>
    <a href="${ctx}/admin/students/export" class="btn btn-outline-secondary"><i class="bi bi-download"></i> Export CSV</a>
  </div>
</div>

<div class="card mb-3">
  <div class="card-body">
    <form action="${ctx}/admin/students" method="get" class="row g-2">
      <div class="col-md-3">
        <input type="text" class="form-control" name="q" placeholder="Search by ID, name or email" value="<c:out value='${q}'/>">
      </div>
      <div class="col-md-2">
        <select name="level" class="form-select">
          <option value="ALL" ${level == 'ALL' ? 'selected' : ''}>All levels</option>
          <option value="CHILD" ${level == 'CHILD' ? 'selected' : ''}>Child</option>
          <option value="SCHOOL" ${level == 'SCHOOL' ? 'selected' : ''}>Grade 1 - 11</option>
          <option value="AL" ${level == 'AL' ? 'selected' : ''}>A/L</option>
          <option value="UNDERGRAD" ${level == 'UNDERGRAD' ? 'selected' : ''}>Undergraduate</option>
        </select>
      </div>
      <div class="col-md-2">
        <select name="status" class="form-select">
          <option value="ALL" ${status == 'ALL' ? 'selected' : ''}>All status</option>
          <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Active</option>
          <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
        </select>
      </div>
      <div class="col-md-2">
        <select name="sort" class="form-select">
          <option value="id" ${sort == 'id' ? 'selected' : ''}>Sort by ID</option>
          <option value="name" ${sort == 'name' ? 'selected' : ''}>Sort by name</option>
          <option value="email" ${sort == 'email' ? 'selected' : ''}>Sort by email</option>
          <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Newest first</option>
        </select>
      </div>
      <div class="col-md-1 d-flex gap-1">
        <button class="btn btn-primary flex-fill" type="submit"><i class="bi bi-search"></i></button>
        <a class="btn btn-outline-secondary flex-fill" href="${ctx}/admin/students">Reset</a>
      </div>
    </form>
  </div>
</div>

<div class="card">
  <div class="table-responsive">
    <table class="table table-hover mb-0">
      <thead class="table-light">
        <tr><th></th><th>ID</th><th>Name</th><th>Email</th><th>Level</th><th>Type</th><th>Status</th><th>Last login</th><th class="text-end">Actions</th></tr>
      </thead>
      <tbody>
        <c:forEach var="s" items="${result.items}">
          <tr>
            <td>
              <c:choose>
                <c:when test="${not empty s.profilePicture}"><img class="avatar avatar-sm" src="${ctx}/photo?id=<c:out value='${s.id}'/>" alt=""></c:when>
                <c:otherwise><span class="avatar avatar-sm avatar-initials"><c:out value="${s.initials}"/></span></c:otherwise>
              </c:choose>
            </td>
            <td><strong><c:out value="${s.id}"/></strong></td>
            <td><c:out value="${s.name}"/></td>
            <td><c:out value="${s.email}"/></td>
            <td><c:out value="${s.level.icon}"/> <c:out value="${s.levelDisplay}"/></td>
            <td><span class="badge ${s.type == 'PREMIUM' ? 'text-bg-warning' : 'text-bg-light border'}"><c:out value="${s.membershipLabel}"/></span></td>
            <td><span class="badge ${s.active ? 'text-bg-success' : 'text-bg-danger'}"><c:out value="${s.status}"/></span></td>
            <td class="small text-muted">${s.lastLoginText}</td>
            <td class="text-end text-nowrap">
              <a class="btn btn-sm btn-outline-primary" href="${ctx}/admin/students/form?id=<c:out value='${s.id}'/>" title="Edit"><i class="bi bi-pencil"></i></a>

              <form action="${ctx}/admin/students" method="post" class="d-inline">
                <input type="hidden" name="id" value="<c:out value='${s.id}'/>">
                <input type="hidden" name="back" value="?<c:out value='${qs}'/>&page=${result.page}">
                <c:choose>
                  <c:when test="${s.active}">
                    <input type="hidden" name="action" value="deactivate">
                    <button class="btn btn-sm btn-outline-warning" type="submit" title="Deactivate"><i class="bi bi-pause-circle"></i></button>
                  </c:when>
                  <c:otherwise>
                    <input type="hidden" name="action" value="activate">
                    <button class="btn btn-sm btn-outline-success" type="submit" title="Activate"><i class="bi bi-play-circle"></i></button>
                  </c:otherwise>
                </c:choose>
              </form>

              <form action="${ctx}/admin/students" method="post" class="d-inline"
                    data-confirm="Delete student <c:out value='${s.id}'/> permanently?">
                <input type="hidden" name="id" value="<c:out value='${s.id}'/>">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="back" value="?<c:out value='${qs}'/>&page=${result.page}">
                <button class="btn btn-sm btn-outline-danger" type="submit" title="Delete"><i class="bi bi-trash"></i></button>
              </form>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty result.items}">
          <tr><td colspan="9" class="text-center text-muted py-4">No students found.</td></tr>
        </c:if>
      </tbody>
    </table>
  </div>

  <c:if test="${result.totalPages > 1}">
    <div class="card-footer bg-transparent">
      <nav>
        <ul class="pagination pagination-sm justify-content-center mb-0">
          <li class="page-item ${result.hasPrevious ? '' : 'disabled'}">
            <a class="page-link" href="${ctx}/admin/students?<c:out value='${qs}'/>&page=${result.page - 1}">Previous</a>
          </li>
          <c:forEach begin="1" end="${result.totalPages}" var="n">
            <li class="page-item ${n == result.page ? 'active' : ''}">
              <a class="page-link" href="${ctx}/admin/students?<c:out value='${qs}'/>&page=${n}">${n}</a>
            </li>
          </c:forEach>
          <li class="page-item ${result.hasNext ? '' : 'disabled'}">
            <a class="page-link" href="${ctx}/admin/students?<c:out value='${qs}'/>&page=${result.page + 1}">Next</a>
          </li>
        </ul>
      </nav>
    </div>
  </c:if>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
