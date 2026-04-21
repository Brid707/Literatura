package com.example.demo.config;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.example.demo.models.ERole;
import com.example.demo.models.Role;
import com.example.demo.repository.RoleRepository;

@Configuration
public class DataLoader {

    @Bean
    CommandLineRunner initRoles(RoleRepository roleRepository) {
        return args -> {

            if (roleRepository.findByName(ERole.ROLE_USER).isEmpty()) {
                roleRepository.save(new Role(ERole.ROLE_USER));
            }

            if (roleRepository.findByName(ERole.ROLE_MODERATOR).isEmpty()) {
                roleRepository.save(new Role(ERole.ROLE_MODERATOR));
            }

            if (roleRepository.findByName(ERole.ROLE_ADMIN).isEmpty()) {
                roleRepository.save(new Role(ERole.ROLE_ADMIN));
            }

            System.out.println("Roles cargados correctamente 🚀");
        };
    }
}
