package com.example.demo.controllers;

import java.util.List;
import java.util.Optional;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.BookPost;
import com.example.demo.models.User;
import com.example.demo.payload.response.BookPostResponseDTO;
import com.example.demo.repository.BookPostRepository;
import com.example.demo.repository.UserRepository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/books")
public class BookPostController {

    @Autowired
    private BookPostRepository bookPostRepository;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/all")
    @Transactional(readOnly = true)
    public Page<BookPostResponseDTO> getBooks(Pageable pageable) {
        Page<BookPost> books = bookPostRepository.findAll(pageable);
        return books.map(BookPostResponseDTO::new);
    }

    @GetMapping
    @Transactional(readOnly = true)
    public List<BookPost> getAllBooksSimple() {
        return bookPostRepository.findAll();
    }

    @PostMapping("/create")
    public BookPost createBook(@Valid @RequestBody BookPost bookPost) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        User user = getValidUser(username);

        BookPost newBook = new BookPost(
            bookPost.getNombreLibro(),
            bookPost.getImagen(),
            bookPost.getAutor(),
            bookPost.getDescripcion()
        );

        newBook.setPostedBy(user);
        bookPostRepository.save(newBook);

        return newBook;
    }

    @DeleteMapping("/{id}")
    public void deleteBook(@PathVariable Long id) {
        bookPostRepository.deleteById(id);
    }

    private User getValidUser(String username) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        return userOpt.get();
    }
}
