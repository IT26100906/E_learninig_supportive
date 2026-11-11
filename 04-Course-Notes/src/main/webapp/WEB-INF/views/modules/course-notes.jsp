<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"><jsp:param name="title" value="Course Notes / Study Materials"/></jsp:include>

<div class="glass-bar mod-hero">
  <div class="mod-title">
    <div class="mod-ico">&#128221;</div>
    <div><h3>Course Notes / Study Materials</h3><p>Lecture notes, slides, videos and useful links for your courses.</p></div>
  </div>
  <c:if test="${currentUser.canManageUsers()}">
    <button class="btn btn-primary" id="btnUpload"><i class="bi bi-cloud-arrow-up"></i> Upload material</button>
  </c:if>
</div>

<div class="row g-3 mb-3" id="stats"></div>

<div class="card mb-3"><div class="card-body">
  <c:if test="${currentUser.canManageUsers()}">
    <div class="small text-muted mb-2"><i class="bi bi-diagram-3"></i> Study materials are split by learner level. Students only see the materials of their own level.</div>
    <div class="mod-tabs mb-3" id="lvTabs"></div>
  </c:if>
  <div class="mod-filter mb-3">
    <input type="search" id="fSearch" class="form-control grow" placeholder="Search notes by title or topic...">
    <select id="fCourse" class="form-select"></select>
    <select id="fSort" class="form-select">
      <option value="new">Newest first</option><option value="title">Title A - Z</option><option value="down">Most downloaded</option>
    </select>
  </div>
  <div class="mod-tabs" id="tabs"></div>
</div></div>

<div id="grid" class="row g-3"></div>

<c:if test="${currentUser.canManageUsers()}">
<div class="modal fade" id="uploadModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <form class="modal-content" id="uploadForm" novalidate>
      <div class="modal-header"><h5 class="modal-title" id="uHead">Upload study material</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <input type="hidden" id="uEditId">
        <div class="mb-3"><label class="form-label">Title</label><input id="uTitle" class="form-control" maxlength="90" required></div>
        <div class="mb-3"><label class="form-label">Learner level</label><select id="uLevel" class="form-select"></select></div>
        <div class="row g-2 mb-3">
          <div class="col-sm-7"><label class="form-label">Course</label><select id="uCourse" class="form-select"></select></div>
          <div class="col-sm-5"><label class="form-label">Type</label>
            <select id="uType" class="form-select"><option value="pdf">PDF notes</option><option value="slides">Slides</option><option value="video">Video</option><option value="link">Link</option></select></div>
        </div>
        <div class="mb-3"><label class="form-label">Description</label><textarea id="uDesc" class="form-control" rows="2" maxlength="200"></textarea></div>
        <div class="alert alert-info small py-2 d-none" id="uEditNote"></div>
        <div class="mb-3" id="uFileWrap"><label class="form-label">File</label><input type="file" id="uFile" class="form-control" accept=".pdf,.ppt,.pptx,.doc,.docx,.xls,.xlsx,.txt,.mp4,.webm,.zip,.png,.jpg,.jpeg"><div class="form-text">PDF, Word, PowerPoint, Excel, MP4 / WebM video or ZIP. Max 200 MB. Students can open it and download it to their device.</div></div>
        <div class="mb-3 d-none" id="uUrlWrap"><label class="form-label">Link (web address)</label><input type="url" id="uUrl" class="form-control" placeholder="https://..."></div>
        <div class="text-danger small" id="uErr"></div>
      </div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
        <button type="submit" class="btn btn-primary" id="uSubmit"><i class="bi bi-upload"></i> Upload</button></div>
    </form>
  </div>
</div>
</c:if>

<!-- Video player -->
<div class="modal fade" id="videoModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title" id="vTitle">Video</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body p-0 bg-dark"><video id="vPlayer" controls playsinline preload="metadata" style="width:100%;max-height:70vh;display:block"></video></div>
      <div class="modal-footer justify-content-between"><span class="small text-muted" id="vNote"></span><a class="btn btn-outline-primary btn-sm" id="vDownload" href="#" download><i class="bi bi-download"></i> Download video</a></div>
    </div>
  </div>
</div>

