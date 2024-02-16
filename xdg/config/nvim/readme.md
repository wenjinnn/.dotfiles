### Personal nvim configuration

#### Directory function notes

`./plugin`  
vim custom autocmd keymap option and more

`./lua/lsp`  
LSP config

`./lua/plugin`  
plugins with settings

`./after`  
just some filetype and colorscheme settings

Support project environment setting by [direnv](https://github.com/direnv/direnv), to set project env, install direnv
and add `.envrc` file to project root path, put your special variables to it.
Language special env note:
#### java
JAVA_HOME  

JDTLS_MAVEN_SETTINGS -- jdtls user maven `settings.xml` location  

TELESCOPE_FILE_IGNORE_PATTERNS -- special file_ignore_patterns setting. see `:h file_ignore_patterns`  

#### recommend dependency and cmdline tool
1. install [ripgrep](https://github.com/BurntSushi/ripgrep) to your system, telescope depend on it.
3. recommend [tmux](https://github.com/tmux/tmux) & [oh-my-tmux](https://github.com/gpakosz/.tmux) to manage your terminal.
4. recommend [lazygit](https://github.com/jesseduffield/lazygit) to enhance git experience.

