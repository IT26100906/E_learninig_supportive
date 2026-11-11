<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Sign up"/><jsp:param name="frosted" value="true"/></jsp:include>

<div class="glass-wrap">
  <div class="glass-card wide signup-card">
    <h1 class="glass-title">Sign up</h1>
    <div class="glass-links">
      <a href="${ctx}/login">Already registered?</a>
      <span class="reg-note">Fields marked * are required &middot; your Student ID is created for you</span>
    </div>

    <form action="${ctx}/register" method="post">
      <jsp:include page="/WEB-INF/views/common/level-picker.jsp"/>

      <div class="mb-3">
        <label class="glabel" for="name">Full Name *</label>
        <div class="gfield"><span class="gicon"><i class="bi bi-person-fill"></i></span>
          <input type="text" id="name" name="name" required maxlength="60" placeholder="Your full name"
                 value="<c:out value='${param.name}'/>"></div>
      </div>

      <div class="mb-3">
        <label class="glabel" for="email">Email *</label>
        <div class="gfield"><span class="gicon"><i class="bi bi-envelope-fill"></i></span>
          <input type="email" id="email" name="email" required maxlength="100" placeholder="name@example.com"
                 value="<c:out value='${param.email}'/>"></div>
      </div>

      <div class="row">
        <div class="col-md-6 mb-3">
          <label class="glabel" for="password">Password *</label>
          <div class="gfield"><span class="gicon"><i class="bi bi-key-fill"></i></span>
            <input type="password" id="password" name="password" required minlength="6" maxlength="64"
                   placeholder="Password" data-pw-meter>
            <button class="gtoggle toggle-pw" type="button" aria-label="Show password"><i class="bi bi-eye"></i></button></div>
          <div class="progress pw-meter mt-2"><div class="progress-bar pw-bar" style="width:0"></div></div>
          <small class="pw-text text-muted"></small>
          <div class="form-text">At least 6 characters with a letter and a digit.</div>
        </div>
        <div class="col-md-6 mb-3">
          <label class="glabel" for="confirmPassword">Confirm Password *</label>
          <div class="gfield"><span class="gicon"><i class="bi bi-key-fill"></i></span>
            <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Repeat password">
            <button class="gtoggle toggle-pw" type="button" aria-label="Show password"><i class="bi bi-eye"></i></button></div>
        </div>
      </div>

      <div class="row">
        <div class="col-md-6 mb-3">
          <label class="glabel" for="phone">Phone</label>
          <div class="gfield"><span class="gicon"><i class="bi bi-telephone-fill"></i></span>
            <input type="tel" id="phone" name="phone" maxlength="16" pattern="\+?[0-9]{9,15}" placeholder="0771234567"
                   value="<c:out value='${param.phone}'/>"></div>
        </div>
        <div class="col-md-6 mb-3">
          <label class="glabel" for="dob">Date of Birth</label>
          <div class="gfield"><span class="gicon"><i class="bi bi-calendar-event-fill"></i></span>
            <input type="date" id="dob" name="dob" data-past value="<c:out value='${param.dob}'/>"></div>
        </div>
      </div>

      <div class="mb-3">
        <label class="glabel" for="address">Address</label>
        <div class="gfield"><span class="gicon"><i class="bi bi-geo-alt-fill"></i></span>
          <input type="text" id="address" name="address" maxlength="150" placeholder="Your address"
                 value="<c:out value='${param.address}'/>"></div>
      </div>

      <div class="row">
        <div class="col-md-6 mb-3">
          <label class="glabel" for="question">Security question *</label>
          <div class="gfield"><span class="gicon"><i class="bi bi-shield-lock-fill"></i></span>
            <select id="question" name="question" required>
              <option value="">Choose a question</option>
              <c:forEach var="q" items="${questions}">
                <option value="<c:out value='${q}'/>" ${param.question == q ? 'selected' : ''}><c:out value="${q}"/></option>
              </c:forEach>
            </select></div>
        </div>
        <div class="col-md-6 mb-3">
          <label class="glabel" for="answer">Your answer *</label>
          <div class="gfield"><span class="gicon"><i class="bi bi-chat-dots-fill"></i></span>
            <input type="text" id="answer" name="answer" required maxlength="60" placeholder="Answer"></div>
        </div>
      </div>

      <div class="text-center mt-3">
        <button type="submit" class="gbtn">Sign up</button>
      </div>
    </form>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
