package com.lms.student.controller;

import com.lms.student.service.CourseNotesStoreService;
import javax.servlet.annotation.WebServlet;

/** Course Notes saved-items store and browser bootstrap. */
@WebServlet({"/js/store.js", "/store"})
public class StoreServlet extends CourseNotesStoreService { }
