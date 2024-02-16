if exists('g:started_by_firenvim')
  let g:auto_session_enabled = v:false
endif
let g:db_ui_winwidth = 30

let g:vim_dadbod_completion_mark = ''
let g:db_ui_save_location = '~/.local/share/nvim/db_ui_queries'

let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
let g:firenvim_config = { 
    \ 'globalSettings': {
        \ 'alt': 'all',
    \  },
    \ 'localSettings': {
        \ '.*': {
            \ 'cmdline': 'neovim',
            \ 'content': 'text',
            \ 'priority': 0,
            \ 'selector': 'textarea',
            \ 'takeover': 'always',
        \ },
    \ }
    \ }
let fc = g:firenvim_config['localSettings']
let fc['.*'] = { 'takeover': 'never' }

let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {'theme':'dark'},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0,
    \ 'toc': {}
    \ }
