package com.example.demo.repository;

import com.example.demo.models.BookPost;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BookPostRepository extends JpaRepository<BookPost, Long> {
}
