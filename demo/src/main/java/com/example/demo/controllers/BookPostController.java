package com.example.demo.controllers;

import java.util.List;
import java.util.Optional;

import jakarta.validation.Valid;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.BookPost;
import com.example.demo.models.User;
import com.example.demo.payload.response.BookPostResponseDTO;
import com.example.demo.payload.response.MessageResponse;
import com.example.demo.repository.BookCommentRepository;
import com.example.demo.repository.BookPostRepository;
import com.example.demo.repository.BookReactionRepository;
import com.example.demo.repository.UserRepository;

@CrossOrigin(originPatterns = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/books")
public class BookPostController {

    private final BookPostRepository bookPostRepository;
    private final BookCommentRepository bookCommentRepository;
    private final BookReactionRepository bookReactionRepository;
    private final UserRepository userRepository;

    public BookPostController(
            BookPostRepository bookPostRepository,
            BookCommentRepository bookCommentRepository,
            BookReactionRepository bookReactionRepository,
            UserRepository userRepository
    ) {
        this.bookPostRepository = bookPostRepository;
        this.bookCommentRepository = bookCommentRepository;
        this.bookReactionRepository = bookReactionRepository;
        this.userRepository = userRepository;
    }

    @GetMapping("/all")
    @Transactional(readOnly = true)
    public Page<BookPostResponseDTO> getBooks(Pageable pageable) {
        Page<BookPost> books = bookPostRepository.findAll(pageable);
        return books.map(this::toDTO);
    }

    @GetMapping
    @Transactional(readOnly = true)
    public List<BookPostResponseDTO> getAllBooksSimple() {
        List<BookPost> books = bookPostRepository.findAll();

        return books.stream()
                .map(this::toDTO)
                .toList();
    }

    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    public ResponseEntity<?> getBookById(@PathVariable Long id) {
        Optional<BookPost> bookOpt = bookPostRepository.findById(id);

        if (bookOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new MessageResponse("Book not found"));
        }

        return ResponseEntity.ok(toDTO(bookOpt.get()));
    }

    @PostMapping("/create")
    public ResponseEntity<?> createBook(
            @Valid @RequestBody BookPost bookPost
    ) {
        try {
            User user = getAuthenticatedUser();

            BookPost newBook = new BookPost(
                    bookPost.getNombreLibro(),
                    bookPost.getImagen(),
                    bookPost.getAutor(),
                    bookPost.getDescripcion()
            );

            newBook.setPostedBy(user);

            BookPost savedBook = bookPostRepository.save(newBook);

            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(toDTO(savedBook));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteBook(@PathVariable Long id) {
        if (!bookPostRepository.existsById(id)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new MessageResponse("Book not found"));
        }

        bookPostRepository.deleteById(id);

        return ResponseEntity.ok(
                new MessageResponse("Book deleted successfully")
        );
    }

    private BookPostResponseDTO toDTO(BookPost bookPost) {
        Long commentsCount = bookCommentRepository.countByBookPost(bookPost);
        Long reactionsCount = bookReactionRepository.countByBookPost(bookPost);

        return new BookPostResponseDTO(bookPost, commentsCount, reactionsCount);
    }

    private User getAuthenticatedUser() {
        Authentication authentication =
                SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || authentication.getName() == null) {
            throw new RuntimeException("User not authenticated");
        }

        String username = authentication.getName();

        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
    }
}