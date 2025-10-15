package com.couplemap.friend.repository;

import com.couplemap.friend.domain.Friendship;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FriendshipRepository extends JpaRepository<Friendship, Long> {
}
