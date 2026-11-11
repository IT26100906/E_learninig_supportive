package com.lms.student.controller;

import com.lms.student.service.CourseNotesService;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;

/** Course Notes endpoint only. Core upload/edit/delete/download logic lives in CourseNotesService. */
@WebServlet("/files")
@MultipartConfig(maxFileSize=200L*1024*1024, maxRequestSize=205L*1024*1024)
public class FileServlet extends CourseNotesService { }
