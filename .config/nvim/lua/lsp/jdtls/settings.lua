local home = os.getenv('HOME')
local jdtls_maven_settings = os.getenv('JDTLS_MAVEN_SETTINGS')
local jdtls_java_home = os.getenv('JDTLS_JAVA_HOME')
local java_home = os.getenv('JAVA_HOME')
local config_path = vim.fn.stdpath('config')
local data_path = vim.fn.stdpath('data')
local M = {
  java = {
    settings = {
      url = config_path .. '/lua/lsp/jdtls/settings.prefs'
    },
    jdt = {
      ls = {
        lombokSupport = { enabled = true },
        java = {
          home = jdtls_java_home or java_home
        },
        vmargs = "-XX:+UseZGC -XX:GCTimeRatio=4 -XX:AdaptiveSizePolicyWeight=90 -Dsun.zip.disableMemoryMapping=true -Xmx2G -Xms1G -javaagent:'"
            .. data_path .. "/mason/packages/jdtls/lombok.jar'"
      }
    },
    eclipse = {
      downloadSources = true,
    },
    symbols = {
      includeSourceMethodDeclarations = true
    },
    quickfix = {
      showAt = true
    },
    selectionRange = { enabled = true },
    recommendations = {
      dependency = {
        analytics = {
          show = true
        }
      }
    },
    format = {
      enabled = false,
      comments = {
        enabled = false
      },
      onType = {
        enabled = false
      },
      settings = {
        -- url = config_path .. '/lua/lsp/jdtls/eclipse-java-google-style.xml',
        profile = "google-java-format",
      }
    },
    maxConcurrentBuilds = 5,
    saveActions = {
      organizeImports = false,
    },
    trace = {
      server = "verbose"
    },
    referencesCodeLens = { enabled = true },
    implementationsCodeLens = { enabled = true },
    signatureHelp = {
      enabled = true,
      description = {
        enabled = true
      }
    },
    contentProvider = { preferred = 'fernflower' },
    templates = {
      fileHeader = {
        "/**",
        " * @author: ${user}",
        " * @date: ${date}",
        " * @description: ",
        " */",
      },
      typeComment = {
        "/**",
        " * @author: ${user}",
        " * @date: ${date}",
        " * @description: ",
        " */",
      }
    },
    typeHierarchy = {
      lazyLoad = true
    },
    import = {
      gradle = { enabled = true },
      generatesMetadataFilesAtProjectRoot = true,
      maven = { enabled = true },
      exclusions = {
        "**/node_modules/**",
        "**/.metadata/**",
        "**/archetype-resources/**",
        "**/META-INF/maven/**",
        "**/Frontend/**",
        "**/CSV_Aggregator/**"
      },
    },
    maven = {
      downloadSources = true
    },
    autobuild = { enabled = true },
    completion = {
      filteredTypes = {
        "java.awt.List",
        "com.sun.*"
      },
      overwrite = false,
      guessMethodArguments = true,
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat", "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*", "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse", "org.mockito.Mockito.*"
      }
    },
    sources = {
      organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 }
    },
    codeGeneration = {
      generateComments = true,
      useBlocks = true,
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
      }
    },
    decompiler = {
      fernflower = {
        asc = 1,
        ind = "    "
      }
    },
    home = "/usr/lib/jvm/java-17-openjdk/",
    configuration = {
      updateBuildConfiguration = 'automatic',
      maven = {
        globalSettings = "/opt/maven/conf/settings.xml",
        userSettings = jdtls_maven_settings or home .. "/.m2/settings.xml",
      },
      runtimes = {
        -- {
        --   name = "JavaSE-11",
        --   path = "/usr/lib/jvm/java-11-openjdk/"
        -- },
        {
          name = "JavaSE-1.8",
          path = "/usr/lib/jvm/java-8-openjdk/",
          default = true
        },
        {
          name = "JavaSE-17",
          path = "/usr/lib/jvm/java-17-openjdk/",
        },
      }
    }
  }
}

return M
