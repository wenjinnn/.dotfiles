
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
* AI powered.

> [!NOTE]
> * This configuration only guaranteed to be compatible with the latest stable version.
> * I'm not using mason.nvim now, The LSP package should managed by you own system.
> * To make [olimorris/codecompanion.nvim](https://dotfyle.com/plugins/olimorris/codecompanion.nvim) work,
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

* `<CR>` in normal mode will trigger `MiniJump2d.query()`
* if you login to Copilot, `<M-CR>` in insert mode will accept Copilot suggestion.

## Directory notes

[plugin](plugin) vim custom autocmd keymap option and more

[lua/lsp](lua/lsp)
LSP config and settings
* define a key-value pair table at `<lspname>/init.lua`, attribute in table will autoload by particular lsp
* on_attach function in `<lspname>/init.lua` will auto execute by particular lsp, with a [setup warpper](https://github.com/wenjinnn/config/blob/e6188ed4f337fac55bd42280ccf1f3b1dd726964/xdg/config/nvim/lua/util/lsp.lua#L14C12-L34)

[lua/plugin](lua/plugin)
plugins with particular settings and keymap

[lua/util](lua/util)
common utils

[after](after)
just some filetype settings

## Defined environment variables cheatsheets:

### Dap

`DAP_PROJECT_NAME` nvim-dap config for dap configuration `projectName`

`DAP_HOST` nvim-dap config for setting host, most used at remote debug situations.

`DAP_HOST_PORT` like above, but for host port

### Java

`JAVA_HOME` fallback java home

`JAVA_8_HOME` java 8 home

`JAVA_17_HOME` java 17 home

`JAVA_21_HOME` java 21 home

`JDTLS_MAVEN_SETTINGS`  jdtls maven user settings.xml path

`JDTLS_JAVA_HOME` jdtls java home, if not set, fallback to `JAVA_21_HOME`

`JAVA_TEST_PATH` path to [vscode-java-test](https://github.com/microsoft/vscode-java-test) jars

`JAVA_DEBUG_PATH` path to [vscode-java-debug](https://github.com/microsoft/vscode-java-debug) jars

`SPRING_BOOT_TOOLS_PATH` path to [spring-boot-tools](https://marketplace.visualstudio.com/items?itemName=vmware.vscode-spring-boot) jars

`JAVA_DEPENDENCY_PATH` path to [vscode-java-dependency](https://github.com/microsoft/vscode-java-dependency) jars

`LOMBOK_PATH` path to [lombok](https://projectlombok.org/) java agent jar

`JDTLS_XMX` jdtls xmx jvm arg value

`JDTLS_DAP_VMARGS` jdtls dap vm args


### Sonarlint
`SONARLINT_PATH` path to sonarlint language server jars

### Vue

`VUE_LANGUAGE_SERVER_PATH` path to vue language server

### AI

`NVIM_AI_ADAPTER` ai adapter for codecompanion.nvim, default to `ollama`
`NVIM_OLLAMA_MODEL` ollama model to use for codecompanion.nvim, default to `llama3.2`

### Must have
1. [ripgrep](https://github.com/BurntSushi/ripgrep) depend by many plugin.
2. All the LSP package that configured in [lua/lsp/init.lua](lua/lsp/init.lua), if you're going to use.

### Recommend
1. [tmux](https://github.com/tmux/tmux) for terminal multiplexing, I'm almost using it only in WSL.
2. [lazygit](https://github.com/jesseduffield/lazygit) smooth git operation.

## Main Plugins

### ai

+ [olimorris/codecompanion.nvim](https://dotfyle.com/plugins/olimorris/codecompanion.nvim)
### code-runner

+ [michaelb/sniprun](https://dotfyle.com/plugins/michaelb/sniprun)
### comment

+ [danymat/neogen](https://dotfyle.com/plugins/danymat/neogen)
+ [JoosepAlviste/nvim-ts-context-commentstring](https://dotfyle.com/plugins/JoosepAlviste/nvim-ts-context-commentstring)
### debugging

+ [mfussenegger/nvim-dap](https://dotfyle.com/plugins/mfussenegger/nvim-dap)
+ [theHamsta/nvim-dap-virtual-text](https://dotfyle.com/plugins/theHamsta/nvim-dap-virtual-text)
### editing-support

+ [nvim-treesitter/nvim-treesitter-context](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter-context)
+ [windwp/nvim-ts-autotag](https://dotfyle.com/plugins/windwp/nvim-ts-autotag)
### formatting

+ [stevearc/conform.nvim](https://dotfyle.com/plugins/stevearc/conform.nvim)
### lsp

+ [b0o/SchemaStore.nvim](https://dotfyle.com/plugins/b0o/SchemaStore.nvim)
+ [mfussenegger/nvim-lint](https://dotfyle.com/plugins/mfussenegger/nvim-lint)
+ [mfussenegger/nvim-jdtls](https://dotfyle.com/plugins/mfussenegger/nvim-jdtls)
+ [neovim/nvim-lspconfig](https://dotfyle.com/plugins/neovim/nvim-lspconfig)
### markdown-and-latex

+ [iamcco/markdown-preview.nvim](https://dotfyle.com/plugins/iamcco/markdown-preview.nvim)
### note-taking

+ [nvim-orgmode/orgmode](https://dotfyle.com/plugins/nvim-orgmode/orgmode)
+ [chipsenkbeil/org-roam.nvim](https://dotfyle.com/plugins/chipsenkbeil/org-roam.nvim)
+ [jbyuki/venn.nvim](https://dotfyle.com/plugins/jbyuki/venn.nvim)
### nvim-dev

+ [nvim-lua/plenary.nvim](https://dotfyle.com/plugins/nvim-lua/plenary.nvim)
### search

+ [MagicDuck/grug-far.nvim](https://dotfyle.com/plugins/MagicDuck/grug-far.nvim)
### snippet

+ [rafamadriz/friendly-snippets](https://dotfyle.com/plugins/rafamadriz/friendly-snippets)
+ [chrisgrieser/nvim-scissors](https://dotfyle.com/plugins/chrisgrieser/nvim-scissors)
### syntax

+ [nvim-treesitter/nvim-treesitter-textobjects](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter-textobjects)
+ [nvim-treesitter/nvim-treesitter](https://dotfyle.com/plugins/nvim-treesitter/nvim-treesitter)
### utility

+ [echasnovski/mini.nvim](https://dotfyle.com/plugins/echasnovski/mini.nvim)
### web-development

+ [mistweaverco/kulala.nvim](https://dotfyle.com/plugins/mistweaverco/kulala.nvim)

 Part of this readme was generated by [Dotfyle](https://dotfyle.com)
