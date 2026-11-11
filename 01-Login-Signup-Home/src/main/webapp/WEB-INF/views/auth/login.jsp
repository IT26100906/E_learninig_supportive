<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Sign in"/><jsp:param name="frosted" value="true"/><jsp:param name="liquid" value="true"/></jsp:include>



<div class="glass-wrap">
  <div class="glass-card">
    <h1 class="glass-title">Sign in</h1>
    <p class="glass-sub">Welcome back! Sign in to continue learning.</p>
    <div class="glass-links">
      <a href="${ctx}/register">Not registered?</a>
      <a href="${ctx}/forgot-password">Forgot Password?</a>
    </div>

    <form action="${ctx}/login" method="post">
      <div class="mb-3">
        <div class="gfield">
          <span class="gicon"><i class="bi bi-person-fill"></i></span>
          <input type="text" name="idOrEmail" placeholder="Student ID or Email" aria-label="Student ID or Email"
                 maxlength="100" required autofocus
                 value="<c:out value='${not empty param.idOrEmail ? param.idOrEmail : rememberedUser}'/>">
        </div>
      </div>
      <div class="mb-3">
        <div class="gfield">
          <span class="gicon"><i class="bi bi-key-fill"></i></span>
          <input type="password" name="password" placeholder="Password" aria-label="Password" required>
          <button class="gtoggle toggle-pw" type="button" aria-label="Show password"><i class="bi bi-eye"></i></button>
        </div>
      </div>
      <label class="gcheck">
        <input type="checkbox" name="remember" ${not empty rememberedUser or param.remember == 'on' ? 'checked' : ''}>
        <span>Remember me</span>
      </label>
      <div class="text-center">
        <button type="submit" class="gbtn">Sign in</button>
      </div>
    </form>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