<div id="meData" hidden data-id="<c:out value='${currentUser.id}'/>" data-name="<c:out value='${currentUser.name}'/>" data-admin="${currentUser.canManageUsers()}" data-level="${currentUser.level.code}" data-detail="<c:out value='${currentUser.levelDetail}'/>" data-ctx="${ctx}"></div>
<script>
document.addEventListener('DOMContentLoaded', function () {
  var ADMIN = document.getElementById('meData').dataset.admin === 'true';
  var $ = function (id) { return document.getElementById(id); };
  var TYPES = {pdf: ['PDF notes', 'bi-file-earmark-pdf', 'ft-pdf'], slides: ['Slides', 'bi-easel', 'ft-slides'],
               video: ['Video', 'bi-play-circle', 'ft-video'], link: ['Link', 'bi-link-45deg', 'ft-link']};
  var COURSES = LH.names();
  var SEED = LH.seedNotes(LH.courses());
  var MYLV = $('meData').dataset.level, curLv = 'ALL';
  var items = LH.keep(LH.load('notes', SEED), 'course'), saved = LH.load('notes-saved', []), tab = 'all', remote = [];
  /* learner level of a material: the one the admin chose, or (older materials) the level of its course */
  function lvOf(i) { return i.lv || LH.courseLevel(i.course); }
  /* materials uploaded by the admin are kept on the server, so every student sees them */
  function all() {
    return items.concat(remote.filter(function (r) { return ADMIN || (COURSES.indexOf(r.course) >= 0 && (!r.lv || r.lv === MYLV)); }))
                .filter(function (i) { return !ADMIN || curLv === 'ALL' || lvOf(i) === curLv; });
  }
  function everything() { return items.concat(remote); }
  function loadRemote() {
    return fetch(LH.ctx() + '/files?kind=material&list=1', {credentials: 'same-origin'}).then(function (r) { return r.json(); }).then(function (list) {
      remote = list.map(function (m) {
        return {id: m.id, title: m.title, course: m.course, type: m.type, size: m.size, date: m.date, down: 0, desc: m.desc, remote: true, lv: m.lv || LH.courseLevel(m.course),
                file: m.fileId ? {id: m.fileId, name: m.fileName} : undefined, url: m.url || undefined};
      });
    }).catch(function () { remote = []; }).then(function () { render(); });
  }

  function fillFilter() {
    var list = ADMIN && curLv !== 'ALL' ? LH.levelCourses(curLv).map(function (c) { return c.name; }) : COURSES;
    $('fCourse').innerHTML = '<option value="">All courses</option>' + list.map(function (c) { return '<option>' + LH.esc(c) + '</option>'; }).join('');
  }
  fillFilter();
  /* admin upload form: choose the learner level first, then one of ITS courses */
  function fillUCourses(lv, keep) {
    var list = LH.levelCourses(lv).map(function (c) { return c.name; });
    if (keep && list.indexOf(keep) < 0) list.push(keep);
    $('uCourse').innerHTML = list.map(function (c) { return '<option>' + LH.esc(c) + '</option>'; }).join('');
    if (keep) $('uCourse').value = keep;
  }
  if ($('uLevel')) {
    $('uLevel').innerHTML = LH.LEVELS.map(function (l) { return '<option value="' + l.code + '">' + l.icon + ' ' + l.name + '</option>'; }).join('');
    $('uLevel').addEventListener('change', function () { fillUCourses($('uLevel').value); });
  }

  function lvTabs() {
    if (!ADMIN) return;
    var defs = [{code: 'ALL', tab: 'All', icon: '&#128450;'}].concat(LH.LEVELS);
    $('lvTabs').innerHTML = defs.map(function (l) {
      var n = l.code === 'ALL' ? everything().length : everything().filter(function (i) { return lvOf(i) === l.code; }).length;
      return '<button type="button" class="mod-tab ' + (curLv === l.code ? 'active' : '') + '" data-lv="' + l.code + '">' + l.icon + ' ' + l.tab + '<span class="cnt">' + n + '</span></button>';
    }).join('');
  }
  function stats() {
    var down = all().reduce(function (a, i) { return a + i.down; }, 0);
    var cards = [['Materials', all().length, 'bi-folder2-open', ''], ['Courses covered', new Set(all().map(function (i) { return i.course; })).size, 'bi-journal-bookmark-fill', 'cyan'],
                 ['Downloads', down.toLocaleString(), 'bi-download', 'green'], ['Saved by me', saved.length, 'bi-bookmark-star-fill', 'amber']];
    $('stats').innerHTML = cards.map(function (c) {
      return '<div class="col-md-3 col-6"><div class="card stat-card ' + c[3] + ' p-3"><span class="gicon"><i class="bi ' + c[2] + '"></i></span><div><div class="text-muted small">' + c[0] + '</div><div class="stat-number">' + c[1] + '</div></div></div></div>';
    }).join('');
  }
  function tabs() {
    var defs = [['all', 'All'], ['pdf', 'PDF notes'], ['slides', 'Slides'], ['video', 'Videos'], ['link', 'Links'], ['saved', 'Saved']];
    $('tabs').innerHTML = defs.map(function (d) {
      var n = d[0] === 'all' ? all().length : d[0] === 'saved' ? saved.length : all().filter(function (i) { return i.type === d[0]; }).length;
      return '<button type="button" class="mod-tab ' + (tab === d[0] ? 'active' : '') + '" data-tab="' + d[0] + '">' + d[1] + '<span class="cnt">' + n + '</span></button>';
    }).join('');
  }
  var VIEWABLE = ['pdf', 'txt', 'png', 'jpg', 'jpeg', 'gif'];
  function extOf(n) { var m = /\.([A-Za-z0-9]+)$/.exec(n || ''); return m ? m[1].toLowerCase() : ''; }
  /* Open + Download buttons that fit the kind of material */
  function actionBtns(i) {
    var b = function (cls, act, ico, txt) { return '<button class="btn ' + cls + '" data-' + act + '="' + i.id + '"><i class="bi ' + ico + '"></i> ' + txt + '</button>'; };
    if (i.type === 'link') return b('btn-primary flex-fill', 'open', 'bi-box-arrow-up-right', 'Open link');
    if (i.type === 'video') return b('btn-primary flex-fill', 'open', 'bi-play-fill', 'Watch') + b('btn-outline-primary', 'dl', 'bi-download', '');
    var canView = !i.file || VIEWABLE.indexOf(extOf(i.file.name)) >= 0;
    return (canView ? b('btn-primary flex-fill', 'open', 'bi-eye', 'Open') + b('btn-outline-primary', 'dl', 'bi-download', 'Download')
                    : b('btn-primary flex-fill', 'dl', 'bi-download', 'Download'));
  }
  /* sample files for the demo materials (real PDF made in the browser) */
  function sampleBlob(it) {
    var slides = it.type === 'slides', head = [{t: it.title, s: slides ? 30 : 22, b: true}, {t: it.course, s: 14}, {t: ' ', s: 8}];
    var body = LH.wrap(it.desc, slides ? 60 : 80).map(function (t) { return {t: t, s: slides ? 16 : 12}; });
    var course = (LH.allCourses().filter(function (c) { return c.name === it.course; })[0]) || {topics: []};
    var pages = [head.concat(body, [{t: ' ', s: 8}, {t: 'Topics in this course', s: 14, b: true}], course.topics.map(function (t, k) { return {t: (k + 1) + '. ' + t, s: slides ? 16 : 12}; }),
                  [{t: ' ', s: 8}, {t: 'Sample study material generated by LearnHub.', s: 10}])];
    if (slides) {
      course.topics.forEach(function (t, k) {
        pages.push([{t: 'Slide ' + (k + 2) + ': ' + t, s: 28, b: true}, {t: ' ', s: 10}, {t: 'Key ideas, worked examples and practice questions.', s: 16}, {t: 'Ask your teacher if anything is unclear.', s: 16}]);
      });
    } else {
      course.topics.forEach(function (t, k) {
        pages.push([{t: 'Part ' + (k + 1) + ': ' + t, s: 18, b: true}, {t: ' ', s: 8}].concat(LH.wrap('Summary notes for ' + t + '. Read these notes, then try the practice questions in the course page and the assignments.', 80).map(function (x) { return {t: x, s: 12}; })));
      });
    }
    return LH.makePdf(pages, slides);
  }
  function fileName(it) { return (it.file ? it.file.name : it.title.replace(/[^A-Za-z0-9 _-]/g, '').trim().replace(/\s+/g, '-') + '.pdf'); }
  function countOpen(it) { it.down++; if (!it.remote) LH.save('notes', items); render(); }
  function playVideo(it) {
    var url = it.file ? LH.fileUrl('material', it.file.id, it.file.name) : LH.ctx() + '/media/sample-lesson.mp4';
    $('vTitle').textContent = it.title;
    $('vNote').textContent = it.file ? it.course : 'Demo video - the teacher\'s own video appears here once uploaded.';
    $('vDownload').href = it.file ? LH.fileUrl('material', it.file.id, it.file.name, true) : url;
    $('vDownload').setAttribute('download', it.file ? it.file.name : 'sample-lesson.mp4');
    var v = $('vPlayer'); v.src = url; v.load(); LH.modal('videoModal').show();
    var p = v.play(); if (p && p.catch) p.catch(function () { /* autoplay blocked: the user presses play */ });
  }
  $('videoModal').addEventListener('hidden.bs.modal', function () { var v = $('vPlayer'); v.pause(); v.removeAttribute('src'); v.load(); });

  function render() {
    var q = $('fSearch').value.toLowerCase(), co = $('fCourse').value, so = $('fSort').value;
    var rows = all().filter(function (i) {
      return (tab === 'all' || (tab === 'saved' ? saved.indexOf(i.id) >= 0 : i.type === tab)) && (!co || i.course === co) &&
             (!q || (i.title + ' ' + i.desc + ' ' + i.course).toLowerCase().indexOf(q) >= 0);
    });
    rows.sort(function (a, b) {
      if (so === 'title') return a.title.localeCompare(b.title);
      if (so === 'down') return b.down - a.down;
      return b.date < a.date ? -1 : b.date > a.date ? 1 : b.id - a.id;
    });
    tabs(); stats(); lvTabs();
    if (!rows.length) { $('grid').innerHTML = '<div class="col-12"><div class="card"><div class="empty-state"><i class="bi bi-folder-x"></i>No study materials found.</div></div></div>'; return; }
    $('grid').innerHTML = rows.map(function (i) {
      var t = TYPES[i.type], isSaved = saved.indexOf(i.id) >= 0;
      return '<div class="col-md-6 col-xl-4"><div class="card h-100"><div class="card-body d-flex flex-column">' +
        '<div class="d-flex gap-3 mb-2"><div class="ftype ' + t[2] + '"><i class="bi ' + t[1] + '"></i></div>' +
        '<div class="flex-fill"><div class="fw-bold">' + LH.esc(i.title) + '</div><div class="small text-muted">' + LH.esc(i.course) + '</div></div>' +
        '<button class="btn btn-sm ' + (isSaved ? 'btn-warning' : 'btn-outline-warning') + ' align-self-start" data-save="' + i.id + '" title="Save"><i class="bi ' + (isSaved ? 'bi-bookmark-fill' : 'bi-bookmark') + '"></i></button></div>' +
        '<p class="small mb-3 flex-fill">' + LH.esc(i.desc) + '</p>' +
        '<div class="d-flex justify-content-between align-items-center small text-muted mb-2"><span class="chip">' + t[0] + '</span>' + (ADMIN && lvOf(i) ? '<span class="chip blue">' + LH.levelIcon(lvOf(i)) + ' ' + LH.esc((LH.LEVELS.filter(function (l) { return l.code === lvOf(i); })[0] || {tab: ''}).tab) + '</span>' : '') + '<span>' + LH.esc(i.size) + '</span><span><i class="bi bi-download"></i> ' + i.down + '</span><span>' + LH.fmtDate(i.date) + '</span></div>' +
        '<div class="d-flex gap-2 flex-wrap">' + actionBtns(i) +
        (ADMIN ? '<button class="btn btn-outline-secondary" data-edit="' + i.id + '" title="Edit"><i class="bi bi-pencil-square"></i></button><button class="btn btn-outline-danger" data-del="' + i.id + '" title="Remove"><i class="bi bi-trash"></i></button>' : '') + '</div>' +
        '</div></div></div>';
    }).join('');
  }

  ['fSearch', 'fCourse', 'fSort'].forEach(function (id) { $(id).addEventListener('input', render); });
  $('tabs').addEventListener('click', function (e) { var b = e.target.closest('[data-tab]'); if (b) { tab = b.getAttribute('data-tab'); render(); } });
  if (ADMIN) $('lvTabs').addEventListener('click', function (e) { var b = e.target.closest('[data-lv]'); if (b) { curLv = b.getAttribute('data-lv'); fillFilter(); $('fCourse').value = ''; render(); } });
  $('grid').addEventListener('click', function (e) {
    var ed = e.target.closest('[data-edit]'), s = e.target.closest('[data-save]'), o = e.target.closest('[data-open]'), dl = e.target.closest('[data-dl]'), d = e.target.closest('[data-del]');
    if (ed) openEdit(+ed.getAttribute('data-edit'));
    if (s) {
      var id = +s.getAttribute('data-save'), k = saved.indexOf(id);
      if (k >= 0) saved.splice(k, 1); else saved.push(id);
      LH.save('notes-saved', saved); render(); LH.toast(k >= 0 ? 'Removed from saved' : 'Saved for later', 'info');
    }
    function find(a) { var n = +a.getAttribute(a.hasAttribute('data-open') ? 'data-open' : 'data-dl'); return all().filter(function (x) { return x.id === n; })[0]; }
    if (o) {
      var it = find(o);
      if (it.type === 'video') { playVideo(it); countOpen(it); }
      else if (it.type === 'link') {
        window.open(it.url || 'https://en.wikipedia.org/w/index.php?search=' + encodeURIComponent(it.title.replace(/ - Useful link$/, '')), '_blank', 'noopener');
        countOpen(it);
      } else {
        // open the file in a new tab (PDF viewer of the browser)
        window.open(it.file ? LH.fileUrl('material', it.file.id, it.file.name) : URL.createObjectURL(sampleBlob(it)), '_blank');
        countOpen(it);
      }
    }
    if (dl) {
      var it2 = find(dl);
      if (it2.file) { var a = document.createElement('a'); a.href = LH.fileUrl('material', it2.file.id, it2.file.name, true); a.download = it2.file.name; document.body.appendChild(a); a.click(); a.remove(); }
      else if (it2.type === 'video') { var a2 = document.createElement('a'); a2.href = LH.ctx() + '/media/sample-lesson.mp4'; a2.download = 'sample-lesson.mp4'; document.body.appendChild(a2); a2.click(); a2.remove(); }
      else LH.saveBlob(sampleBlob(it2), fileName(it2));
      LH.toast('Downloading: ' + (it2.type === 'video' && !it2.file ? 'sample-lesson.mp4' : fileName(it2)), 'info'); countOpen(it2);
    }
    if (d && confirm('Remove this material?')) {
      var did = +d.getAttribute('data-del');
      var gone = all().filter(function (x) { return x.id === did; })[0];
      if (gone && gone.remote) { LH.removeFile('material', '', gone.id).then(loadRemote); LH.toast('Material removed', 'info'); return; }
      items = items.filter(function (x) { return x.id !== did; }); LH.save('notes', items); render(); LH.toast('Material removed', 'info');
    }
  });

  if (ADMIN) {
    function setMode(edit) {
      $('uHead').textContent = edit ? 'Edit study material' : 'Upload study material';
      $('uSubmit').innerHTML = edit ? '<i class="bi bi-check2-circle"></i> Save changes' : '<i class="bi bi-upload"></i> Upload';
      $('uEditNote').classList.toggle('d-none', !edit);
      if (edit) { $('uFileWrap').classList.add('d-none'); }
    }
    $('btnUpload').addEventListener('click', function () { $('uploadForm').reset(); $('uEditId').value = ''; $('uLevel').value = curLv === 'ALL' ? 'SCHOOL' : curLv; fillUCourses($('uLevel').value); setMode(false); $('uErr').textContent = ''; $('uType').disabled = false; Array.prototype.forEach.call($('uType').options, function (o) { o.disabled = false; }); syncUpload(); LH.modal('uploadModal').show(); });
    /* edit the details of a material (title, course, type, description, web address) */
    window.openEdit = function (id) {
      var it = all().filter(function (x) { return x.id === id; })[0]; if (!it) return;
      $('uploadForm').reset(); $('uErr').textContent = ''; $('uEditId').value = id; setMode(true);
      $('uLevel').value = lvOf(it) || 'SCHOOL'; fillUCourses($('uLevel').value, it.course);
      $('uTitle').value = it.title; $('uCourse').value = it.course; $('uDesc').value = it.desc;
      var isLink = it.type === 'link', isFile = !!it.file;
      $('uType').value = it.type; $('uType').disabled = isLink;                                    // a link stays a link
      Array.prototype.forEach.call($('uType').options, function (o) { o.disabled = isFile && o.value === 'link'; });   // a file cannot become a link
      $('uUrl').value = it.url || '';
      $('uUrlWrap').classList.toggle('d-none', !isLink);
      $('uEditNote').textContent = isLink ? 'Change the title, course, description or web address of this link.' : isFile ? 'Change the details. The uploaded file stays as it is (' + it.file.name + '). To replace the file, remove this material and upload a new one.' : 'Change the details of this material.';
      LH.modal('uploadModal').show();
    };
    var EXT_TYPE = {pdf: 'pdf', doc: 'pdf', docx: 'pdf', txt: 'pdf', xls: 'pdf', xlsx: 'pdf', zip: 'pdf', png: 'pdf', jpg: 'pdf', jpeg: 'pdf', ppt: 'slides', pptx: 'slides', mp4: 'video', webm: 'video'};
    function syncUpload() { if ($('uEditId').value) return; var link = $('uType').value === 'link'; $('uFileWrap').classList.toggle('d-none', link); $('uUrlWrap').classList.toggle('d-none', !link); }
    $('uType').addEventListener('change', syncUpload);
    $('uFile').addEventListener('change', function () {
      var f = this.files[0]; if (!f) return;
      if (EXT_TYPE[extOf(f.name)]) $('uType').value = EXT_TYPE[extOf(f.name)];
      if (!$('uTitle').value.trim()) $('uTitle').value = f.name.replace(/\.[^.]+$/, '').replace(/[_-]+/g, ' ');
    });
    $('uploadForm').addEventListener('submit', function (e) {
      e.preventDefault();
      var title = $('uTitle').value.trim(), f = $('uFile').files[0], type = $('uType').value, url = $('uUrl').value.trim(), btn = e.submitter || $('uploadForm').querySelector('[type=submit]');
      if (title.length < 3) return $('uErr').textContent = 'Please enter a title.';
      var editId = +$('uEditId').value;
      if (editId) {                                                              // ---- save changes to an existing material ----
        var it = all().filter(function (x) { return x.id === editId; })[0]; if (!it) return;
        if (it.type === 'link' && !/^https?:\/\/\S+$/i.test(url)) return $('uErr').textContent = 'Please enter a web address starting with http:// or https://';
        if (it.remote) {
          var fd = new FormData(); fd.append('action', 'update'); fd.append('kind', 'material'); fd.append('entry', it.id); fd.append('title', title); fd.append('course', $('uCourse').value); fd.append('lv', $('uLevel').value);
          fd.append('type', it.type === 'link' ? 'link' : type); fd.append('desc', $('uDesc').value.trim()); fd.append('url', url);
          btn.disabled = true;
          fetch(LH.ctx() + '/files', {method: 'POST', body: fd, credentials: 'same-origin'}).then(function (r) { return r.json().catch(function () { return {ok: false}; }); })
            .then(function (j) { if (!j.ok) throw new Error(j.error || 'Could not save the changes.'); $('uErr').textContent = ''; LH.modal('uploadModal').hide(); LH.toast('Material updated'); return loadRemote(); })
            .catch(function (err) { $('uErr').textContent = err.message; }).then(function () { btn.disabled = false; });
        } else {
          it.title = title; it.course = $('uCourse').value; it.lv = $('uLevel').value; it.type = it.type === 'link' ? 'link' : type; it.desc = $('uDesc').value.trim() || 'No description.'; if (it.type === 'link') it.url = url;
          LH.save('notes', items); LH.modal('uploadModal').hide(); render(); LH.toast('Material updated');
        }
        return;
      }
      if (type === 'link') {
        if (!/^https?:\/\/\S+$/i.test(url)) return $('uErr').textContent = 'Please enter a web address starting with http:// or https://';
      } else {
        if (!f) return $('uErr').textContent = 'Please choose the file to upload.';
        if (f.size > 200 * 1024 * 1024) return $('uErr').textContent = 'File is larger than 200 MB.';
      }
      btn.disabled = true; $('uErr').textContent = 'Uploading...';
      Promise.resolve().then(function () { return LH.upload('material', type === 'link' ? null : f, {title: title, course: $('uCourse').value, lv: $('uLevel').value, type: type, desc: $('uDesc').value.trim(), url: type === 'link' ? url : ''}); })
        .then(function () { $('uErr').textContent = ''; LH.modal('uploadModal').hide(); LH.toast('Material uploaded'); return loadRemote(); })
        .catch(function (err) { $('uErr').textContent = err.message; })
        .then(function () { btn.disabled = false; });
    });
  }
  render();
  loadRemote();
});
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
