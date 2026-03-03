package com.couplemap.map.repository;

import com.couplemap.map.domain.Map;
import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MapMemberRepository extends JpaRepository<MapMember, Long> {
    List<MapMember> findAllByUser(User user);

    Optional<MapMember> findByMap_MapIdAndUser_UserId(Long mapId, Long userId);

    List<MapMember> findAllByUserAndMapMemberRole(User user, MapMemberRole role);

    void deleteAllByMap(Map map);

    long countByMap_MapIdAndMapMemberRoleNot(Long mapId, MapMemberRole role);

    @Query("SELECT COUNT(mm) > 0 FROM MapMember mm " +
            "WHERE mm.user.userId = :userId AND mm.map.mapName = :mapName " +
            "AND mm.mapMemberRole != 'PENDING'")
    boolean existsByUserIdAndMapName(@Param("userId") Long userId, @Param("mapName") String mapName);

    @Query("SELECT COUNT(mm) > 0 FROM MapMember mm " +
            "WHERE mm.user.userId = :userId AND mm.map.mapName = :mapName " +
            "AND mm.map.mapId != :excludeMapId AND mm.mapMemberRole != 'PENDING'")
    boolean existsByUserIdAndMapNameExcludingMapId(@Param("userId") Long userId,
                                                     @Param("mapName") String mapName,
                                                     @Param("excludeMapId") Long excludeMapId);
}
