package com.lms.student.controller;
import com.lms.student.service.AssignmentsStoreService;
import javax.servlet.annotation.WebServlet;
@WebServlet({"/js/store.js", "/store"})
public class StoreServlet extends AssignmentsStoreService {}
import com.lms.student.service.CourseFeedbackStoreService;
import javax.servlet.annotation.WebServlet;
@WebServlet({"/js/store.js", "/store"})
public class StoreServlet extends CourseFeedbackStoreService {}
import com.lms.student.service.CourseDetailsStoreService;
import javax.servlet.annotation.WebServlet;
@WebServlet({"/js/store.js", "/store"})
public class StoreServlet extends CourseDetailsStoreService {}
