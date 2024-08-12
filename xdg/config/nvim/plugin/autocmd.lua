local augroup = require("util").augroup
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

-- resize splits if window got resized
au({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
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

-- force commentstring to include spaces
au({ "CursorHold", "FileType" }, {
  desc = "Force commentstring to include spaces",
  group = augroup("commentstring_spaces"),
  callback = function(event)
    local cs = vim.bo[event.buf].commentstring
    vim.bo[event.buf].commentstring = cs:gsub("(%S)%%s", "%1 %%s"):gsub("%%s(%S)", "%%s %1")
  end,
})

-- Copy/Paste when using wsl
au("VimEnter", {
  group = augroup("clipboard"),
  callback = function()
    if vim.fn.has("wsl") ~= 0 then
      vim.g.clipboard = {
        name = "WslClipboard",
        copy = {
          ["+"] = "clip.exe",
          ["*"] = "clip.exe",
        },
        paste = {
          ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
          ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = 0,
      }
    end
  end,
})

-- terminal buffer specific options
au({ "TermEnter", "TermOpen" }, {
  group = augroup("terminal_buffer"),
  pattern = "*",
  callback = require("util").setup_term_opt,
})
