package com.couplemap.global.filecleanup;

import com.couplemap.global.s3.S3Service;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Component
@RequiredArgsConstructor
public class FileCleanupTaskProcessor {

    private final S3Service s3Service;
    private final FileCleanupTaskRepository fileCleanupTaskRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void process(Long taskId, int maxRetry) {
        FileCleanupTask task = fileCleanupTaskRepository.findById(taskId).orElse(null);
        if (task == null) {
            return;
        }

        try {
            s3Service.deleteFile(task.getFileKey());
            task.markDone();
            log.info("파일 정리 성공: {}", task.getFileKey());
        } catch (Exception e) {
            task.markFailed(e.getMessage(), maxRetry);
            log.warn("파일 정리 실패 (retry {}): {} - {}", task.getRetryCount(), task.getFileKey(), e.getMessage());
        }
    }
}
