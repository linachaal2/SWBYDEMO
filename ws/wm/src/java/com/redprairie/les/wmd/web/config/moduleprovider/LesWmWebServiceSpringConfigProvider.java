package com.redprairie.les.wmd.web.config.moduleprovider;

import com.redprairie.les.wmd.web.config.LesWmWebServiceConfiguration;
import com.redprairie.moca.common.config.bootstrap.support.provider.ModuleName;
import com.redprairie.moca.common.config.bootstrap.support.provider.SpringConfigProvider;
import com.redprairie.wmd.web.rpux.WmModuleNames;

/**
 * Identifies the Spring configuration classes to
 * load when creating the base WM application context.
 *
 * Copyright (c) 2014 JDA Corporation
 * All Rights Reserved
 */
public class LesWmWebServiceSpringConfigProvider implements SpringConfigProvider {
    @Override
    public Class<?>[] provideSpringConfigs() {
        return new Class<?>[] {
            LesWmWebServiceConfiguration.class
        };
    }

    @Override
    public ModuleName forModuleName() {
        return WmModuleNames.WM;
    }
}
