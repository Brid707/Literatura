package com.example.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.models.Reaction;

@Repository
public interface ReactionRepository extends JpaRepository<Reaction, Long> {
}