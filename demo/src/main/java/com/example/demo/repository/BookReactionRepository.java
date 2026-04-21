package com.example.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.models.BookReaction;

@Repository
public interface BookReactionRepository extends JpaRepository<BookReaction, Long> {
}