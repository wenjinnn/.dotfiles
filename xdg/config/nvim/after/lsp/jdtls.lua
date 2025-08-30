local root_dir = vim.fs.root(0, { 'mvnw', 'gradlew', '.git', '.svn' })
local ws_name, _ = string.gsub(vim.fn.fnamemodify(root_dir, ':p'), '/', '_')

local bundles = { vim.fn.glob(vim.env.JAVA_DEBUG_PATH .. '/server/com.microsoft.java.debug.plugin-*.jar') }
local test_bundles = vim.split(vim.fn.glob(vim.env.JAVA_TEST_PATH .. '/server/*.jar', true), '\n')
local excluded = {
  'com.microsoft.java.test.runner-jar-with-dependencies.jar',
  'jacocoagent.jar',
}
for _, java_test_jar in ipairs(test_bundles) do
  local fname = vim.fn.fnamemodify(java_test_jar, ':t')
  if not vim.tbl_contains(excluded, fname) then table.insert(bundles, java_test_jar) end
end

local jdtls_cache_path = vim.fn.stdpath('cache') .. '/jdtls'
local lombok_path = vim.env.LOMBOK_PATH
return {
  settings = {
    java = {
      settings = { url = vim.fn.stdpath('config') .. '/lsp/jdtls.settings.prefs' },
      eclipse = { downloadSources = true },
      symbols = { includeSourceMethodDeclarations = true },
      selectionRange = { enabled = true },
      format = {
        enabled = true,
        comments = { enabled = false },
        onType = { enabled = false },
      },
      maxConcurrentBuilds = 5,
      saveActions = { organizeImports = false },
      referencesCodeLens = { enabled = true },
      implementationCodeLens = 'all',
      signatureHelp = {
        enabled = true,
        description = { enabled = true },
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
          userSettings = vim.env.JDTLS_MAVEN_SETTINGS or vim.env.HOME .. '/.m2/settings.xml',
        },
        runtimes = {
          {
            name = 'JavaSE-1.8',
            path = vim.env.JAVA8_HOME or '/usr/lib/jvm/java-8-openjdk/',
            default = true,
          },
          {
            name = 'JavaSE-17',
            path = vim.env.JAVA17_HOME or '/usr/lib/jvm/java-17-openjdk/',
          },
          {
            name = 'JavaSE-21',
            path = vim.env.JAVA21_HOME or '/usr/lib/jvm/java-21-openjdk/',
          },
        },
      },
    },
  },
  root_dir = root_dir,
  on_attach = function(client, bufnr)
    -- setup keymaps
    local jdtls = require('jdtls')
    local map = require('wenvim.util').buf_map(bufnr)
    local jdtls_tests = require('jdtls.tests')
    map('n', '<leader>cC', '<cmd>JdtCompile full<CR>', 'Jdt compile full')
    map('n', '<leader>cc', '<cmd>JdtCompile incremental<CR>', 'Jdt compile incremental')
    map('n', '<leader>cu', '<cmd>JdtUpdateHotcode<CR>', 'Jdt update hotcode')
    map('n', '<leader>cg', jdtls_tests.generate, 'Jdt test generate')
    map('n', '<leader>co', jdtls.organize_imports, 'Jdt Organize Imports')
    map('n', '<leader>cv', jdtls.extract_variable, 'Jdt Extract Variable')
    map('n', '<leader>cT', jdtls_tests.goto_subjects, 'Jdt Test Goto Subjects')
    -- If using nvim-dap
    -- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
    map('n', '<leader>da', jdtls.test_class, 'Jdt Test Class')
    map('n', '<leader>dm', jdtls.test_nearest_method, 'Jdt Test Method')
    map('n', '<leader>cV', jdtls.extract_constant, 'Jdt Extract Constant')
    map('v', '<leader>cv', function() jdtls.extract_variable(true) end, 'Jdt Extract Variable')
    map('v', '<leader>cV', function() jdtls.extract_constant(true) end, 'Jdt Extract Constant')
    map('v', '<leader>ce', function() jdtls.extract_method(true) end, 'Jdt Extract Method')
    -- setup dap
    require('jdtls.dap').setup_dap_main_class_configs({
      config_overrides = { vmArgs = vim.env.JDTLS_DAP_VMARGS or '-Xms128m -Xmx512m' },
    })
    -- for all launch.json options see https://github.com/microsoft/vscode-java-debug#options
    require('dap.ext.vscode').load_launchjs()
  end,
  init_options = {
    bundles = bundles,
  },
  handlers = {
    -- filter noisy notifications
    ['$/progress'] = function(err, result, ctx)
      local msg = result.value.message
      if msg and msg:sub(1, 18) == 'Validate documents' then return end
      if msg and msg:sub(1, 19) == 'Publish Diagnostics' then return end
      -- pass through to normal handler
      vim.lsp.handlers['$/progress'](err, result, ctx)
    end,
  },
  cmd = {
    'jdtls',
    -- The following 6 lines is for optimize memory use, see https://github.com/redhat-developer/vscode-java/pull/1262#discussion_r386912240
    '--jvm-arg=-XX:+UseParallelGC',
    '--jvm-arg=-XX:MinHeapFreeRatio=5',
    '--jvm-arg=-XX:MaxHeapFreeRatio=10',
    '--jvm-arg=-XX:GCTimeRatio=4',
    '--jvm-arg=-XX:AdaptiveSizePolicyWeight=90',
    '--jvm-arg=-Dsun.zip.disableMemoryMapping=true',
    '--jvm-arg=-Dlog.protocol=true',
    '--jvm-arg=-Dlog.level=ALL',
    '--jvm-arg=-Dfile.encoding=utf-8',
    '--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false',
    '--jvm-arg=-Xms256m',
    '--jvm-arg=-Xmx' .. (vim.env.JDTLS_XMX or '1G'),
    lombok_path ~= nil and string.format('--jvm-arg=-javaagent:%s/lombok.jar', lombok_path) or '',
    '-configuration',
    jdtls_cache_path .. '/config',
    '-data',
    jdtls_cache_path .. '/workspace/' .. ws_name,
  },
}
