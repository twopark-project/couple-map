package com.couplemap.map.repository;

import com.couplemap.map.domain.MapMember;
import com.couplemap.map.domain.MapMemberRole;
import com.couplemap.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MapMemberRepository extends JpaRepository<MapMember, Long> {
    List<MapMember> findAllByUser(User user);

    Optional<MapMember> findByMap_MapIdAndUser_UserId(Long mapId, Long userId);

    List<MapMember> findAllByUserAndMapMemberRole(User user, MapMemberRole role);
}
