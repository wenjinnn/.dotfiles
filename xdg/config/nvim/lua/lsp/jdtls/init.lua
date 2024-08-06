local M = {}
local lsp = require("util.lsp")

function M.setup_dap()
  require("jdtls").setup_dap()
  require("jdtls.dap").setup_dap_main_class_configs({
    config_overrides = { vmArgs = "-Xms128m -Xmx512m" },
  })
  local dap = require("dap")
  -- for all launch.json options see https://github.com/microsoft/vscode-java-debug#options
  require("dap.ext.vscode").load_launchjs()
  local project_name = os.getenv("PROJECT_NAME")
  local host_name = os.getenv("DAP_HOST")
  local host_port = os.getenv("DAP_HOST_PORT")
  if project_name then
    dap.configurations.java = {
      {
        type = "java",
        request = "attach",
        projectName = project_name or nil,
        name = "Java attach: " .. project_name,
        hostName = host_name or "127.0.0.1",
        port = host_port or 5005,
      },
    }
  end
end

function M.setup_jdtls_buf_keymap(bufnr)
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>cC",
    "<cmd>JdtCompile full<CR>",
    { desc = "Jdt compile full" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>cc",
    "<cmd>JdtCompile incremental<CR>",
    { desc = "Jdt compile incremental" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>cu",
    "<cmd>JdtUpdateHotcode<CR>",
    { desc = "Jdt update hotcode" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>cg",
    "<cmd>lua require('jdtls.tests').generate()<CR>",
    { desc = "Jdt test generate" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>co",
    "<Cmd>lua require('jdtls').organize_imports()<CR>",
    { desc = "Jdt Organize Imports" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>cv",
    "<Cmd>lua require('jdtls').extract_variable()<CR>",
    { desc = "Jdt Extract Variable" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "v",
    "<leader>cv",
    "<Cmd>lua require('jdtls').extract_variable(true)<CR>",
    { desc = "Jdt Extract Variable" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>cV",
    "<Cmd>lua require('jdtls').extract_constant()<CR>",
    { noremap = true, silent = true, desc = "Jdt Extract Constant" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "v",
    "<leader>cV",
    "<Cmd>lua require('jdtls').extract_constant(true)<CR>",
    { noremap = true, silent = true, desc = "Jdt Extract Constant" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "v",
    "<leader>cm",
    "<Cmd>lua require('jdtls').extract_method(true)<CR>",
    { noremap = true, silent = true, desc = "Jdt Extract Method" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>cT",
    '<cmd>lua require("jdtls.tests").goto_subjects()<CR>',
    { desc = "Jdt Test Goto Subjects" }
  )
  -- If using nvim-dap
  -- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>da",
    "<Cmd>lua require('jdtls').test_class()<CR>",
    { noremap = true, silent = true, desc = "Jdt Test Class" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>dm",
    "<Cmd>lua require('jdtls').test_nearest_method()<CR>",
    { noremap = true, silent = true, desc = "Jdt Test Method" }
  )
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
    vim.split((vim.fn.glob((os.getenv("JAVA_TEST_PATH") or jdtls_data_path) .. "/server/*.jar")), "\n")
  )

  local jdtls_cache_path = vim.fn.stdpath("cache") .. "/jdtls"
  local lombok_path = os.getenv("LOMBOK_PATH") or jdtls_cache_path
  local config = {
    settings = require("lsp.jdtls.settings"),
    capabilities = lsp.make_capabilities(),
    on_attach = on_attach,
    name = "jdtls",
    filetypes = { "java" },
    init_options = {
      bundles = bundles,
    },
    cmd = {
      "jdtls",
      "--jvm-arg=-Dlog.protocol=true",
      "--jvm-arg=-Dlog.level=ALL",
      "--jvm-arg=-Dfile.encoding=utf-8",
      "--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false",
      "--jvm-arg=-Xmx1G",
      -- The following 6 lines is for optimize memory use, see https://github.com/redhat-developer/vscode-java/pull/1262#discussion_r386912240
      "--jvm-arg=-XX:+UseParallelGC",
      "--jvm-arg=-XX:MinHeapFreeRatio=5",
      "--jvm-arg=-XX:MaxHeapFreeRatio=10",
      "--jvm-arg=-XX:GCTimeRatio=4",
      "--jvm-arg=-XX:AdaptiveSizePolicyWeight=90",
      "--jvm-arg=-Dsun.zip.disableMemoryMapping=true",
      "--jvm-arg=-javaagent:" .. lombok_path .. "/lombok.jar",
      "-configuration",
      jdtls_cache_path .. "/config",
      "-data",
      jdtls_cache_path .. "/workspace/" .. workspace_name,
    },
  }

  -- Server
  require("jdtls").start_or_attach(config)
end

function M.setup()
  vim.api.nvim_create_augroup("user_jdtls_setup", { clear = true })
  vim.api.nvim_create_autocmd(
    { "FileType" },
    {
      group = "user_jdtls_setup",
      pattern = "java",
      callback = M.start,
    }
  )
end

return M
