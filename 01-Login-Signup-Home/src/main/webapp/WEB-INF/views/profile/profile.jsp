<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="My Profile"/></jsp:include>

<div class="row g-4">
  <div class="col-lg-4">
    <div class="card text-center">
      <div class="card-body p-4">
        <c:choose>
          <c:when test="${not empty currentUser.profilePicture}">
            <img class="avatar avatar-lg mb-3" src="${ctx}/photo?id=<c:out value='${currentUser.id}'/>" alt="Profile picture">
          </c:when>
          <c:otherwise>
            <span class="avatar avatar-lg avatar-initials mb-3"><c:out value="${currentUser.initials}"/></span>
          </c:otherwise>
        </c:choose>
        <h5 class="mb-0"><c:out value="${currentUser.name}"/></h5>
        <div class="text-muted mb-3"><c:out value="${currentUser.id}"/></div>

        <form action="${ctx}/profile/photo" method="post" enctype="multipart/form-data" class="mb-2">
          <label class="btn btn-outline-primary btn-sm w-100">
            <i class="bi bi-camera"></i> Upload picture
            <input type="file" name="photo" accept="image/png,image/jpeg,image/gif" hidden data-autosubmit>
          </label>
        </form>
        <c:if test="${not empty currentUser.profilePicture}">
          <form action="${ctx}/profile/photo/remove" method="post" data-confirm="Remove your profile picture?">
            <button class="btn btn-outline-secondary btn-sm w-100" type="submit"><i class="bi bi-trash"></i> Remove picture</button>
          </form>
        </c:if>
        <div class="form-text mt-2">JPG, PNG or GIF, max 2 MB</div>
      </div>
    </div>
  </div>

  <div class="col-lg-8">
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="bi bi-person-lines-fill"></i> My details</span>
        <span>
          <a href="${ctx}/profile/edit" class="btn btn-primary btn-sm"><i class="bi bi-pencil-square"></i> Edit</a>
          <a href="${ctx}/change-password" class="btn btn-outline-primary btn-sm"><i class="bi bi-key"></i> Password</a>
        </span>
      </div>
      <div class="card-body">
        <div class="detail-row"><div class="detail-label">Student ID</div><div><c:out value="${currentUser.id}"/></div></div>
        <div class="detail-row"><div class="detail-label">Full name</div><div><c:out value="${currentUser.name}"/></div></div>
        <div class="detail-row"><div class="detail-label">Email</div><div><c:out value="${currentUser.email}"/></div></div>
        <div class="detail-row"><div class="detail-label">Phone</div><div><c:out value="${empty currentUser.phone ? '-' : currentUser.phone}"/></div></div>
        <div class="detail-row"><div class="detail-label">Date of birth</div><div><c:out value="${empty currentUser.dateOfBirthText ? '-' : currentUser.dateOfBirthText}"/></div></div>
        <div class="detail-row"><div class="detail-label">Address</div><div><c:out value="${empty currentUser.address ? '-' : currentUser.address}"/></div></div>
        <c:if test="${not currentUser.canManageUsers()}">
          <div class="detail-row"><div class="detail-label">Learner type</div><div><c:out value="${currentUser.level.icon}"/> <c:out value="${currentUser.level.label}"/></div></div>
          <div class="detail-row"><div class="detail-label"><c:out value="${currentUser.level.detailLabel}"/></div><div><c:out value="${empty currentUser.levelDetail ? '-' : currentUser.levelDisplay}"/></div></div>
        </c:if>
        <div class="detail-row"><div class="detail-label">Account type</div><div><span class="badge text-bg-primary"><c:out value="${currentUser.role}"/></span></div></div>
        <div class="detail-row"><div class="detail-label">Status</div><div><span class="badge text-bg-success"><c:out value="${currentUser.status}"/></span></div></div>
        <div class="detail-row"><div class="detail-label">Registered</div><div>${currentUser.registeredDate}</div></div>
        <div class="detail-row"><div class="detail-label">Last login</div><div>${currentUser.lastLoginText}</div></div>
      </div>
    </div>

  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
