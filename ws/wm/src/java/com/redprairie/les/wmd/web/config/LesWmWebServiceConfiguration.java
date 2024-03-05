package com.redprairie.les.wmd.web.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.ImportResource;

/**
 * Configuration class for Spring MVC Web Services. This configuration class
 * scans for web service spring configs.
 *
 * Copyright (c) 2014 JDA Corporation
 * All Rights Reserved
 */
@Configuration
@ImportResource("classpath*:com/redprairie/les/wmd/web/**/*-config.xml")
public class LesWmWebServiceConfiguration {
}
