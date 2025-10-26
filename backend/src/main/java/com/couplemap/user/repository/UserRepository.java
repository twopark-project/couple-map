package com.couplemap.user.repository;

import com.couplemap.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    User findByProviderId(String providerId);
    Optional<User> findByFriendCode(String friendCode);

}
