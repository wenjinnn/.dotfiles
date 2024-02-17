" auto positioning to last edit position when open file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif
" auto format and save buffer, DiffFormat is a custom command from ../lua/plugin/editing.lua
function! FormatAndWrite() abort
    if &readonly==0 && filereadable(bufname('%')) && getbufinfo('%')[0].changed
        DiffFormat
        w
    endif
endfunction
au BufLeave * exec FormatAndWrite() 
" auto vimdiff wrap
au VimEnter * if &diff | execute 'windo set wrap' | endif
" nvim-dap repl completion
au FileType dap-repl lua require('dap.ext.autocompl').attach()
au FileType dap-float nnoremap <buffer> <silent> q <cmd>quit<CR>

" Auto generate tags file on file write of ctags supported languages file,
" Languages Supported by Exuberant Ctags: http://ctags.sourceforge.net/languages.html
" if executable('ctags') && getcwd() != getenv('HOME')
"     au BufWritePost,QuitPre *.c,*.h,*.asp,*.awk,*.cpp,*.cs,*.html,*.java,*.js,*.lua,makefile,*.sql,*.py,*.vim,*.yml,*.json,*.ts,*.go,*.properties,*.lisp silent! !ctags
" endif
autocmd User TelescopePreviewerLoaded setlocal wrap
autocmd User TelescopePreviewerLoaded setlocal number

" firenvim setting
function! s:IsFirenvimActive(event) abort
  if !exists('*nvim_get_chan_info')
    return 0
  endif
  let l:ui = nvim_get_chan_info(a:event.chan)
  return has_key(l:ui, 'client') && has_key(l:ui.client, 'name') &&
      \ l:ui.client.name =~? 'Firenvim'
endfunction

function! OnUIEnter(event) abort
  if s:IsFirenvimActive(a:event)
    " for 4k screen display
    " set guifont=FiraCode_Nerd_Font_Mono:h20
    " disable auto session
    let g:auto_session_enabled = v:false
  endif
endfunction
autocmd UIEnter * call OnUIEnter(deepcopy(v:event))

" fcitx5 rime
" Disable the input method when exiting insert mode and save the state
" 2 means that the input method was opened in the previous state, and the input method is started when entering the insert mode
autocmd InsertLeave * :silent call system("busctl call --user org.fcitx.Fcitx5 /rime org.fcitx.Fcitx.Rime1 SetAsciiMode b 1")

" sync wsl clipboard
if has('wsl')
  augroup Yank
  autocmd!
  autocmd TextYankPost * :call system('/mnt/c/windows/system32/clip.exe ',@")
  augroup END
endif
