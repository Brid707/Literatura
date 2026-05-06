package com.example.demo.payload.request;

import com.example.demo.models.EReaction;

import jakarta.validation.constraints.NotNull;

public class BookReactionRequest {

    @NotNull(message = "Book post ID cannot be null")
    private Long bookPostId;

    @NotNull(message = "Reaction type cannot be null")
    private EReaction type;

    public Long getBookPostId() {
        return bookPostId;
    }

    public void setBookPostId(Long bookPostId) {
        this.bookPostId = bookPostId;
    }

    public EReaction getType() {
        return type;
    }

    public void setType(EReaction type) {
        this.type = type;
    }
}
