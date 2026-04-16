# wenvim
### wenjinnn's neovim configuration, basically a distribution of [mini.nvim](https://github.com/nvim-mini/mini.nvim)

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
* AI powered by [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) and [Github Copilot](https://github.com/features/copilot).

> [!NOTE]
> * This configuration only guaranteed to be compatible with the nightly version.
> * I'm not using mason.nvim now, The LSP package should managed by you own system.
> * To get all the custom keymap clue you need, just press `space`.

## Installation Instructions

> Installation requires Neovim 0.11+. Always review the code before installing a configuration.

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

* `ss` in normal mode will trigger mini.jump2d motion `MiniJump2d.builtin_opts.single_character`
* `sq` in normal mode will trigger mini.jump2d motion `MiniJump2d.builtin_opts.query`
* if you login to Copilot, `<M-CR>` in insert mode will accept Copilot suggestion.

## Directory notes

[plugin/](plugin) Custom configurations for plugins, keymaps and options.

[lua/wenvim/lsp.lua](lua/wenvim/lsp.lua) LSP event handlers like `on_attach` and `on_detach`.

[lua/wenvim/util.lua](lua/wenvim/util.lua) Common utility functions.

[after/](after) Filetype-specific settings and LSP server configurations.

[colors/](colors) Custom color schemes based on [mini.hues](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-hues.md).

## Defined environment variables cheatsheets:

### Java

`JAVA_HOME` fallback java home

`JAVA8_HOME` java 8 home

`JAVA17_HOME` java 17 home

`JAVA21_HOME` java 21 home

`JDTLS_MAVEN_SETTINGS`  jdtls maven user settings.xml path

`JAVA_TEST_PATH` path to [vscode-java-test](https://github.com/microsoft/vscode-java-test) jars

`JAVA_DEBUG_PATH` path to [vscode-java-debug](https://github.com/microsoft/vscode-java-debug) jars

`LOMBOK_PATH` path to [lombok](https://projectlombok.org/) java agent jar

`JDTLS_XMX` jdtls xmx jvm arg value

`JDTLS_DAP_VMARGS` jdtls dap vm args

### AI
`NVIM_AI_ADAPTER` default AI adapter for CodeCompanion.nvim (e.g., `copilot`, `ollama`).

`NVIM_OLLAMA_MODEL` default model for ollama adapter.

`NVIM_OPENROUTER_MODEL` default model for openrouter adapter.

### Vue

`VUE_LANGUAGE_SERVER_PATH` path to vue language server

### Note taking
`NOTE` note directory path for obsidian

### Must have
1. [ripgrep](https://github.com/BurntSushi/ripgrep) depend by many plugin.
2. All the LSP package that configured in [plugin/lspconfig.lua](plugin/lspconfig.lua), if you're going to use these.
3. Linters and formatters that you want to use for conform.nvim and nvim-lint, you may also need to configure them in [plugin/editing.lua](plugin/editing.lua)

### Recommend
1. [tmux](https://github.com/tmux/tmux) for terminal multiplexing.
2. [lazygit](https://github.com/jesseduffield/lazygit) smooth git operation.

## Plugins

### core
+ [echasnovski/mini.nvim](https://github.com/echasnovski/mini.nvim) - The heart of this configuration.

### AI
+ [olimorris/codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)
+ [ravitemer/codecompanion-history.nvim](https://github.com/ravitemer/codecompanion-history.nvim)

### comment and annotation
+ [danymat/neogen](https://github.com/danymat/neogen)

### database
+ [tpope/vim-dadbod](https://github.com/tpope/vim-dadbod)
+ [kristijanhusak/vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion)

### debugging

+ [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap)
+ [mfussenegger/nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)
+ [jbyuki/one-small-step-for-vimkind](https://github.com/jbyuki/one-small-step-for-vimkind)

### VCS

+ [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)

### formatting

+ [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)

### lsp

+ [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
+ [b0o/SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim)
+ [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint)
+ [mfussenegger/nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls)

### preview

+ [barrettruth/preview.nvim](https://github.com/barrettruth/preview.nvim)

### note-taking

+ [obsidian-nvim/obsidian.nvim](https://github.com/obsidian-nvim/obsidian.nvim)
+ [jbyuki/venn.nvim](https://github.com/jbyuki/venn.nvim)

### runner

+ [kassio/neoterm](https://github.com/kassio/neoterm)
+ [tpope/vim-dispatch](https://github.com/tpope/vim-dispatch)
+ [vim-test/vim-test](https://github.com/vim-test/vim-test)

### snippet

+ [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
+ [chrisgrieser/nvim-scissors](https://github.com/chrisgrieser/nvim-scissors)

### syntax

+ [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
+ [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
+ [nvim-treesitter/nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context)
+ [hiphish/rainbow-delimiters.nvim](https://github.com/hiphish/rainbow-delimiters.nvim)

### utility

+ [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
+ [tpope/vim-speeddating](https://github.com/tpope/vim-speeddating)
+ [oysandvik94/curl.nvim](https://github.com/oysandvik94/curl.nvim)

Part of this readme was generated by [Dotfyle](https://dotfyle.com)
