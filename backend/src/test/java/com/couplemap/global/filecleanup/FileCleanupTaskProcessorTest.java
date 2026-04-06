package com.couplemap.global.filecleanup;

import com.couplemap.global.s3.S3Service;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FileCleanupTaskProcessorTest {

    @Mock
    private S3Service s3Service;

    @Mock
    private FileCleanupTaskRepository fileCleanupTaskRepository;

    @InjectMocks
    private FileCleanupTaskProcessor processor;

    private FileCleanupTask task;
    private final Long taskId = 1L;
    private final int maxRetry = 3;

    @BeforeEach
    void setUp() {
        task = FileCleanupTask.of("memory/test-file.jpg");
        when(fileCleanupTaskRepository.findById(taskId)).thenReturn(Optional.of(task));
    }

    @Test
    @DisplayName("S3 삭제 성공 시 DONE 상태로 변경")
    void process_success() {
        doNothing().when(s3Service).deleteFile("memory/test-file.jpg");

        processor.process(taskId, maxRetry);

        assertThat(task.getStatus()).isEqualTo(FileCleanupStatus.DONE);
        verify(s3Service, times(1)).deleteFile("memory/test-file.jpg");
    }

    @Test
    @DisplayName("S3 삭제 실패 시 retryCount 증가")
    void process_fail_retryIncrement() {
        doThrow(new RuntimeException("Connection timeout")).when(s3Service).deleteFile("memory/test-file.jpg");

        processor.process(taskId, maxRetry);

        assertThat(task.getStatus()).isEqualTo(FileCleanupStatus.PENDING);
        assertThat(task.getRetryCount()).isEqualTo(1);
        assertThat(task.getLastError()).isEqualTo("Connection timeout");
    }

    @Test
    @DisplayName("maxRetry 도달 시 FAILED 상태로 변경")
    void process_fail_maxRetry() {
        doThrow(new RuntimeException("Connection timeout")).when(s3Service).deleteFile("memory/test-file.jpg");

        processor.process(taskId, maxRetry);
        processor.process(taskId, maxRetry);
        processor.process(taskId, maxRetry);

        assertThat(task.getStatus()).isEqualTo(FileCleanupStatus.FAILED);
        assertThat(task.getRetryCount()).isEqualTo(3);
    }
}
