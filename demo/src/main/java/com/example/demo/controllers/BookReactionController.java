package com.example.demo.controllers;

import java.util.Optional;

import jakarta.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import com.example.demo.models.BookPost;
import com.example.demo.models.BookReaction;
import com.example.demo.models.Reaction;
import com.example.demo.models.User;
import com.example.demo.payload.request.BookReactionRequest;
import com.example.demo.repository.BookPostRepository;
import com.example.demo.repository.BookReactionRepository;
import com.example.demo.repository.ReactionRepository;
import com.example.demo.repository.UserRepository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/book-reactions")
public class BookReactionController {

    @Autowired
    private BookReactionRepository bookReactionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BookPostRepository bookPostRepository;

    @Autowired
    private ReactionRepository reactionRepository;

    @GetMapping("/all")
    public Page<BookReaction> getAllReactions(Pageable pageable) {
        return bookReactionRepository.findAll(pageable);
    }

    @PostMapping("/create")
    public BookReaction createReaction(@Valid @RequestBody BookReactionRequest bookReactionRequest) {

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();

        User user = getValidUser(username);
        BookPost book = getValidBook(bookReactionRequest.getBookPostId());
        Reaction reaction = getValidReaction(bookReactionRequest.getReactionId());

        BookReaction newReaction = new BookReaction();
        newReaction.setUser(user);
        newReaction.setBookPost(book);
        newReaction.setReaction(reaction);

        bookReactionRepository.save(newReaction);

        return newReaction;
    }

    private User getValidUser(String username) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        return userOpt.get();
    }

    private BookPost getValidBook(Long bookPostId) {
        Optional<BookPost> bookOpt = bookPostRepository.findById(bookPostId);
        if (bookOpt.isEmpty()) {
            throw new RuntimeException("Book not found");
        }
        return bookOpt.get();
    }

    private Reaction getValidReaction(Long reactionId) {
        Optional<Reaction> reactionOpt = reactionRepository.findById(reactionId);
        if (reactionOpt.isEmpty()) {
            throw new RuntimeException("Reaction not found");
        }
        return reactionOpt.get();
    }
}