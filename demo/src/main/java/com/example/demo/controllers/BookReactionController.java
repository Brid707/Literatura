package com.example.demo.controllers;

import java.util.List;
import java.util.Optional;

import jakarta.validation.Valid;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.BookPost;
import com.example.demo.models.BookReaction;
import com.example.demo.models.User;
import com.example.demo.payload.request.BookReactionRequest;
import com.example.demo.payload.response.BookReactionResponseDTO;
import com.example.demo.payload.response.MessageResponse;
import com.example.demo.repository.BookPostRepository;
import com.example.demo.repository.BookReactionRepository;
import com.example.demo.repository.UserRepository;

@CrossOrigin(originPatterns = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/book-reactions")
public class BookReactionController {

    private final BookReactionRepository bookReactionRepository;
    private final UserRepository userRepository;
    private final BookPostRepository bookPostRepository;

    public BookReactionController(
            BookReactionRepository bookReactionRepository,
            UserRepository userRepository,
            BookPostRepository bookPostRepository
    ) {
        this.bookReactionRepository = bookReactionRepository;
        this.userRepository = userRepository;
        this.bookPostRepository = bookPostRepository;
    }

    @GetMapping("/book/{bookPostId}")
    public ResponseEntity<?> getReactionsByBook(@PathVariable Long bookPostId) {
        Optional<BookPost> bookOpt = bookPostRepository.findById(bookPostId);

        if (bookOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new MessageResponse("Book not found"));
        }

        List<BookReactionResponseDTO> reactions =
                bookReactionRepository.findByBookPost(bookOpt.get())
                        .stream()
                        .map(BookReactionResponseDTO::new)
                        .toList();

        return ResponseEntity.ok(reactions);
    }

    @PostMapping
    public ResponseEntity<?> createReaction(
            @Valid @RequestBody BookReactionRequest request
    ) {
        try {
            User user = getAuthenticatedUser();

            BookPost book = bookPostRepository
                    .findById(request.getBookPostId())
                    .orElseThrow(() -> new RuntimeException("Book not found"));

            Optional<BookReaction> existingReaction =
                    bookReactionRepository.findByBookPostAndReactedBy(book, user);

            BookReaction reaction;

            if (existingReaction.isPresent()) {
                reaction = existingReaction.get();
                reaction.setType(request.getType());
            } else {
                reaction = new BookReaction(
                        request.getType(),
                        user,
                        book
                );
            }

            BookReaction savedReaction =
                    bookReactionRepository.save(reaction);

            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(new BookReactionResponseDTO(savedReaction));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{reactionId}")
    public ResponseEntity<?> deleteReaction(@PathVariable Long reactionId) {
        if (!bookReactionRepository.existsById(reactionId)) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new MessageResponse("Reaction not found"));
        }

        bookReactionRepository.deleteById(reactionId);

        return ResponseEntity.ok(
                new MessageResponse("Reaction deleted successfully")
        );
    }

    @DeleteMapping("/book/{bookPostId}/user")
    public ResponseEntity<?> removeUserReactionFromBook(
            @PathVariable Long bookPostId
    ) {
        try {
            User user = getAuthenticatedUser();

            BookPost book = bookPostRepository
                    .findById(bookPostId)
                    .orElseThrow(() -> new RuntimeException("Book not found"));

            Optional<BookReaction> reaction =
                    bookReactionRepository.findByBookPostAndReactedBy(book, user);

            reaction.ifPresent(bookReactionRepository::delete);

            return ResponseEntity.ok(
                    new MessageResponse("Reaction removed successfully")
            );
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new MessageResponse("Error: " + e.getMessage()));
        }
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