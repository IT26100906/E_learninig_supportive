package com.lms.student.model;

import java.util.List;

/** One page of search results (used for pagination). Generic class. */
public class Page<T> {
    private final List<T> items;
    private final int page;
    private final int pageSize;
    private final int totalItems;

    public Page(List<T> items, int page, int pageSize, int totalItems) {
        this.items = items;
        this.page = page;
        this.pageSize = pageSize;
        this.totalItems = totalItems;
    }

    public List<T> getItems() { return items; }
    public int getPage() { return page; }
    public int getPageSize() { return pageSize; }
    public int getTotalItems() { return totalItems; }
    public int getTotalPages() { return Math.max(1, (int) Math.ceil(totalItems / (double) pageSize)); }
    public boolean isHasPrevious() { return page > 1; }
    public boolean isHasNext() { return page < getTotalPages(); }
}
