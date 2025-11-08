package com.couplemap.jwt.repository;

import com.couplemap.jwt.entity.RefreshToken;
import org.springframework.data.repository.CrudRepository;

public interface RefreshTokenRepository extends CrudRepository<RefreshToken, String> {

    void deleteById(String userId);
}