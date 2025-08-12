local home = os.getenv('HOME')
local jdtls_maven_settings = os.getenv('JDTLS_MAVEN_SETTINGS')
local java8_home = os.getenv('JAVA8_HOME')
local java17_home = os.getenv('JAVA17_HOME')
local java21_home = os.getenv('JAVA21_HOME')
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
    import = {
      gradle = { enabled = true },
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
          path = java8_home or '/usr/lib/jvm/java-8-openjdk/',
          default = true,
        },
        {
          name = 'JavaSE-17',
          path = java17_home or '/usr/lib/jvm/java-17-openjdk/',
        },
        {
          name = 'JavaSE-21',
          path = java21_home or '/usr/lib/jvm/java-21-openjdk/',
        },
      },
    },
  },
}

return M
