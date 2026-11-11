<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Change Password"/></jsp:include>

<div class="auth-card">
  <div class="card">
    <div class="card-body p-4">
      <h3 class="text-center mb-4"><i class="bi bi-key text-brand"></i> Change Password</h3>
      <form action="${ctx}/change-password" method="post">
        <div class="mb-3">
          <label class="form-label" for="oldPassword">Current password</label>
          <div class="input-group">
            <input type="password" class="form-control" id="oldPassword" name="oldPassword" required>
            <button class="btn btn-outline-secondary toggle-pw" type="button"><i class="bi bi-eye"></i></button>
          </div>
        </div>
        <div class="mb-3">
          <label class="form-label" for="newPassword">New password</label>
          <div class="input-group">
            <input type="password" class="form-control" id="newPassword" name="newPassword" required minlength="6" maxlength="64" data-pw-meter>
            <button class="btn btn-outline-secondary toggle-pw" type="button"><i class="bi bi-eye"></i></button>
          </div>
          <div class="progress pw-meter mt-2"><div class="progress-bar pw-bar" style="width:0"></div></div>
          <small class="pw-text text-muted"></small>
        </div>
        <div class="mb-3">
          <label class="form-label" for="confirmPassword">Confirm new password</label>
          <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
        </div>
        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-primary flex-fill">Update password</button>
          <a href="${ctx}${currentUser.homePath}" class="btn btn-outline-secondary flex-fill">Cancel</a>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
