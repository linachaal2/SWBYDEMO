package com.redprairie.les.spring;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;
import org.springframework.context.annotation.Scope;

/**
 * LesSpringConfiguration loads the LES Spring beans.
 */
@Configuration
@ImportResource("classpath*:com/redprairie/les/spring/les-spring-config.xml")
public class LesSpringConfiguration {

}
