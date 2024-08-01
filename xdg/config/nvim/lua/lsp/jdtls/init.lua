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
      "<leader>cc",
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

function M.setup()
  local on_attach = function(client, bufnr)
    M.setup_dap()
    M.setup_jdtls_buf_keymap(bufnr)
    lsp.setup(client, bufnr)
  end
  local root_dir = require("jdtls.setup").find_root({ "mvnw", "gradlew", ".mvn", ".git", ".svn" })
  local workspace_name, _ = string.gsub(vim.fn.fnamemodify(root_dir, ":p"), "/", "_")
  local mason_pkg_path = lsp.get_mason_pkg_path()
  local jdtls_path = mason_pkg_path .. "/jdtls"
  local config_path = vim.fn.stdpath("config") .. "/lua/lsp/jdtls"

  local bundles = {
    vim.fn.glob(
      mason_pkg_path .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
    ),
  }
  vim.list_extend(
    bundles,
    vim.split(vim.fn.glob(mason_pkg_path .. "/vscode-java-decompiler/server/*.jar"), "\n")
  )
  vim.list_extend(
    bundles,
    vim.split(vim.fn.glob(mason_pkg_path .. "/java-test/extension/server/*.jar"), "\n")
  )
  -- TODO implement vscode-java-dependency for nvim
  -- vim.list_extend(
  --   bundles,
  --   vim.split(vim.fn.glob(config_path .. "/vscode-java-dependency/server/*.jar"), "\n")
  -- )

  local jdtls_java_home = os.getenv("JDTLS_JAVA_HOME")
  local java_cmd = "java"
  if jdtls_java_home then
    java_cmd = jdtls_java_home .. "/bin/java"
  end
  local config = {
    settings = require("lsp.jdtls.settings"),
    capabilities = lsp.make_capabilities(),
    on_attach = on_attach,
    name = "jdtls",
    filetypes = { "java", "xml", "gradle", "groovy" },
    init_options = {
      bundles = bundles,
    },
    cmd = {
      java_cmd,
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Dfile.encoding=utf-8",
      "-Djava.import.generatesMetadataFilesAtProjectRoot=false",
      "-Xms256m",
      "-Xmx1G",
      -- The following 6 lines is for optimize memory use, see https://github.com/redhat-developer/vscode-java/pull/1262#discussion_r386912240
      "-XX:+UseParallelGC",
      "-XX:MinHeapFreeRatio=5",
      "-XX:MaxHeapFreeRatio=10",
      "-XX:GCTimeRatio=4",
      "-XX:AdaptiveSizePolicyWeight=90",
      "-Dsun.zip.disableMemoryMapping=true",
      "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",
      "-javaagent:" .. jdtls_path .. "/lombok.jar",
      "-jar",
      vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
      "-configuration",
      jdtls_path .. "/config_linux",
      "-data",
      jdtls_path .. "/workspace/" .. workspace_name,
    },
  }

  -- Server
  require("jdtls").start_or_attach(config)
end

return M
