package com.couplemap;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class CouplemapApplication {

	public static void main(String[] args) {
		SpringApplication.run(CouplemapApplication.class, args);
	}

}
