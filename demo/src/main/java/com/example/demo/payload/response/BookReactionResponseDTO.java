package com.example.demo.payload.response;

import java.time.Instant;

import com.example.demo.models.BookReaction;
import com.example.demo.models.EReaction;

public class BookReactionResponseDTO {

    private Long id;
    private EReaction type;
    private String reactedByUsername;
    private Long reactedByUserId;
    private Long bookPostId;
    private Instant createdAt;

    public BookReactionResponseDTO(BookReaction reaction) {
        this.id = reaction.getId();
        this.type = reaction.getType();
        this.reactedByUsername = reaction.getReactedBy().getUsername();
        this.reactedByUserId = reaction.getReactedBy().getId();
        this.bookPostId = reaction.getBookPost().getId();
        this.createdAt = reaction.getCreatedAt();
    }

    public Long getId() {
        return id;
    }

    public EReaction getType() {
        return type;
    }

    public String getReactedByUsername() {
        return reactedByUsername;
    }

    public Long getReactedByUserId() {
        return reactedByUserId;
    }

    public Long getBookPostId() {
        return bookPostId;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}