package com.example.demo.payload.response;

import java.time.Instant;

import com.example.demo.models.BookComment;

public class BookCommentResponseDTO {

    private Long id;
    private String content;
    private String commentedByUsername;
    private Long commentedByUserId;
    private Long bookPostId;
    private Instant createdAt;
    private Instant updatedAt;

    public BookCommentResponseDTO(BookComment comment) {
        this.id = comment.getId();
        this.content = comment.getContent();
        this.commentedByUsername = comment.getCommentedBy().getUsername();
        this.commentedByUserId = comment.getCommentedBy().getId();
        this.bookPostId = comment.getBookPost().getId();
        this.createdAt = comment.getCreatedAt();
        this.updatedAt = comment.getUpdatedAt();
    }

    public Long getId() {
        return id;
    }

    public String getContent() {
        return content;
    }

    public String getCommentedByUsername() {
        return commentedByUsername;
    }

    public Long getCommentedByUserId() {
        return commentedByUserId;
    }

    public Long getBookPostId() {
        return bookPostId;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
