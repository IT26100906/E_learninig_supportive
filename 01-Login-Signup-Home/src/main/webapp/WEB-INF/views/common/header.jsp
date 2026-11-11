<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request"/>
<c:set var="isFrosted" value="true"/>
<%-- Liquid glass is now ON for every page (it used to be login-only via param.liquid) --%>
<c:set var="isLiquid" value="true"/>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><c:out value="${param.title}"/> | LearnHub</title>
  <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E%F0%9F%8E%93%3C/text%3E%3C/svg%3E">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
  <link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Fredoka:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link href="${ctx}/css/style.css" rel="stylesheet">
  <link href="${ctx}/css/themes.css" rel="stylesheet">
  <link href="${ctx}/css/frosted.css" rel="stylesheet">
  <link href="${ctx}/css/dark.css" rel="stylesheet">
  <link href="${ctx}/css/modules.css" rel="stylesheet">
  <script>try{if(localStorage.getItem("lh-theme")==="dark")document.documentElement.classList.add("dark-pre");}catch(e){}</script>
  <c:if test="${isLiquid}"><link href="${ctx}/css/liquid.css" rel="stylesheet"></c:if>
  <link href="${ctx}/css/readable.css" rel="stylesheet">
</head>
<c:set var="themeName" value="${not empty currentUser and not currentUser.canManageUsers() ? currentUser.level.theme : 'undergrad'}"/>
<body data-ctx="${ctx}" class="theme-${themeName}${isFrosted ? ' frosted' : ''}${isLiquid ? ' liquid' : ''}">


<c:if test="${isLiquid}">
<%-- Liquid glass: SVG lens-refraction filters used by css/liquid.css (Chromium browsers) --%>
<svg width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false">
  <filter id="lg-refract" x="0" y="0" width="100%" height="100%" color-interpolation-filters="sRGB">
    <feImage href="data:image/svg+xml;charset=utf-8,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%22540%22%20height=%22540%22%20viewBox=%220%200%20540%20540%22%20preserveAspectRatio=%22none%22%3E%3Cdefs%3E%3ClinearGradient%20id=%22x%22%20x1=%220%22%20x2=%221%22%20y1=%220%22%20y2=%220%22%3E%3Cstop%20offset=%220%22%20stop-color=%22%23ff0000%22/%3E%3Cstop%20offset=%22.12%22%20stop-color=%22%23800000%22/%3E%3Cstop%20offset=%22.88%22%20stop-color=%22%23800000%22/%3E%3Cstop%20offset=%221%22%20stop-color=%22%23000000%22/%3E%3C/linearGradient%3E%3ClinearGradient%20id=%22y%22%20x1=%220%22%20x2=%220%22%20y1=%220%22%20y2=%221%22%3E%3Cstop%20offset=%220%22%20stop-color=%22%2300ff00%22/%3E%3Cstop%20offset=%22.12%22%20stop-color=%22%23008000%22/%3E%3Cstop%20offset=%22.88%22%20stop-color=%22%23008000%22/%3E%3Cstop%20offset=%221%22%20stop-color=%22%23000000%22/%3E%3C/linearGradient%3E%3C/defs%3E%3Crect%20width=%22540%22%20height=%22540%22%20fill=%22%23000080%22/%3E%3Crect%20width=%22540%22%20height=%22540%22%20fill=%22url(#x)%22%20style=%22mix-blend-mode:screen%22/%3E%3Crect%20width=%22540%22%20height=%22540%22%20fill=%22url(#y)%22%20style=%22mix-blend-mode:screen%22/%3E%3C/svg%3E" x="0" y="0" width="100%" height="100%" preserveAspectRatio="none" result="map"/>
    <feDisplacementMap in="SourceGraphic" in2="map" scale="46" xChannelSelector="R" yChannelSelector="G"/>
  </filter>
</svg>
<svg width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false">
  <filter id="lg-refract-soft" x="0" y="0" width="100%" height="100%" color-interpolation-filters="sRGB">
    <feImage href="data:image/svg+xml;charset=utf-8,%3Csvg%20xmlns=%22http://www.w3.org/2000/svg%22%20width=%22540%22%20height=%22540%22%20viewBox=%220%200%20540%20540%22%20preserveAspectRatio=%22none%22%3E%3Cdefs%3E%3ClinearGradient%20id=%22x%22%20x1=%220%22%20x2=%221%22%20y1=%220%22%20y2=%220%22%3E%3Cstop%20offset=%220%22%20stop-color=%22%23ff0000%22/%3E%3Cstop%20offset=%22.12%22%20stop-color=%22%23800000%22/%3E%3Cstop%20offset=%22.88%22%20stop-color=%22%23800000%22/%3E%3Cstop%20offset=%221%22%20stop-color=%22%23000000%22/%3E%3C/linearGradient%3E%3ClinearGradient%20id=%22y%22%20x1=%220%22%20x2=%220%22%20y1=%220%22%20y2=%221%22%3E%3Cstop%20offset=%220%22%20stop-color=%22%2300ff00%22/%3E%3Cstop%20offset=%22.12%22%20stop-color=%22%23008000%22/%3E%3Cstop%20offset=%22.88%22%20stop-color=%22%23008000%22/%3E%3Cstop%20offset=%221%22%20stop-color=%22%23000000%22/%3E%3C/linearGradient%3E%3C/defs%3E%3Crect%20width=%22540%22%20height=%22540%22%20fill=%22%23000080%22/%3E%3Crect%20width=%22540%22%20height=%22540%22%20fill=%22url(#x)%22%20style=%22mix-blend-mode:screen%22/%3E%3Crect%20width=%22540%22%20height=%22540%22%20fill=%22url(#y)%22%20style=%22mix-blend-mode:screen%22/%3E%3C/svg%3E" x="0" y="0" width="100%" height="100%" preserveAspectRatio="none" result="map"/>
    <feDisplacementMap in="SourceGraphic" in2="map" scale="22" xChannelSelector="R" yChannelSelector="G"/>
  </filter>
