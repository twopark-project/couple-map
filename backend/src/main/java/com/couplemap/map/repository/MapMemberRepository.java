package com.couplemap.map.repository;

import com.couplemap.map.domain.MapMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MapMemberRepository extends JpaRepository<MapMember, Long> {
}
