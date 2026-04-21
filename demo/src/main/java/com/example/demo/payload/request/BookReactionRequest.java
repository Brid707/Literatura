package com.example.demo.payload.request;

public class BookReactionRequest {

    private Long bookPostId;
    private Long reactionId;

    public Long getBookPostId() {
        return bookPostId;
    }

    public void setBookPostId(Long bookPostId) {
        this.bookPostId = bookPostId;
    }

    public Long getReactionId() {
        return reactionId;
    }

    public void setReactionId(Long reactionId) {
        this.reactionId = reactionId;
    }
}
