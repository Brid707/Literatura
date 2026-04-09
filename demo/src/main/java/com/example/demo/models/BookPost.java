package com.example.demo.models;

import jakarta.persistence.*;

@Entity
@Table(name = "book_posts")
public class BookPost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String nombreLibro;

    @Column(nullable = false, length = 1000)
    private String imagen;

    @Column(nullable = false)
    private String autor;

    @Column(nullable = false, length = 3000)
    private String descripcion;

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
}
