package com.example.demo.payload.response;

import com.example.demo.models.BookPost;

public class BookPostResponseDTO {

    private Long id;
    private String nombreLibro;
    private String imagen;
    private String autor;
    private String descripcion;
    private UserResponseDTO postedBy;

    public BookPostResponseDTO(BookPost bookPost) {
        this.id = bookPost.getId();
        this.nombreLibro = bookPost.getNombreLibro();
        this.imagen = bookPost.getImagen();
        this.autor = bookPost.getAutor();
        this.descripcion = bookPost.getDescripcion();

        if (bookPost.getPostedBy() != null) {
            this.postedBy = new UserResponseDTO(bookPost.getPostedBy());
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public UserResponseDTO getPostedBy() {
        return postedBy;
    }

    public void setPostedBy(UserResponseDTO postedBy) {
        this.postedBy = postedBy;
    }
}