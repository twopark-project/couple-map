package com.couplemap.global.filecleanup;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class FileCleanupService {

    @Value("${file-cleanup.max-retry}")
    private int maxRetry;

    private final FileCleanupTaskRepository fileCleanupTaskRepository;
    private final FileCleanupTaskProcessor fileCleanupTaskProcessor;

    @Transactional
    public void scheduleDelete(String fileKey) {
        fileCleanupTaskRepository.save(FileCleanupTask.of(fileKey));
    }

    @Transactional
    public void scheduleDeleteAll(List<String> fileKeys) {
        fileCleanupTaskRepository.saveAll(
                fileKeys.stream().map(FileCleanupTask::of).toList()
        );
    }

    @Scheduled(cron = "${file-cleanup.cron}")
    public void processPendingTasks() {
        List<FileCleanupTask> tasks = fileCleanupTaskRepository.findPendingTasks(maxRetry, LocalDateTime.now());

        log.info("파일 정리 배치 시작: {}건", tasks.size());

        for (FileCleanupTask task : tasks) {
            fileCleanupTaskProcessor.process(task, maxRetry);
        }

        log.info("파일 정리 배치 완료");
    }
}
