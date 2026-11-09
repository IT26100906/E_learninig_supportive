<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Edit Profile"/></jsp:include>
<c:set var="posted" value="${not empty errors}"/>

<div class="auth-card wide">
  <div class="card">
    <div class="card-body p-4">
      <h3 class="text-center mb-4"><i class="bi bi-pencil-square text-brand"></i> Edit Profile</h3>

      <form action="${ctx}/profile/edit" method="post">
        <div class="mb-3">
          <label class="form-label">Student ID</label>
          <input type="text" class="form-control" readonly value="<c:out value='${currentUser.id}'/>">
          <div class="form-text">Student ID cannot be changed.</div>
        </div>
        <div class="row">
          <div class="col-md-6 mb-3">
            <label class="form-label" for="name">Full Name *</label>
            <input type="text" class="form-control" id="name" name="name" required maxlength="60"
                   value="<c:out value='${posted ? param.name : currentUser.name}'/>">
          </div>
          <div class="col-md-6 mb-3">
            <label class="form-label" for="email">Email *</label>
            <input type="email" class="form-control" id="email" name="email" required maxlength="100"
                   value="<c:out value='${posted ? param.email : currentUser.email}'/>">
          </div>
        </div>
        <div class="row">
          <div class="col-md-6 mb-3">
            <label class="form-label" for="phone">Phone</label>
            <input type="tel" class="form-control" id="phone" name="phone" maxlength="16" pattern="\+?[0-9]{9,15}"
                   value="<c:out value='${posted ? param.phone : currentUser.phone}'/>">
          </div>
          <div class="col-md-6 mb-3">
            <label class="form-label" for="dob">Date of Birth</label>
            <input type="date" class="form-control" id="dob" name="dob" data-past
                   value="<c:out value='${posted ? param.dob : currentUser.dateOfBirthText}'/>">
          </div>
        </div>
        <c:if test="${not currentUser.canManageUsers()}">
          <c:set var="lv" value="${currentUser.level.code}"/>
          <c:set var="curDetail" value="${posted ? param.levelDetail : currentUser.levelDetail}"/>
          <div class="mb-3">
            <label class="form-label" for="levelDetail"><c:out value="${currentUser.level.icon}"/> <c:out value="${currentUser.level.detailLabel}"/> (<c:out value="${currentUser.level.label}"/>)</label>
            <c:choose>
              <c:when test="${lv == 'CHILD'}">
                <select class="form-select" id="levelDetail" name="levelDetail" required>
                  <c:forEach begin="3" end="7" var="a"><option value="${a}" ${curDetail eq a ? 'selected' : ''}>${a} years</option></c:forEach>
                </select>
              </c:when>
              <c:when test="${lv == 'SCHOOL'}">
                <select class="form-select" id="levelDetail" name="levelDetail" required>
                  <c:forEach begin="1" end="11" var="g"><option value="${g}" ${curDetail eq g ? 'selected' : ''}>Grade ${g}</option></c:forEach>
                </select>
              </c:when>
              <c:when test="${lv == 'AL'}">
                <select class="form-select" id="levelDetail" name="levelDetail" required>
                  <c:forEach var="s" items="${streams}"><option value="<c:out value='${s}'/>" ${curDetail == s ? 'selected' : ''}><c:out value="${s}"/></option></c:forEach>
                </select>
              </c:when>
              <c:otherwise>
                <input type="text" class="form-control" id="levelDetail" name="levelDetail" maxlength="60"
                       placeholder="e.g. BSc (Hons) in Information Technology" value="<c:out value='${curDetail}'/>">
              </c:otherwise>
            </c:choose>
          </div>
        </c:if>
        <div class="mb-4">
          <label class="form-label" for="address">Address</label>
          <input type="text" class="form-control" id="address" name="address" maxlength="150"
                 value="<c:out value='${posted ? param.address : currentUser.address}'/>">
        </div>
        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-primary flex-fill">Save changes</button>
          <a href="${ctx}/profile" class="btn btn-outline-secondary flex-fill">Cancel</a>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
