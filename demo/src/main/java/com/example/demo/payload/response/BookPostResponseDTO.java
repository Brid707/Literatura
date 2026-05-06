package com.example.demo.payload.response;

import java.time.Instant;

import com.example.demo.models.BookPost;

public class BookPostResponseDTO {

    private Long id;
    private String nombreLibro;
    private String imagen;
    private String autor;
    private String descripcion;
    private String postedByUsername;
    private Long postedByUserId;
    private Long commentsCount;
    private Long reactionsCount;
    private Instant createdAt;
    private Instant updatedAt;

    public BookPostResponseDTO(BookPost bookPost, Long commentsCount, Long reactionsCount) {
        this.id = bookPost.getId();
        this.nombreLibro = bookPost.getNombreLibro();
        this.imagen = bookPost.getImagen();
        this.autor = bookPost.getAutor();
        this.descripcion = bookPost.getDescripcion();

        if (bookPost.getPostedBy() != null) {
            this.postedByUsername = bookPost.getPostedBy().getUsername();
            this.postedByUserId = bookPost.getPostedBy().getId();
        }

        this.commentsCount = commentsCount;
        this.reactionsCount = reactionsCount;
        this.createdAt = bookPost.getCreatedAt();
        this.updatedAt = bookPost.getUpdatedAt();
    }

    public Long getId() {
        return id;
    }

    public String getNombreLibro() {
        return nombreLibro;
    }

    public String getImagen() {
        return imagen;
    }

    public String getAutor() {
        return autor;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public String getPostedByUsername() {
        return postedByUsername;
    }

    public Long getPostedByUserId() {
        return postedByUserId;
    }

    public Long getCommentsCount() {
        return commentsCount;
    }

    public Long getReactionsCount() {
        return reactionsCount;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}