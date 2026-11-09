<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%-- Admin pages: the real students (id, name, level ...) written as hidden data so the page script can read them safely --%>
<div id="roster" hidden>
  <c:forEach var="r" items="${roster}">
    <i data-id="<c:out value='${r.id}'/>" data-name="<c:out value='${r.name}'/>" data-email="<c:out value='${r.email}'/>"
       data-lv="${r.level.code}" data-detail="<c:out value='${r.levelDetail}'/>" data-member="<c:out value='${r.membershipLabel}'/>"
       data-max="${r.maxEnrollments}" data-status="${r.status}"></i>
  </c:forEach>
</div>
<script>
/* LH.roster(): [{id, name, email, lv, detail, member, max, status}] */
(function () {
  var cache = null;
  window.getRoster = function () {
    if (!cache) cache = Array.prototype.map.call(document.querySelectorAll('#roster i'), function (i) {
      var d = i.dataset; return {id: d.id, name: d.name, email: d.email, lv: d.lv, detail: d.detail, member: d.member, max: parseInt(d.max, 10) || 0, status: d.status};
    });
    return cache;
  };
})();
</script>
