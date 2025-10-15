package com.couplemap.login.Repository;

import com.couplemap.login.Entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LoginUserRepository extends JpaRepository<UserEntity, Long> {
    UserEntity findByUsername(String username);
}
