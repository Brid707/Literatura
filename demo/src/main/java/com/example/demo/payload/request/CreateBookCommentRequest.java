package com.example.demo.payload.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class CreateBookCommentRequest {

    @NotBlank(message = "Content cannot be blank")
    @Size(min = 1, max = 500, message = "Content must be between 1 and 500 characters")
    private String content;

    @NotNull(message = "Book post ID cannot be null")
    private Long bookPostId;

    public CreateBookCommentRequest() {
    }

    public CreateBookCommentRequest(String content, Long bookPostId) {
        this.content = content;
        this.bookPostId = bookPostId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Long getBookPostId() {
        return bookPostId;
    }

    public void setBookPostId(Long bookPostId) {
        this.bookPostId = bookPostId;
    }
}