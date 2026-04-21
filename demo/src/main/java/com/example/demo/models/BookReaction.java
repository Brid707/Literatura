package com.example.demo.models;

import jakarta.persistence.*;

@Entity
@Table(
    name = "book_reactions",
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"user_id", "book_post_id"})
    }
)
public class BookReaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "reaction_id")
    private Long reactionId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "book_post_id")
    private Long bookPostId;

    @ManyToOne
    @JoinColumn(name = "user_id", insertable = false, updatable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "book_post_id", insertable = false, updatable = false)
    private BookPost bookPost;

    @ManyToOne
    @JoinColumn(name = "reaction_id", insertable = false, updatable = false)
    private Reaction reaction;

    public BookReaction() {
    }

    public Long getId() {
        return id;
    }

    public Long getReactionId() {
        return reactionId;
    }

    public void setReactionId(Long reactionId) {
        this.reactionId = reactionId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Long getBookPostId() {
        return bookPostId;
    }

    public void setBookPostId(Long bookPostId) {
        this.bookPostId = bookPostId;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
        this.userId = user.getId();
    }

    public BookPost getBookPost() {
        return bookPost;
    }

    public void setBookPost(BookPost bookPost) {
        this.bookPost = bookPost;
        this.bookPostId = bookPost.getId();
    }

    public Reaction getReaction() {
        return reaction;
    }

    public void setReaction(Reaction reaction) {
        this.reaction = reaction;
        this.reactionId = reaction.getId();
    }
}