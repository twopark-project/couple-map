package com.couplemap.friend.repository;

import com.couplemap.friend.domain.Friendship;
import com.couplemap.friend.domain.FriendshipStatus;
import com.couplemap.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FriendshipRepository extends JpaRepository<Friendship, Long> {

    // 나를 친구로 추가한 사람들
    @Query("SELECT f.requester " +
            "FROM Friendship f " +
            "WHERE f.receiver.userId = :userId " +
            "AND f.status = :status")
    List<User> findFriendsWhereReceiver(@Param("userId") Long userId,
                                         @Param("status") FriendshipStatus status);

    // 내가 친구로 추가한 사람들
    @Query("SELECT f.receiver " +
            "FROM Friendship f " +
            "WHERE f.requester.userId = :userId " +
            "AND f.status = :status")
    List<User> findFriendsWhereRequester(@Param("userId") Long userId,
                                        @Param("status") FriendshipStatus status);

    @Query("SELECT COUNT(f) > 0 FROM Friendship f " +
            "WHERE ((f.requester = :user1 AND f.receiver = :user2) " +
            "OR (f.requester = :user2 AND f.receiver = :user1)) " +
            "AND f.status = :status")
    boolean existsFriendship(@Param("user1") User user1,
                             @Param("user2") User user2,
                             @Param("status") FriendshipStatus status);

    @Query("SELECT f FROM Friendship f " +
            "WHERE f.receiver.userId = :userId AND f.status = :status")
    List<Friendship> findFriendshipsWhereReceiver(@Param("userId") Long userId,
                                                  @Param("status") FriendshipStatus status);

    @Query("DELETE FROM Friendship f WHERE f.requester.userId = :userId OR f.receiver.userId = :userId")
    @org.springframework.data.jpa.repository.Modifying
    void deleteAllByUserId(@Param("userId") Long userId);
}
