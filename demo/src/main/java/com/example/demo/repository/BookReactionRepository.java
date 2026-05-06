package com.example.demo.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.models.BookPost;
import com.example.demo.models.BookReaction;
import com.example.demo.models.EReaction;
import com.example.demo.models.User;

@Repository
public interface BookReactionRepository extends JpaRepository<BookReaction, Long> {

    List<BookReaction> findByBookPost(BookPost bookPost);

    Long countByBookPost(BookPost bookPost);

    Long countByBookPostAndType(BookPost bookPost, EReaction type);

    Optional<BookReaction> findByBookPostAndReactedBy(BookPost bookPost, User reactedBy);
}