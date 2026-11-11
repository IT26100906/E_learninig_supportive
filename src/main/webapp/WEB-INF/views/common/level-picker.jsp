<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%-- Who is the learner? Child / Grade 1-11 / A-L / Undergraduate.  Needs request attributes: selLevel, selDetail, streams --%>
<c:set var="L" value="${selLevel}"/>
<label class="glabel">I am a *</label>
<div class="level-grid mb-3">
  <label class="level-card"><input type="radio" name="level" value="CHILD" required ${L == 'CHILD' ? 'checked' : ''}>
    <div class="lc-body"><span class="lc-icon">&#129490;</span><strong>Child</strong><small>Ages 3 - 7</small></div></label>
  <label class="level-card"><input type="radio" name="level" value="SCHOOL" ${L == 'SCHOOL' ? 'checked' : ''}>
    <div class="lc-body"><span class="lc-icon">&#127890;</span><strong>Grade 1 - 11</strong><small>School student</small></div></label>
  <label class="level-card"><input type="radio" name="level" value="AL" ${L == 'AL' ? 'checked' : ''}>
    <div class="lc-body"><span class="lc-icon">&#128218;</span><strong>A/L</strong><small>Advanced Level</small></div></label>
  <label class="level-card"><input type="radio" name="level" value="UNDERGRAD" ${L == 'UNDERGRAD' ? 'checked' : ''}>
    <div class="lc-body"><span class="lc-icon">&#127891;</span><strong>Undergraduate</strong><small>University student</small></div></label>
</div>

<div class="level-detail mb-3" data-level="CHILD" ${L == 'CHILD' ? '' : 'hidden'}>
  <label class="glabel" for="detailChild">Age *</label>
  <div class="gfield"><span class="gicon"><i class="bi bi-balloon-heart-fill"></i></span>
    <select id="detailChild" name="detailChild" required ${L == 'CHILD' ? '' : 'disabled'}>
      <option value="">Select age</option>
      <c:forEach begin="3" end="7" var="a"><option value="${a}" ${L == 'CHILD' && selDetail eq a ? 'selected' : ''}>${a} years</option></c:forEach>
    </select></div>
</div>

<div class="level-detail mb-3" data-level="SCHOOL" ${L == 'SCHOOL' ? '' : 'hidden'}>
  <label class="glabel" for="detailSchool">Grade *</label>
  <div class="gfield"><span class="gicon"><i class="bi bi-backpack-fill"></i></span>
    <select id="detailSchool" name="detailSchool" required ${L == 'SCHOOL' ? '' : 'disabled'}>
      <option value="">Select grade</option>
      <c:forEach begin="1" end="11" var="g"><option value="${g}" ${L == 'SCHOOL' && selDetail eq g ? 'selected' : ''}>Grade ${g}</option></c:forEach>
    </select></div>
</div>

<div class="level-detail mb-3" data-level="AL" ${L == 'AL' ? '' : 'hidden'}>
  <label class="glabel" for="detailAl">A/L stream *</label>
  <div class="gfield"><span class="gicon"><i class="bi bi-journal-text"></i></span>
    <select id="detailAl" name="detailAl" required ${L == 'AL' ? '' : 'disabled'}>
      <option value="">Select stream</option>
      <c:forEach var="s" items="${streams}"><option value="<c:out value='${s}'/>" ${L == 'AL' && selDetail == s ? 'selected' : ''}><c:out value="${s}"/></option></c:forEach>
    </select></div>
</div>

<div class="level-detail mb-3" data-level="UNDERGRAD" ${L == 'UNDERGRAD' ? '' : 'hidden'}>
  <label class="glabel" for="detailUni">Degree / Course *</label>
  <div class="gfield"><span class="gicon"><i class="bi bi-mortarboard-fill"></i></span>
    <select id="detailUni" name="detailUni" required ${L == 'UNDERGRAD' ? '' : 'disabled'}>
      <option value="">Select your degree</option>
      <c:forEach var="grp" items="${degrees}">
        <optgroup label="<c:out value='${grp.key}'/>">
          <c:forEach var="d" items="${grp.value}"><option value="<c:out value='${d}'/>" ${L == 'UNDERGRAD' && selDetail == d ? 'selected' : ''}><c:out value="${d}"/></option></c:forEach>
        </optgroup>
      </c:forEach>
      <c:if test="${not empty degreeExtra}"><option value="<c:out value='${degreeExtra}'/>" selected><c:out value="${degreeExtra}"/></option></c:if>
    </select></div>
  <div class="form-text">Pick your degree. We will show the courses that match it.</div>
</div>
