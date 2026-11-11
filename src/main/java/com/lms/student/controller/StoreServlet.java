package com.lms.student.controller;
import com.lms.student.service.CourseDetailsStoreService;
import javax.servlet.annotation.WebServlet;
@WebServlet({"/js/store.js", "/store"})
public class StoreServlet extends CourseDetailsStoreService {}
