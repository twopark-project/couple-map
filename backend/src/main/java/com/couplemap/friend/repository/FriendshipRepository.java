package com.couplemap.friend.repository;

import com.couplemap.friend.domain.Friendship;
import com.couplemap.friend.domain.FriendshipStatus;
import com.couplemap.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface FriendshipRepository extends JpaRepository<Friendship, Long> {

    @Query("SELECT COUNT(f) > 0 FROM Friendship f " +
            "WHERE ((f.requester = :user1 AND f.receiver = :user2) " +
            "OR (f.requester = :user2 AND f.receiver = :user1)) " +
            "AND f.status = :status")
    boolean existsFriendship(@Param("user1") User user1,
                             @Param("user2") User user2,
                             @Param("status") FriendshipStatus status);
}
