package com.example.demo.controllers;

import java.util.Optional;

import jakarta.validation.Valid;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.BookComment;
import com.example.demo.models.BookPost;
import com.example.demo.models.User;
import com.example.demo.payload.request.CreateBookCommentRequest;
import com.example.demo.payload.response.BookCommentResponseDTO;
import com.example.demo.payload.response.MessageResponse;
import com.example.demo.repository.BookCommentRepository;
import com.example.demo.repository.BookPostRepository;
import com.example.demo.repository.UserRepository;

@CrossOrigin(originPatterns = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/book-comments")
public class BookCommentController {

    private final BookCommentRepository bookCommentRepository;
    private final BookPostRepository bookPostRepository;
    private final UserRepository userRepository;

    public BookCommentController(
            BookCommentRepository bookCommentRepository,
            BookPostRepository bookPostRepository,
            UserRepository userRepository
    ) {
        this.bookCommentRepository = bookCommentRepository;
        this.bookPostRepository = bookPostRepository;
        this.userRepository = userRepository;
    }

    @GetMapping("/book/{bookPostId}")
    @Transactional(readOnly = true)
    public ResponseEntity<?> getCommentsByBook(
            @PathVariable Long bookPostId,
            Pageable pageable
    ) {
        Optional<BookPost> bookOpt = bookPostRepository.findById(bookPostId);

        if (bookOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new MessageResponse("Book not found"));
        }

        Page<BookCommentResponseDTO> comments =
                bookCommentRepository
                        .findByBookPostOrderByCreatedAtDesc(bookOpt.get(), pageable)
                        .map(BookCommentResponseDTO::new);

        return ResponseEntity.ok(comments);
    }

    @PostMapping
    public ResponseEntity<?> createComment(
            @Valid @RequestBody CreateBookCommentRequest request
    ) {
        try {
            User user = getAuthenticatedUser();

            BookPost bookPost = bookPostRepository.findById(request.getBookPostId())
                    .orElseThrow(() -> new RuntimeException("Book not found"));

            BookComment comment = new BookComment(
                    request.getContent(),
                    user,
                    bookPost
            );

            BookComment savedComment = bookCommentRepository.save(comment);

            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(new BookCommentResponseDTO(savedComment));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{commentId}")
    public ResponseEntity<?> deleteComment(@PathVariable Long commentId) {
        if (!bookCommentRepository.existsById(commentId)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new MessageResponse("Comment not found"));
        }

        bookCommentRepository.deleteById(commentId);

        return ResponseEntity.ok(
                new MessageResponse("Comment deleted successfully")
        );
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