package com.example.demo.models;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Entity
@Table(name = "book_posts")
public class BookPost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 200)
    private String nombreLibro;

    @NotBlank
    @Size(max = 1000)
    private String imagen;

    @NotBlank
    @Size(max = 150)
    private String autor;

    @NotBlank
    @Size(max = 3000)
    private String descripcion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "posted_by", referencedColumnName = "id")
    private User postedBy;

    @Temporal(TemporalType.TIMESTAMP)
    private Instant createdAt;

    @Temporal(TemporalType.TIMESTAMP)
    private Instant updatedAt;

    @OneToMany(mappedBy = "bookPost", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<BookComment> comments = new HashSet<>();

    @OneToMany(mappedBy = "bookPost", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<BookReaction> reactions = new HashSet<>();

    public BookPost() {
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public BookPost(String nombreLibro, String imagen, String autor, String descripcion) {
        this();
        this.nombreLibro = nombreLibro;
        this.imagen = imagen;
        this.autor = autor;
        this.descripcion = descripcion;
    }

    public Long getId() {
        return id;
    }

    public String getNombreLibro() {
        return nombreLibro;
    }

    public void setNombreLibro(String nombreLibro) {
        this.nombreLibro = nombreLibro;
        this.updatedAt = Instant.now();
    }

    public String getImagen() {
        return imagen;
    }

    public void setImagen(String imagen) {
        this.imagen = imagen;
        this.updatedAt = Instant.now();
    }

    public String getAutor() {
        return autor;
    }

    public void setAutor(String autor) {
        this.autor = autor;
        this.updatedAt = Instant.now();
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
        this.updatedAt = Instant.now();
    }

    public User getPostedBy() {
        return postedBy;
    }

    public void setPostedBy(User postedBy) {
        this.postedBy = postedBy;
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

    public Set<BookComment> getComments() {
        return comments;
    }

    public void setComments(Set<BookComment> comments) {
        this.comments = comments;
    }

    public Set<BookReaction> getReactions() {
        return reactions;
    }

    public void setReactions(Set<BookReaction> reactions) {
        this.reactions = reactions;
    }

    public long getCommentsCount() {
        return comments.size();
    }

    public long getReactionsCount() {
        return reactions.size();
    }
}