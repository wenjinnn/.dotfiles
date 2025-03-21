local home = os.getenv('HOME')
local jdtls_maven_settings = os.getenv('JDTLS_MAVEN_SETTINGS')
local java_8_home = os.getenv('JAVA_8_HOME')
local java_17_home = os.getenv('JAVA_17_HOME')
local java_21_home = os.getenv('JAVA_21_HOME')
local config_path = vim.fn.stdpath('config')
local M = {
  java = {
    settings = {
      url = config_path .. '/lua/lsp/jdtls/settings.prefs',
    },
    eclipse = {
      downloadSources = true,
    },
    symbols = {
      includeSourceMethodDeclarations = true,
    },
    selectionRange = { enabled = true },
    recommendations = {
      dependency = {
        analytics = {
          show = true,
        },
      },
    },
    format = {
      enabled = true,
      comments = {
        enabled = false,
      },
      onType = {
        enabled = false,
      },
    },
    maxConcurrentBuilds = 5,
    saveActions = {
      organizeImports = false,
    },
    trace = {
      server = 'verbose',
    },
    referencesCodeLens = { enabled = true },
    implementationsCodeLens = { enabled = true },
    signatureHelp = {
      enabled = true,
      description = {
        enabled = true,
      },
    },
    inlayHints = {
      parameterNames = { enabled = 'all' },
    },
    contentProvider = { preferred = 'fernflower' },
    templates = {
      typeComment = {
        '/**',
        ' * @author: ${user}',
        ' * @date: ${date}',
        ' * @description: ',
        ' */',
      },
    },
    typeHierarchy = {
      lazyLoad = true,
    },
    import = {
      gradle = { enabled = true },
      generatesMetadataFilesAtProjectRoot = false,
      maven = { enabled = true },
      exclusions = {
        '**/node_modules/**',
        '**/.metadata/**',
        '**/archetype-resources/**',
        '**/META-INF/maven/**',
        '**/Frontend/**',
        '**/CSV_Aggregator/**',
      },
    },
    maven = {
      downloadSources = true,
    },
    autobuild = { enabled = true },
    completion = {
      maxResults = 0,
      filteredTypes = {
        'com.sun.*',
        'io.micrometer.shaded.*',
        'java.awt.*',
        'jdk.*',
        'sun.*',
      },
      project = {
        resourceFilters = {
          'build',
          'node_modules',
          '\\.git',
          '\\.idea',
          '\\.cache',
          '\\.vscode',
          '\\.settings',
        },
      },
      overwrite = false,
      guessMethodArguments = true,
      favoriteStaticMembers = {
        'org.hamcrest.MatcherAssert.assertThat',
        'org.hamcrest.Matchers.*',
        'org.hamcrest.CoreMatchers.*',
        'org.junit.jupiter.api.Assertions.*',
        'java.util.Objects.requireNonNull',
        'java.util.Objects.requireNonNullElse',
        'org.mockito.Mockito.*',
      },
    },
    sources = {
      organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
    },
    codeGeneration = {
      generateComments = true,
      useBlocks = true,
      toString = {
        template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
      },
    },
    configuration = {
      updateBuildConfiguration = 'automatic',
      maven = {
        globalSettings = '/opt/maven/conf/settings.xml',
        userSettings = jdtls_maven_settings or home .. '/.m2/settings.xml',
      },
      runtimes = {
        {
          name = 'JavaSE-1.8',
          path = java_8_home or '/usr/lib/jvm/java-8-openjdk/',
          default = true,
        },
        {
          name = 'JavaSE-17',
          path = java_17_home or '/usr/lib/jvm/java-17-openjdk/',
          default = true,
        },
        {
          name = 'JavaSE-21',
          path = java_21_home or '/usr/lib/jvm/java-21-openjdk/',
        },
      },
    },
  },
}

return M
