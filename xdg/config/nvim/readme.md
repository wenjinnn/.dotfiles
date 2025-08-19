
# wenvim
### wenjinnn's neovim configuration

<a href="https://dotfyle.com/wenjinnn/dotfiles-xdg-config-nvim"><img src="https://dotfyle.com/wenjinnn/dotfiles-xdg-config-nvim/badges/plugins?style=flat" /></a>
<a href="https://dotfyle.com/wenjinnn/dotfiles-xdg-config-nvim"><img src="https://dotfyle.com/wenjinnn/dotfiles-xdg-config-nvim/badges/leaderkey?style=flat" /></a>
<a href="https://dotfyle.com/wenjinnn/dotfiles-xdg-config-nvim"><img src="https://dotfyle.com/wenjinnn/dotfiles-xdg-config-nvim/badges/plugin-manager?style=flat" /></a>

# Screenshots
| | | | |
| :--------------: | :--------------: | :--------------: | :--------------: |
| ![starter](https://github.com/user-attachments/assets/736dae00-311e-44c1-8840-a33fd6fd1b53 "starter") | ![auto completion](https://github.com/user-attachments/assets/e4996800-da09-47bd-85f5-86f44b847ba8 "auto completion") | ![mini.deps](https://github.com/user-attachments/assets/1db44925-8d78-45de-aa15-50f28338a19a "mini.deps") | ![key clue](https://github.com/user-attachments/assets/9c73e035-87f4-4be9-b973-639b9690ded3 "key clue") |
| ![HTTP request](https://github.com/user-attachments/assets/34a03fc4-f8fb-47db-96d0-d0c7f671058f "HTTP request with hurl") | ![pick anything](https://github.com/user-attachments/assets/57d9064a-3630-472d-bf22-28fef9be5619 "pick anything") | ![DAP integration](https://github.com/user-attachments/assets/9b773251-ea74-4b8b-9172-35f52e74da98 "DAP integration") | ![file explorer](https://github.com/user-attachments/assets/9f1ae398-21fd-4d70-a3bf-92f5f0b3d69b "file explorer") |
 | ![LSP process and notify](https://github.com/user-attachments/assets/25a624d2-c080-4cda-b45c-3e3af8499563 "LSP process and notify") | ![code action](https://github.com/user-attachments/assets/c3fb3dc8-233c-4f07-9392-c0c3dedc8825 "code action") | ![LSP jump to](https://github.com/user-attachments/assets/cf15f776-ae51-424d-b456-7254392be4dd "LSP jump to") | ![LSP symbol](https://github.com/user-attachments/assets/93bf429d-f9fc-4681-96ac-0cfed750c51d "LSP symbol") |


## Principle and Goal

* Simple, yet powerful, always on develop.
* Lazy load all plugins if it could, to optimize startup time to the shortest possible time, right now on my PC, the startup time are less then 30ms.
* Avoid sidebar, focus on editing. personally, I prefer to use float window, sidebar buffer just distract me a lot.
* Avoid extra UI plugins. In common scenarios, [mini.notify](https://github.com/echasnovski/mini.notify) and [mini.pick](https://github.com/echasnovski/mini.pick) with `vim.ui.select()` wrapper already done well enough for notify and float window.
* Provide out-of-box experience for web development.
* AI powered by Github copilot, for AI agentic, I'm using [opencode](https://github.com/sst/opencode).

> [!NOTE]
> * This configuration only guaranteed to be compatible with the latest stable version.
> * I'm not using mason.nvim now, The LSP package should managed by you own system.
> you need to setup your own api key in [lua/plugin/extra.lua](lua/plugin/extra.lua#L198).
> * To get all the custom keymap clue you need, just press `space`.

## Installation Instructions

> Installation requires Neovim 0.10+. Always review the code before installing a configuration.

Clone the repository and install the plugins:

```sh
git clone git@github.com:wenjinnn/wenvim ~/.config/wenjinnn/wenvim
```

Open Neovim with this config:

```sh
NVIM_APPNAME=wenjinnn/wenvim nvim
```

## Special notes

Some behavior are not common in this configuration, but it's reasonable in my opinion:

* `sj` in normal mode will trigger mini.jump2d motion `MiniJump2d.builtin_opts.default`
* `ss` in normal mode will trigger mini.jump2d motion `MiniJump2d.builtin_opts.single_character`
* `sq` in normal mode will trigger mini.jump2d motion `MiniJump2d.builtin_opts.query`
* if you login to Copilot, `<M-CR>` in insert mode will accept Copilot suggestion.

## Directory notes

[plugin](plugin) vim custom autocmd keymap option and more

[lsp](./lsp)
Custom LSP config and settings

[lua/lsp](lua/lsp)
Some LSP that didn't depends on neovim built-in lsp-config like jdtls

[lua/plugin](lua/plugin)
plugins with particular settings and keymap

[lua/util](lua/util)
common utils

[after](after)
just some filetype settings

## Defined environment variables cheatsheets:

### Java

`JAVA_HOME` fallback java home

`JAVA8_HOME` java 8 home

`JAVA17_HOME` java 17 home

`JAVA21_HOME` java 21 home

`JDTLS_MAVEN_SETTINGS`  jdtls maven user settings.xml path

`JDTLS_JAVA_HOME` jdtls java home, if not set, fallback to `JAVA_21_HOME`

`JAVA_TEST_PATH` path to [vscode-java-test](https://github.com/microsoft/vscode-java-test) jars

`JAVA_DEBUG_PATH` path to [vscode-java-debug](https://github.com/microsoft/vscode-java-debug) jars

`LOMBOK_PATH` path to [lombok](https://projectlombok.org/) java agent jar

`JDTLS_XMX` jdtls xmx jvm arg value

`JDTLS_DAP_VMARGS` jdtls dap vm args

### Sonarlint
`SONARLINT_PATH` path to sonarlint language server jars

### Vue

`VUE_LANGUAGE_SERVER_PATH` path to vue language server

### Note taking
`NOTE` note directory path for obsidian

### Must have
1. [ripgrep](https://github.com/BurntSushi/ripgrep) depend by many plugin.
2. All the LSP package that configured in [lua/plugin/lspconfig.lua](lua/plugin/lspconfig.lua), if you're going to use these.

### Recommend
1. [tmux](https://github.com/tmux/tmux) for terminal multiplexing, I'm almost using it only in WSL.
2. [lazygit](https://github.com/jesseduffield/lazygit) smooth git operation.

## Plugins

### ai
+ [zbirenbaum/copilot.lua](https://github.com/zbirenbaum/copilot.lua)

### comment

+ [danymat/neogen](https://github.com/danymat/neogen)

### extra

+ [glacambre/firenvim](https://github.com/glacambre/firenvim)

### database
+ [tpope/vim-dadbod](https://github.com/tpope/vim-dadbod)

### debugging

+ [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap)
+ [mfussenegger/nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)
+ [theHamsta/nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text)
+ [jbyuki/one-small-step-for-vimkind](https://github.com/jbyuki/one-small-step-for-vimkind)

### VCS

+ [vim-fugitive](https://github.com/tpope/vim-fugitive)
+ [vim-flog](https://github.com/rbong/vim-flog)

### editing-support
+ [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag)
### formatting

+ [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)
### lsp

+ [b0o/SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim)
+ [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint)
+ [mfussenegger/nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)
+ [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
+ [schrieveslaach/sonarlint.nvim](https://gitlab.com/schrieveslaach/sonarlint.nvim)
### markdown-and-latex

+ [brianhuster/live-preview.nvim](https://github.com/brianhuster/live-preview.nvim)
### note-taking

+ [obsidian-nvim/obsidian.nvim](github.com/obsidian-nvim/obsidian.nvim)
+ [jbyuki/venn.nvim](https://github.com/jbyuki/venn.nvim)

### search

+ [MagicDuck/grug-far.nvim](https://github.com/MagicDuck/grug-far.nvim)
### snippet

+ [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
+ [chrisgrieser/nvim-scissors](https://github.com/chrisgrieser/nvim-scissors)
### syntax

+ [hiphish/rainbow-delimiters.nvim](https://github.com/hiphish/rainbow-delimiters.nvim)

+ [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
+ [nvim-treesitter/nvim-treesitter-context](https://https://github.com/nvim-treesitter/nvim-treesitter-context)
+ [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

### utility

+ [echasnovski/mini.nvim](https://github.com/echasnovski/mini.nvim)
### web-development

+ [mistweaverco/kulala.nvim](https://github.com/mistweaverco/kulala.nvim)

 Part of this readme was generated by [Dotfyle](https://dotfyle.com)
