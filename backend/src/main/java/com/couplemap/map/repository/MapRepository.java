package com.couplemap.map.repository;

import com.couplemap.map.domain.Map;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MapRepository extends JpaRepository<Map, Long> {

    @Query("SELECT mm.map FROM MapMember mm WHERE mm.user.id = :userId")
    List<Map> findAllByUserId(@Param("userId") Long userId);
}
