package com.example.demo.models;

import java.time.Instant;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;

@Entity
@Table(
        name = "book_reactions",
        uniqueConstraints = {
                @UniqueConstraint(columnNames = {"user_id", "book_post_id"})
        }
)
public class BookReaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    private EReaction type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User reactedBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_post_id", nullable = false)
    private BookPost bookPost;

    @Temporal(TemporalType.TIMESTAMP)
    private Instant createdAt;

    public BookReaction() {
        this.createdAt = Instant.now();
    }

    public BookReaction(EReaction type, User reactedBy, BookPost bookPost) {
        this();
        this.type = type;
        this.reactedBy = reactedBy;
        this.bookPost = bookPost;
    }

    public Long getId() {
        return id;
    }

    public EReaction getType() {
        return type;
    }

    public void setType(EReaction type) {
        this.type = type;
    }

    public User getReactedBy() {
        return reactedBy;
    }

    public void setReactedBy(User reactedBy) {
        this.reactedBy = reactedBy;
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
}