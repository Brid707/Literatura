package com.example.demo.models;

import java.time.Instant;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Entity
@Table(name = "book_comments")
public class BookComment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 500)
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "commented_by", nullable = false)
    private User commentedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_post_id", nullable = false)
    private BookPost bookPost;

    @Temporal(TemporalType.TIMESTAMP)
    private Instant createdAt;

    @Temporal(TemporalType.TIMESTAMP)
    private Instant updatedAt;

    public BookComment() {
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public BookComment(String content, User commentedBy, BookPost bookPost) {
        this();
        this.content = content;
        this.commentedBy = commentedBy;
        this.bookPost = bookPost;
    }

    public Long getId() {
        return id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
        this.updatedAt = Instant.now();
    }

    public User getCommentedBy() {
        return commentedBy;
    }

    public void setCommentedBy(User commentedBy) {
        this.commentedBy = commentedBy;
    }

    public BookPost getBookPost() {
        return bookPost;
    }

    public void setBookPost(BookPost bookPost) {
        this.bookPost = bookPost;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
