package com.example.demo.repository;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.models.BookComment;
import com.example.demo.models.BookPost;

@Repository
public interface BookCommentRepository extends JpaRepository<BookComment, Long> {

    List<BookComment> findByBookPost(BookPost bookPost);

    Page<BookComment> findByBookPostOrderByCreatedAtDesc(BookPost bookPost, Pageable pageable);

    Long countByBookPost(BookPost bookPost);
}