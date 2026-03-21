package com.couplemap.memory.repository;

import com.couplemap.memory.domain.Memory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MemoryRepository extends JpaRepository<Memory, Long> {
    List<Memory> findAllByMap_MapId(Long mapId);

    @Query("SELECT m FROM Memory m " +
            "JOIN MapMember mm ON m.map = mm.map " +
            "WHERE mm.user.userId = :userId " +
            "AND mm.mapMemberRole IN (com.couplemap.map.domain.MapMemberRole.OWNER, com.couplemap.map.domain.MapMemberRole.EDITOR) " +
            "AND YEAR(m.memoryDate) = :year " +
            "ORDER BY m.memoryDate ASC")
    List<Memory> findAllByUserIdAndYear(@Param("userId") Long userId, @Param("year") int year);

    @Query("SELECT COUNT(m) FROM Memory m " +
            "JOIN MapMember mm ON m.map = mm.map " +
            "WHERE mm.user.userId = :userId " +
            "AND mm.mapMemberRole IN (com.couplemap.map.domain.MapMemberRole.OWNER, com.couplemap.map.domain.MapMemberRole.EDITOR)")
    long countByUserMaps(@Param("userId") Long userId);
}
