<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
</main>

<footer class="app-footer py-3 mt-4">
  <div class="container d-flex flex-wrap justify-content-between">
    <span>&copy; LearnHub &ndash; E-Learning Supportive System</span>
    <span>Student Account Management module</span>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${ctx}/js/app.js"></script>
<script src="${ctx}/js/liquid.js"></script>
<script src="${ctx}/js/store.js"></script>
<script src="${ctx}/js/modules.js?v=12"></script>
<script src="${ctx}/js/courses.js?v=12"></script>
<script src="${ctx}/js/readable.js"></script>
<script>
/* Module switch: a link to a page whose module is not installed is dimmed and shows a message instead of a 404.
   Each module servlet sets applicationScope['mod.<name>'] when it starts. */
(function () {
  var ctx = '${ctx}';
  var MODS = {
    '/course-details': ${not empty applicationScope['mod.details']},
    '/course-notes': ${not empty applicationScope['mod.notes']},
    '/course-enrollment': ${not empty applicationScope['mod.enrollment']},
    '/assignments': ${not empty applicationScope['mod.assignments']},
    '/course-feedback': ${not empty applicationScope['mod.feedback']},
    '/payment': ${not empty applicationScope['mod.payment']}
  };
  function gone(href) {
    if (!href) return false;
    var p = href.split('#')[0].split('?')[0];
    try { p = new URL(p, location.href).pathname; } catch (e) {}
    if (ctx && p.indexOf(ctx) === 0) p = p.substring(ctx.length);
    return Object.prototype.hasOwnProperty.call(MODS, p) && !MODS[p];
  }
  function mark() {
    document.querySelectorAll('a[href]').forEach(function (a) {
      if (!a.dataset.lhGone && gone(a.getAttribute('href'))) {
        a.dataset.lhGone = '1'; a.style.opacity = '.45'; a.title = 'This page is in another module that is not installed in this build';
      }
    });
  }
  document.addEventListener('click', function (e) {
    var a = e.target.closest ? e.target.closest('a[href]') : null;
    if (a && gone(a.getAttribute('href'))) {
      e.preventDefault(); e.stopPropagation();
      alert('This page is in another module that is not installed in this build yet.');
    }
  }, true);
  document.addEventListener('DOMContentLoaded', function () {
    mark(); new MutationObserver(mark).observe(document.body, {childList: true, subtree: true});
  });
})();
</script>
</body>
</html>
