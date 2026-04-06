package com.couplemap.mediaFile.repository;

import com.couplemap.mediaFile.domain.MediaFile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MediaFileRepository extends JpaRepository<MediaFile, Long> {

    @Query("SELECT mf FROM MediaFile mf WHERE mf.memory.memoryId = :memoryId")
    List<MediaFile> findByMemoryId(@Param("memoryId") Long memoryId);

    @Query("SELECT mf FROM MediaFile mf WHERE mf.memory.memoryId = :memoryId ORDER BY mf.displayOrder ASC")
    List<MediaFile> findByMemoryIdOrderByDisplayOrder(@Param("memoryId") Long memoryId);

    @Query("SELECT mf FROM MediaFile mf WHERE mf.memory.memoryId IN :memoryIds ORDER BY mf.displayOrder ASC")
    List<MediaFile> findByMemoryIdIn(@Param("memoryIds") List<Long> memoryIds);

    @Query("SELECT mf.fileKey FROM MediaFile mf WHERE mf.memory.user.userId = :userId")
    List<String> findFileKeysByUserId(@Param("userId") Long userId);

    @Query("SELECT mf.fileKey FROM MediaFile mf WHERE mf.memory.map.mapId = :mapId")
    List<String> findFileKeysByMapId(@Param("mapId") Long mapId);
}
