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
        projectName = project_name or nil,
        name = string.format("Java attach: %s:%s %s", host_name, host_port, project_name),
        hostName = host_name,
        port = host_port,
      },
    }
  end
end

function M.setup_jdtls_buf_keymap(bufnr)
  local map = lsp.buf_map(bufnr)
  map("<leader>cC", "<cmd>JdtCompile full<CR>", "Jdt compile full")
  map("<leader>cc", "<cmd>JdtCompile incremental<CR>", "Jdt compile incremental")
  map("<leader>cu", "<cmd>JdtUpdateHotcode<CR>", "Jdt update hotcode")
  map("<leader>cg", "<cmd>lua require'jdtls.tests'.generate()<cr>", "Jdt test generate")
  map("<leader>co", "<cmd>lua require'jdtls'.organize_imports()<cr>", "Jdt Organize Imports")
  map("<leader>cv", "<cmd>lua require'jdtls'.extract_variable()<cr>", "Jdt Extract Variable")
  map("<leader>cT", "<cmd>lua require'jdtls.tests'.goto_subjects()<cr>", "Jdt Test Goto Subjects")
  -- If using nvim-dap
  -- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
  map("<leader>da", "<cmd>lua require'jdtls'.test_class()<cr>", "Jdt Test Class")
  map("<leader>dm", "<cmd>lua require'jdtls'.test_nearest_method()<cr>", "Jdt Test Method")
  map("<leader>cV", "<cmd>lua require'jdtls'.extract_constant()<cr>", "Jdt Extract Constant")
  map("<leader>cv",
    "<cmd>lua require'jdtls'.extract_variable(true)<cr>",
    "Jdt Extract Variable",
    "v")
  map("<leader>cV",
    "<cmd>lua require'jdtls'.extract_constant(true)<cr>",
    "Jdt Extract Constant",
    "v")
  map(
    "<leader>cm",
    "<cmd>lua require'jdtls'.extract_method(true)<cr>",
    "Jdt Extract Method",
    "v")
end

function M.start()
  local on_attach = function(client, bufnr)
    M.setup_dap()
    M.setup_jdtls_buf_keymap(bufnr)
    lsp.setup(client, bufnr)
  end
  local root_dir = require("jdtls.setup").find_root({ "mvnw", "gradlew", ".mvn", ".git", ".svn" })
  local workspace_name, _ = string.gsub(vim.fn.fnamemodify(root_dir, ":p"), "/", "_")
  local jdtls_data_path = vim.fn.stdpath("data") .. "/jdtls"
  local bundles = {
    vim.fn.glob(
      (os.getenv("JAVA_DEBUG_PATH") or jdtls_data_path) .. "/server/com.microsoft.java.debug.plugin-*.jar"
    ),
  }
  vim.list_extend(
    bundles,
    vim.split(vim.fn.glob((os.getenv("JAVA_TEST_PATH") or jdtls_data_path) .. "/server/*.jar", true),
      "\n")
  )
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
  local jdtls_cache_path = vim.fn.stdpath("cache") .. "/jdtls"
  local lombok_path = os.getenv("LOMBOK_PATH")
  local config = {
    settings = require("lsp.jdtls.settings"),
    capabilities = lsp.make_capabilities(),
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
      jdtls_cache_path .. "/workspace/" .. workspace_name,
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
end

return M
