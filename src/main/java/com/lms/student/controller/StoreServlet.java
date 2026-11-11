package com.lms.student.controller;
import com.lms.student.service.PaymentStoreService;
import javax.servlet.annotation.WebServlet;
@WebServlet({"/js/store.js", "/store"})
public class StoreServlet extends PaymentStoreService {}
