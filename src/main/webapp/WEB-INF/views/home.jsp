<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Welcome | LearnHub</title>
  <link rel="icon" href="${ctx}/images/logo.svg" type="image/svg+xml">
  <script>try{if(localStorage.getItem("lh-theme")==="dark")document.documentElement.classList.add("dark-pre");}catch(e){}</script>
  <link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <style>
    * { box-sizing: border-box; }
    html, body { margin: 0; min-height: 100%; }
    body {
      font-family: 'Inter', system-ui, -apple-system, 'Segoe UI', Roboto, Arial, sans-serif; color: #fff; text-shadow: 0 2px 14px rgba(5,8,20,.55);
      background: #14213d url('${ctx}/images/main-bg.jpg') center / cover fixed no-repeat;
    }
    .overlay { position: fixed; inset: 0; z-index: 0;
      background: linear-gradient(90deg, rgba(8,14,34,.72) 0%, rgba(8,14,34,.45) 50%, rgba(8,14,34,.15) 100%); }
    .page { position: relative; z-index: 1; min-height: 100vh; padding: 28px 8vw 40px; display: flex; flex-direction: column; }

    .topbar { display: flex; justify-content: space-between; align-items: flex-start; }
    .brand { display: flex; align-items: center; gap: 14px; color: #fff; text-decoration: none; }
    .brand img { width: 62px; height: 62px; }
    .brand .name { font-size: 2.3rem; font-weight: 800; line-height: 1; letter-spacing: -.5px; }
    .brand .name b { color: #7cc0ff; }
    .brand .tag { font-size: .95rem; margin-top: 6px; opacity: .92; }
    .top-actions { display: flex; gap: 14px; }

    .btn { display: inline-flex; align-items: center; gap: 10px; padding: 14px 34px; border-radius: 999px; font-weight: 600;
           font-size: 1.05rem; text-decoration: none; transition: .15s; border: 2px solid transparent; color: #fff; }
    .btn-solid { background: #1f7aff; box-shadow: 0 8px 24px rgba(31,122,255,.45); }
    .btn-solid:hover { background: #0b5fe8; }
    .btn-line { border-color: rgba(255,255,255,.9); color: #fff; background: rgba(255,255,255,.12);
                -webkit-backdrop-filter: blur(6px); backdrop-filter: blur(6px); }
    .btn-line:hover { background: rgba(255,255,255,.30); }

    .hero { margin-top: auto; margin-bottom: auto; padding-top: 50px; max-width: 900px; }
    .hero h1 { font-size: clamp(3rem, 8vw, 5.8rem); line-height: 1.02; font-weight: 800; margin: 0 0 22px; letter-spacing: -2px; }
    .hero h1 .blue { color: #7cc0ff; }
    .hero p { font-size: 1.2rem; line-height: 1.6; max-width: 540px; margin: 0 0 34px; opacity: .95; }

    .features { display: flex; flex-wrap: wrap; align-items: center; gap: 0; margin-bottom: 38px; }
    .feat { display: flex; align-items: center; gap: 14px; padding: 4px 28px; border-left: 1px solid rgba(255,255,255,.45); }
    .feat:first-child { padding-left: 0; border-left: 0; }
    .feat i { font-size: 2rem; color: #7cc0ff; }
    .feat span { font-weight: 500; line-height: 1.25; }
    .cta { display: flex; flex-wrap: wrap; gap: 16px; }

    .top-actions { align-items: center; }
    .theme-toggle { width: 46px; height: 46px; border-radius: 50%; cursor: pointer; font-size: 1.15rem; color: #fde68a;
      display: inline-flex; align-items: center; justify-content: center; background: rgba(255,255,255,.35);
      border: 2px solid rgba(255,255,255,.85); -webkit-backdrop-filter: blur(6px); backdrop-filter: blur(6px); transition: .15s; }
    .theme-toggle:hover { background: rgba(255,255,255,.3); }
    /* dark mode: 2nd photo */
    html.dark-pre body { background-image: url('${ctx}/images/dark-bg.jpg'); }
    html.dark-pre body, html.dark-pre .brand { color: #fff; }
    html.dark-pre .btn-line { border-color: rgba(255,255,255,.9); color: #fff; background: rgba(255,255,255,.08); }
    html.dark-pre .btn-line:hover { background: rgba(255,255,255,.25); }
    html.dark-pre .feat { border-left-color: rgba(255,255,255,.4); }
    html.dark-pre .feat i { color: #7cc0ff; }
    html.dark-pre .theme-toggle { color: #fde68a; background: rgba(255,255,255,.12); border-color: rgba(255,255,255,.85); }
    html.dark-pre .theme-toggle:hover { background: rgba(255,255,255,.28); }
    html.dark-pre .overlay { background: linear-gradient(90deg, rgba(5,8,20,.80) 0%, rgba(5,8,20,.45) 45%, rgba(5,8,20,.10) 100%); }

    @media (max-width: 768px) {
      .page { padding: 20px 6vw 30px; }
      .brand img { width: 46px; height: 46px; } .brand .name { font-size: 1.7rem; } .brand .tag { display: none; }
      .btn { padding: 11px 22px; font-size: .95rem; }
      .feat { padding: 8px 16px; } .features { margin-bottom: 26px; }
    }
  </style>
</head>
<body>
  <div class="overlay"></div>
  <div class="page">
    <div class="topbar">
      <a class="brand" href="${ctx}/">
        <img src="${ctx}/images/logo.svg" alt="">
        <div><div class="name">Learn<b>Hub</b></div><div class="tag">E-Learning Supportive System</div></div>
      </a>
      <div class="top-actions">
        <button type="button" class="theme-toggle" id="themeToggle" aria-label="Toggle dark mode" title="Dark / Light mode"><i class="bi bi-moon-stars-fill"></i></button>
        <a class="btn btn-line" href="${ctx}/login">Sign In</a>
        <a class="btn btn-solid" href="${ctx}/register">Sign Up</a>
      </div>
    </div>

    <div class="hero">
      <h1>Learn<br><span style="white-space:nowrap"><span class="blue">Grow</span> Achieve</span></h1>
      <p>Your complete e-learning supportive system. Access courses, manage your learning, and build a better tomorrow with LearnHub.</p>

      <div class="features">
        <div class="feat"><i class="bi bi-book"></i><span>Quality<br>Courses</span></div>
        <div class="feat"><i class="bi bi-people"></i><span>Track<br>Progress</span></div>
        <div class="feat"><i class="bi bi-shield-check"></i><span>Learn<br>Anytime</span></div>
      </div>

      <div class="cta">
        <a class="btn btn-solid" href="${ctx}/register"><i class="bi bi-arrow-right"></i> Get Started</a>
        <a class="btn btn-line" href="${ctx}/login">Sign In</a>
      </div>
    </div>
  </div>
  <script>
  (function () {
    var KEY = 'lh-theme', btn = document.getElementById('themeToggle'), root = document.documentElement;
    function icon() { btn.innerHTML = root.classList.contains('dark-pre') ? '<i class="bi bi-sun-fill"></i>' : '<i class="bi bi-moon-stars-fill"></i>'; }
    icon();
    btn.addEventListener('click', function () {
      var dark = root.classList.toggle('dark-pre');
      try { localStorage.setItem(KEY, dark ? 'dark' : 'light'); } catch (e) {}
      icon();
    });
  })();
  </script>
</body>
</html>