</svg>
</c:if>
<c:set var="navPath" value="${requestScope['javax.servlet.forward.servlet_path']}"/>

<nav class="navbar app-navbar fixed-top">
  <div class="container d-flex align-items-center justify-content-between">
    <div class="d-flex align-items-center">
      <c:if test="${not empty currentUser}">
        <button class="menu-btn me-3" type="button" data-bs-toggle="offcanvas" data-bs-target="#sideMenu" aria-label="Open menu">
          <span></span><span></span><span></span><span></span>
        </button>
      </c:if>
      <a class="brand-link" href="${ctx}/"><img src="${ctx}/images/logo.svg" alt=""><span>Learn<span class="hub">Hub</span></span></a>
      <%-- Premium students: a gold "Premium" tag right after the LearnHub name (regular students see nothing extra) --%>
      <c:if test="${not empty currentUser and not currentUser.canManageUsers() and currentUser.type == 'PREMIUM'}">
        <span class="premium-tag" id="premiumTag"><i class="bi bi-star-fill"></i> Premium</span>
      </c:if>
    </div>

    <div class="d-flex align-items-center gap-2">
    <button type="button" class="theme-toggle" id="themeToggle" aria-label="Toggle dark mode" title="Dark / Light mode"><i class="bi bi-moon-stars-fill"></i></button>
    <c:choose>
      <c:when test="${not empty currentUser}">
        <div class="dropdown">
          <a class="nav-link dropdown-toggle d-flex align-items-center gap-2" href="#" data-bs-toggle="dropdown">
            <c:choose>
              <c:when test="${not empty currentUser.profilePicture}">
                <img class="avatar avatar-sm" src="${ctx}/photo?id=<c:out value='${currentUser.id}'/>" alt="">
              </c:when>
              <c:otherwise><span class="avatar avatar-sm avatar-initials"><c:out value="${currentUser.initials}"/></span></c:otherwise>
            </c:choose>
            <span class="d-none d-sm-inline"><c:out value="${currentUser.name}"/></span>
            <span class="badge text-bg-primary"><c:out value="${currentUser.role}"/></span>
          </a>
          <ul class="dropdown-menu dropdown-menu-end">
            <c:if test="${not currentUser.canManageUsers()}">
              <li><a class="dropdown-item" href="${ctx}/profile"><i class="bi bi-person"></i> My Profile</a></li>
              <li><a class="dropdown-item" href="${ctx}/profile/edit"><i class="bi bi-pencil-square"></i> Edit Profile</a></li>
            </c:if>
            <li><a class="dropdown-item" href="${ctx}/change-password"><i class="bi bi-key"></i> Change Password</a></li>
            <li><hr class="dropdown-divider"></li>
            <li>
              <form action="${ctx}/logout" method="post" class="m-0">
                <button class="dropdown-item text-danger" type="submit"><i class="bi bi-box-arrow-right"></i> Logout</button>
              </form>
            </li>
          </ul>
        </div>
      </c:when>
      <c:otherwise>
        <div class="d-flex align-items-center gap-2">
          <a class="nav-link" href="${ctx}/login">Sign in</a>
          <a class="btn btn-primary btn-sm" href="${ctx}/register">Sign up</a>
        </div>
      </c:otherwise>
    </c:choose>
    </div>
  </div>
</nav>

<c:if test="${not empty currentUser}">
<%-- Sidebar: opens when the 4-line button is clicked, items are listed one under the other --%>
<div class="offcanvas offcanvas-start side-menu" tabindex="-1" id="sideMenu">
  <div class="offcanvas-header">
    <a class="brand-link" href="${ctx}/"><img src="${ctx}/images/logo.svg" alt=""><span>Learn<span class="hub">Hub</span></span></a>
    <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
  </div>
  <div class="offcanvas-body pt-0">
    <nav class="d-flex flex-column">
      <a class="side-link ${navPath == '/dashboard' || navPath == '/admin/dashboard' ? 'active' : ''}" href="${ctx}${currentUser.homePath}">
        <span class="side-icon">&#127968;</span><span>Home</span></a>
      <c:if test="${currentUser.canManageUsers()}">
        <a class="side-link ${navPath == '/admin/students' ? 'active' : ''}" href="${ctx}/admin/students">
          <span class="side-icon">&#128101;</span><span>Students</span></a>
        <a class="side-link ${navPath == '/admin/students/form' ? 'active' : ''}" href="${ctx}/admin/students/form">
          <span class="side-icon">&#10133;</span><span>Add Student</span></a>
        <a class="side-link ${navPath == '/admin/database' ? 'active' : ''}" href="${ctx}/admin/database">
          <span class="side-icon">&#128202;</span><span>Database</span></a>
        <a class="side-link" href="${ctx}/admin/phpmyadmin" target="_blank" rel="noopener">
          <span class="side-icon">&#128451;</span><span>phpMyAdmin</span></a>
      </c:if>
    </nav>
  </div>
</div>
</c:if>

<main class="container page-content py-4">

<c:if test="${not empty flashMessage}">
  <div class="alert alert-${flashType} alert-dismissible fade show alert-auto" role="alert">
    <c:out value="${flashMessage}"/>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
</c:if>
<c:if test="${not empty errors}">
  <div class="alert alert-danger" role="alert">
    <strong><i class="bi bi-exclamation-triangle"></i> Please fix the following:</strong>
    <ul class="mb-0 mt-1">
      <c:forEach var="e" items="${errors}"><li><c:out value="${e}"/></li></c:forEach>
    </ul>
  </div>
</c:if>
