local M = {}
local lsp = require("util.lsp")
local jdtls = require("jdtls")
function M.setup_dap()
  jdtls.setup_dap()
  require("jdtls.dap").setup_dap_main_class_configs({
    config_overrides = { vmArgs = os.getenv("JDTLS_DAP_VMARGS") or "-Xms128m -Xmx512m" },
  })
  local dap = require("dap")
  -- for all launch.json options see https://github.com/microsoft/vscode-java-debug#options
  require("dap.ext.vscode").load_launchjs()
  local project_name = os.getenv("DAP_PROJECT_NAME")
  local host_name = os.getenv("DAP_HOST")
  local host_port = os.getenv("DAP_HOST_PORT") or 5005
  if host_name ~= nil then
    dap.configurations.java = {
      {
        type = "java",
        request = "attach",
        projectName = project_name or "",
        name = string.format("Java attach: %s:%s %s", host_name, host_port, project_name or ""),
        hostName = host_name,
        port = host_port,
      },
    }
  end
end

function M.setup_jdtls_buf_keymap(bufnr)
  local map = lsp.buf_map(bufnr)
  local jdtls_tests = require("jdtls.tests")
  map("n", "<leader>cC", "<cmd>JdtCompile full<CR>", "Jdt compile full")
  map("n", "<leader>cc", "<cmd>JdtCompile incremental<CR>", "Jdt compile incremental")
  map("n", "<leader>cu", "<cmd>JdtUpdateHotcode<CR>", "Jdt update hotcode")
  map("n", "<leader>cg", jdtls_tests.generate, "Jdt test generate")
  map("n", "<leader>co", jdtls.organize_imports, "Jdt Organize Imports")
  map("n", "<leader>cv", jdtls.extract_variable, "Jdt Extract Variable")
  map("n", "<leader>cT", jdtls_tests.goto_subjects, "Jdt Test Goto Subjects")
  -- If using nvim-dap
  -- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
  map("n", "<leader>da", jdtls.test_class, "Jdt Test Class")
  map("n", "<leader>dm", jdtls.test_nearest_method, "Jdt Test Method")
  map("n", "<leader>cV", jdtls.extract_constant, "Jdt Extract Constant")
  map("v", "<leader>cv", function() jdtls.extract_variable(true) end, "Jdt Extract Variable")
  map("v", "<leader>cV", function() jdtls.extract_constant(true) end, "Jdt Extract Constant")
  map("v", "<leader>ce", function() jdtls.extract_method(true) end, "Jdt Extract Method")
end

function M.start()
  local on_attach = function(client, bufnr)
    M.setup_dap()
    M.setup_jdtls_buf_keymap(bufnr)
    lsp.setup(client, bufnr)
  end
  local root_dir = vim.fs.root(0, { "mvnw", "gradlew", ".git", ".svn" })
  local ws_name, _ = string.gsub(vim.fn.fnamemodify(root_dir, ":p"), "/", "_")
  local jdtls_data_path = vim.fn.stdpath("data") .. "/jdtls"
  local jdtls_debug_path = os.getenv("JAVA_DEBUG_PATH") or jdtls_data_path
  local jdtls_test_path = os.getenv("JAVA_TEST_PATH") or jdtls_data_path
  local bundles = { vim.fn.glob(jdtls_debug_path .. "/server/com.microsoft.java.debug.plugin-*.jar") }
  local test_bundles = vim.split(vim.fn.glob(jdtls_test_path .. "/server/*.jar", true), "\n")
  vim.list_extend(bundles, test_bundles)
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
  local jdtls_cache_path = vim.fn.stdpath("cache") .. "/jdtls"
  local lombok_path = os.getenv("LOMBOK_PATH")
  local config = {
    settings = require("lsp.jdtls.settings"),
    capabilities = lsp.make_capabilities(),
    root_dir = root_dir,
    on_attach = on_attach,
    filetypes = { "java" },
    init_options = {
      bundles = bundles,
      extendedClientCapabilities = extendedClientCapabilities,
    },
    cmd = {
      "jdtls",
      "--jvm-arg=-Dlog.protocol=true",
      "--jvm-arg=-Dlog.level=ALL",
      "--jvm-arg=-Dfile.encoding=utf-8",
      "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false",
      "--jvm-arg=-Xms256m",
      "--jvm-arg=-Xmx" .. (os.getenv("JDTLS_XMX") or "1G"),
      -- The following 6 lines is for optimize memory use, see https://github.com/redhat-developer/vscode-java/pull/1262#discussion_r386912240
      "--jvm-arg=-XX:+UseParallelGC",
      "--jvm-arg=-XX:MinHeapFreeRatio=5",
      "--jvm-arg=-XX:MaxHeapFreeRatio=10",
      "--jvm-arg=-XX:GCTimeRatio=4",
      "--jvm-arg=-XX:AdaptiveSizePolicyWeight=90",
      "--jvm-arg=-Dsun.zip.disableMemoryMapping=true",
      lombok_path ~= nil and string.format("--jvm-arg=-javaagent:%s/lombok.jar", lombok_path) or "",
      "-configuration",
      jdtls_cache_path .. "/config",
      "-data",
      jdtls_cache_path .. "/workspace/" .. ws_name,
    },
  }

  -- Server
  jdtls.start_or_attach(config)
end

function M.setup()
  local jdtls_setup_group = require("util").augroup("jdtls_setup")
  vim.api.nvim_create_autocmd( { "FileType" },
    {
      group = jdtls_setup_group,
      pattern = "java",
      callback = M.start,
    }
  )
  require("spring_boot").setup()
end

return M
