package com.example.demo.models;

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

    @OneToMany(mappedBy = "bookPost")
    private Set<BookReaction> reactions = new HashSet<>();

    public BookPost() {
    }

    public BookPost(String nombreLibro, String imagen, String autor, String descripcion) {
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
    }

    public String getImagen() {
        return imagen;
    }

    public void setImagen(String imagen) {
        this.imagen = imagen;
    }

    public String getAutor() {
        return autor;
    }

    public void setAutor(String autor) {
        this.autor = autor;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public User getPostedBy() {
        return postedBy;
    }

    public void setPostedBy(User postedBy) {
        this.postedBy = postedBy;
    }

    public Set<BookReaction> getReactions() {
        return reactions;
    }

    public void setReactions(Set<BookReaction> reactions) {
        this.reactions = reactions;
    }
}
