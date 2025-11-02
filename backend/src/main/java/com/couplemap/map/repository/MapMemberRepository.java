package com.couplemap.map.repository;

import com.couplemap.map.domain.MapMember;
import com.couplemap.user.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MapMemberRepository extends JpaRepository<MapMember, Long> {
    List<MapMember> findAllByUser(User user);
}
