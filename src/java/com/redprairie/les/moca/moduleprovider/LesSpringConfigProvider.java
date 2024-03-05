package com.redprairie.les.moca.moduleprovider;

import com.redprairie.les.spring.LesSpringConfiguration;
import com.redprairie.moca.common.config.bootstrap.RootBootstrapper;
import com.redprairie.moca.common.config.bootstrap.support.provider.ModuleName;
import com.redprairie.moca.common.config.bootstrap.support.provider.SpringConfigProvider;

/**
 * LesSpringConfigProvider identifies the Spring configuration classes to
 * load when creating the LES application context.
 */
public class LesSpringConfigProvider implements SpringConfigProvider {
    @Override
    public Class<?>[] provideSpringConfigs() {
        return new Class<?>[] {
                LesSpringConfiguration.class
        };
    }

    @Override
    public ModuleName forModuleName() {
        return RootBootstrapper.ROOT_APPLICATION;
    }
}
