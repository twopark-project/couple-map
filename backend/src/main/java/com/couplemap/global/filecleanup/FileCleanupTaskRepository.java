package com.couplemap.global.filecleanup;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface FileCleanupTaskRepository extends JpaRepository<FileCleanupTask, Long> {

    @Query("SELECT t FROM FileCleanupTask t WHERE t.status = 'PENDING' " +
            "AND t.retryCount < :maxRetry " +
            "AND t.nextRetryAt <= :now")
    List<FileCleanupTask> findPendingTasks(int maxRetry, LocalDateTime now);
}
