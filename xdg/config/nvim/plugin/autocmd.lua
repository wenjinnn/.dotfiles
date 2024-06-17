local function augroup(name)
  return vim.api.nvim_create_augroup("wenvim_" .. name, { clear = true })
end
local au = vim.api.nvim_create_autocmd

-- Check if we need to reload the file when it changed
au({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank, already include in mini.basic
-- autocmd("TextYankPost", {
--   group = augroup("highlight_yank"),
--   callback = function()
--     vim.highlight.on_yank()
--   end,
-- })

-- resize splits if window got resized
au({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer
au("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].wenvim_last_loc then
      return
    end
    vim.b[buf].wenvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- wrap and check for spell in text filetypes
-- autocmd("FileType", {
--   group = augroup("wrap_spell"),
--   pattern = { "gitcommit", "markdown" },
--   callback = function()
--     vim.opt_local.wrap = true
--     vim.opt_local.spell = true
--   end,
-- })

-- Fix conceallevel for json files
au({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
au({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- close some filetypes with <q>
au("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "dap-float",
    "dap-repl",
    "man",
    "notify",
    "qf",
    "query",
    "git",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "checkhealth",
    "httpResult",
    "dbout",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- wrap vim diff buffer
au({ "VimEnter" }, {
  group = augroup("vim_enter"),
  pattern = "*",
  callback = function(event)
    if vim.o.diff then
      vim.wo.wrap = true
    end
  end,
})

-- auto update when BufLeave
au("BufLeave", {
  pattern = "*",
  callback = function()
    local buffer_readable = vim.fn.filereadable(vim.fn.bufname("%")) > 0
    if not vim.bo.readonly and buffer_readable then
      vim.cmd("update")
    end
  end,
})

-- fcitx5 rime auto switch to asciimode
if vim.fn.has("fcitx5") then
  au({ "InsertLeave" }, {
    group = augroup("fcitx5_rime"),
    pattern = "*",
    callback = function(event)
      vim.cmd(
        "silent call system('busctl call --user org.fcitx.Fcitx5 /rime org.fcitx.Fcitx.Rime1 SetAsciiMode b 1')"
      )
    end,
  })
end

-- sync wsl clipboard
if vim.fn.has("wsl") then
  au({ "TextYankPost" }, {
    group = augroup("wsl_yank"),
    pattern = "*",
    callback = function(event)
      vim.cmd("call system('/mnt/c/windows/system32/clip.exe ',@\")")
    end,
  })
end

-- force commentstring to include spaces
au({ "CursorHold", "FileType" }, {
  desc = "Force commentstring to include spaces",
  group = augroup("commentstring_spaces"),
  callback = function(event)
    local cs = vim.bo[event.buf].commentstring
    vim.bo[event.buf].commentstring = cs:gsub("(%S)%%s", "%1 %%s"):gsub("%%s(%S)", "%%s %1")
  end,
})

-- Copy/Paste when using ssh on a remote server
-- Only works on Neovim >= 0.10.0
if vim.clipboard and vim.clipboard.osc52 then
  au("VimEnter", {
    group = augroup("ssh_clipboard"),
    callback = function()
      if vim.env.SSH_CONNECTION and vim.clipboard.osc52 then
        vim.g.clipboard = {
          name = "OSC 52",
          copy = {
            ["+"] = require("vim.clipboard.osc52").copy,
            ["*"] = require("vim.clipboard.osc52").copy,
          },
          paste = {
            ["+"] = require("vim.clipboard.osc52").paste,
            ["*"] = require("vim.clipboard.osc52").paste,
          },
        }
      end
    end,
  })
end

-- auto change root
au("BufEnter", {
  callback = function(ctx)
    local root = vim.fs.root(ctx.buf, { ".git", ".svn", "Makefile", "mvnw", "package.json" })
    if root and root ~= "." and root ~= vim.fn.getcwd() then
      vim.cmd.cd(root)
      vim.notify("Set CWD to " .. root)
    end
  end,
})

au({ "InsertLeave" }, {
  desc = "set relativenumber",
  group = augroup("set_relativenumber"),
  pattern = "*.*",
  command = "set relativenumber",
})

au({ "InsertEnter" }, {
  desc = "set number",
  group = augroup("set_number"),
  pattern = "*",
  command = "set number norelativenumber",
})
