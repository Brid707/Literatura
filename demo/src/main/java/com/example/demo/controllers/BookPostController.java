package com.example.demo.controllers;

import com.example.demo.models.BookPost;
import com.example.demo.repository.BookPostRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/books")
@CrossOrigin("*")
public class BookPostController {

    private final BookPostRepository bookPostRepository;

    public BookPostController(BookPostRepository bookPostRepository) {
        this.bookPostRepository = bookPostRepository;
    }

    @GetMapping
    public List<BookPost> getAllBooks() {
        return bookPostRepository.findAll();
    }

    @PostMapping
    public BookPost createBook(@RequestBody BookPost bookPost) {
        return bookPostRepository.save(bookPost);
    }

    @DeleteMapping("/{id}")
    public void deleteBook(@PathVariable Long id) {
        bookPostRepository.deleteById(id);
    }
}
