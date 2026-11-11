<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="editing" value="${not empty student}"/>
<c:set var="posted" value="${not empty errors}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Student Form"/></jsp:include>

<div class="auth-card wide">
  <div class="card">
    <div class="card-body p-4">
      <h3 class="text-center mb-4">
        <i class="bi ${editing ? 'bi-pencil-square' : 'bi-person-plus'} text-brand"></i>
        ${editing ? 'Edit Student' : 'Add New Student'}
      </h3>

      <form action="${ctx}/admin/students/form" method="post">
        <input type="hidden" name="mode" value="${editing ? 'edit' : 'create'}">

        <div class="row">
          <div class="col-md-6 mb-3">
            <label class="form-label" for="id">Student ID *</label>
            <c:choose>
              <c:when test="${editing}">
                <input type="text" class="form-control" id="id" name="id" readonly value="<c:out value='${student.id}'/>">
              </c:when>
              <c:otherwise>
                <input type="text" class="form-control" id="id" name="id" required maxlength="12" placeholder="e.g. S010"
                       pattern="[A-Za-z][A-Za-z0-9]{2,11}" value="<c:out value='${param.id}'/>">
              </c:otherwise>
            </c:choose>
          </div>
          <div class="col-md-6 mb-3">
            <label class="form-label" for="name">Full Name *</label>
            <input type="text" class="form-control" id="name" name="name" required maxlength="60"
                   value="<c:out value='${posted ? param.name : student.name}'/>">
          </div>
        </div>

        <div class="row">
          <div class="col-md-6 mb-3">
            <label class="form-label" for="email">Email *</label>
            <input type="email" class="form-control" id="email" name="email" required maxlength="100"
                   value="<c:out value='${posted ? param.email : student.email}'/>">
          </div>
          <div class="col-md-6 mb-3">
            <label class="form-label" for="phone">Phone</label>
            <input type="tel" class="form-control" id="phone" name="phone" maxlength="16" pattern="\+?[0-9]{9,15}"
                   value="<c:out value='${posted ? param.phone : student.phone}'/>">
          </div>
        </div>

        <div class="row">
          <div class="col-md-6 mb-3">
            <label class="form-label" for="dob">Date of Birth</label>
            <input type="date" class="form-control" id="dob" name="dob" data-past
                   value="<c:out value='${posted ? param.dob : student.dateOfBirthText}'/>">
          </div>
          <div class="col-md-6 mb-3">
            <label class="form-label" for="address">Address</label>
            <input type="text" class="form-control" id="address" name="address" maxlength="150"
                   value="<c:out value='${posted ? param.address : student.address}'/>">
          </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/level-picker.jsp"/>

        <div class="row">
          <div class="col-md-6 mb-3">
            <label class="form-label" for="membership">Membership</label>
            <c:set var="curType" value="${posted ? param.membership : student.type}"/>
            <select class="form-select" id="membership" name="membership">
              <option value="STUDENT" ${curType != 'PREMIUM' ? 'selected' : ''}>Regular (5 courses)</option>
              <option value="PREMIUM" ${curType == 'PREMIUM' ? 'selected' : ''}>Premium (15 courses)</option>
            </select>
          </div>
          <c:if test="${editing}">
            <div class="col-md-6 mb-3">
              <label class="form-label" for="status">Account status</label>
              <c:set var="curStatus" value="${posted ? param.status : student.status}"/>
              <select class="form-select" id="status" name="status">
                <option value="ACTIVE" ${curStatus == 'ACTIVE' ? 'selected' : ''}>Active</option>
                <option value="INACTIVE" ${curStatus == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
              </select>
            </div>
          </c:if>
        </div>

        <c:choose>
          <c:when test="${editing}">
            <div class="mb-3">
              <label class="form-label" for="newPassword">Reset password <span class="text-muted fw-normal">(leave blank to keep the current password)</span></label>
              <div class="input-group">
                <input type="password" class="form-control" id="newPassword" name="newPassword" maxlength="64" autocomplete="new-password">
                <button class="btn btn-outline-secondary toggle-pw" type="button"><i class="bi bi-eye"></i></button>
              </div>
            </div>
          </c:when>
          <c:otherwise>
            <div class="mb-3">
              <label class="form-label" for="password">Temporary password *</label>
              <div class="input-group">
                <input type="password" class="form-control" id="password" name="password" required minlength="6" maxlength="64" autocomplete="new-password">
                <button class="btn btn-outline-secondary toggle-pw" type="button"><i class="bi bi-eye"></i></button>
              </div>
              <div class="form-text">At least 6 characters with a letter and a digit.</div>
            </div>
            <div class="card bg-light border-0 mb-3"><div class="card-body">
              <h6><i class="bi bi-shield-lock"></i> Security question</h6>
              <select class="form-select mb-2" name="question" required>
                <option value="">-- choose a question --</option>
                <c:forEach var="q" items="${questions}">
                  <option value="<c:out value='${q}'/>" ${param.question == q ? 'selected' : ''}><c:out value="${q}"/></option>
                </c:forEach>
              </select>
              <input type="text" class="form-control" name="answer" placeholder="Answer" required maxlength="60">
            </div></div>
          </c:otherwise>
        </c:choose>

        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-primary flex-fill">${editing ? 'Save changes' : 'Add student'}</button>
          <a href="${ctx}/admin/students" class="btn btn-outline-secondary flex-fill">Cancel</a>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
