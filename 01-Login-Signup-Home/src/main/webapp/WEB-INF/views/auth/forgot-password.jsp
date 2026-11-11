<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Forgot Password"/></jsp:include>

<div class="glass-wrap">
  <div class="glass-card">
    <h1 class="glass-title">Reset password</h1>
    <div class="glass-links">
      <a href="${ctx}/login">Back to sign in</a>
      <a href="${ctx}/register">Not registered?</a>
    </div>

    <c:choose>
      <%-- STEP 2: answer the security question --%>
      <c:when test="${not empty question}">
        <form action="${ctx}/forgot-password" method="post">
          <input type="hidden" name="step" value="reset">
          <input type="hidden" name="id" value="<c:out value='${studentId}'/>">
          <p class="text-muted ms-2">Account: <strong><c:out value="${studentId}"/></strong></p>
          <div class="mb-3">
            <label class="glabel">Security question</label>
            <div class="gfield"><span class="gicon"><i class="bi bi-shield-lock-fill"></i></span>
              <input type="text" readonly value="<c:out value='${question}'/>"></div>
          </div>
          <div class="mb-3">
            <div class="gfield"><span class="gicon"><i class="bi bi-chat-dots-fill"></i></span>
              <input type="text" name="answer" placeholder="Your answer" aria-label="Your answer" required autofocus></div>
          </div>
          <div class="mb-3">
            <div class="gfield"><span class="gicon"><i class="bi bi-key-fill"></i></span>
              <input type="password" id="newPassword" name="newPassword" placeholder="New password" aria-label="New password"
                     required minlength="6" maxlength="64" data-pw-meter>
              <button class="gtoggle toggle-pw" type="button" aria-label="Show password"><i class="bi bi-eye"></i></button></div>
            <div class="progress pw-meter mt-2"><div class="progress-bar pw-bar" style="width:0"></div></div>
            <small class="pw-text text-muted"></small>
          </div>
          <div class="mb-3">
            <div class="gfield"><span class="gicon"><i class="bi bi-key-fill"></i></span>
              <input type="password" name="confirmPassword" placeholder="Confirm new password" aria-label="Confirm new password" required></div>
          </div>
          <div class="text-center mt-4"><button type="submit" class="gbtn">Reset password</button></div>
        </form>
      </c:when>

      <%-- STEP 1: enter Student ID --%>
      <c:otherwise>
        <form action="${ctx}/forgot-password" method="post">
          <input type="hidden" name="step" value="lookup">
          <div class="mb-4">
            <div class="gfield"><span class="gicon"><i class="bi bi-person-fill"></i></span>
              <input type="text" name="id" placeholder="Student ID" aria-label="Student ID" required autofocus maxlength="12"
                     value="<c:out value='${param.id}'/>"></div>
          </div>
          <div class="text-center"><button type="submit" class="gbtn">Continue</button></div>
        </form>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
