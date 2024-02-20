nnoremap <silent> <M-h> <cmd>wincmd <<CR>
nnoremap <silent> <M-j> <cmd>wincmd +<CR>
nnoremap <silent> <M-k> <cmd>wincmd -<CR>
nnoremap <silent> <M-l> <cmd>wincmd ><CR>
noremap <silent> <M-n> :tabn<cr>
noremap <silent> <M-p> :tabp<cr>
" cnoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
" These commands will navigate through buffers in order regardless of which mode you are using
" e.g. if you change the order of buffers :bnext and :bprevious will not respect the custom ordering
" These commands will move the current buffer backwards or forwards in the bufferline
nnoremap <silent><c-n> <cmd>bn<CR>
nnoremap <silent><c-p> <cmd>bp<CR>
nnoremap <silent><leader>S <cmd>windo set scrollbind!<CR>
nnoremap <silent><leader>X <cmd>only<CR>
" nnoremap <silent><leader>a <cmd>Alpha<CR>
nnoremap <silent><leader><leader>b <c-^>

" copy to system clipboard
vmap <leader>y "+y

" paste to vim register
nnoremap <leader>p "+p
nnoremap <leader>0 "0p
vmap <leader>p "+p
vmap <leader>0 "0p

" Add undo break-points
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ; ;<c-g>u

nnoremap <silent> <leader>h <cmd>noh<CR>

nnoremap <leader>K <cmd>norm! K<CR>
nnoremap [q <cmd>cprev<CR>
nnoremap ]q <cmd>cnext<CR>


nnoremap <silent> <leader>q <cmd>copen<cr>

" source config
if !exists('*SourceMyConfig')
    function SourceMyConfig()
        let configs = split(glob('~/.config/nvim/plugin/*.vim'))
        call extend(configs, split(glob('~/.config/nvim/after/plugin/*.vim')))
        call extend(configs, split(glob('~/.config/nvim/after/ftplugin/*.vim')))
        " for f in split(glob(configs), '\n')
        for f in configs
            exe 'source' f
        endfor
        source $MYVIMRC
    endfunction
endif

nnoremap <silent> <leader>sc <cmd>call SourceMyConfig()<CR>
nnoremap <silent> <leader>u <cmd>Lazy update<CR>
nnoremap <silent> <leader>l <cmd>Lazy<CR>
nnoremap <silent> <leader>L <cmd>Mason<CR>

" ctags
nnoremap <silent> <leader>C <cmd>!ctags<CR>

let s:textdomain = $TEXTDOMAIN
if s:textdomain == 'git'
    nnoremap <silent> gl <cmd>diffget LO<CR>
    nnoremap <silent> gr <cmd>diffget RE<CR>
endif
if exists('g:vscode')
    nnoremap K <cmd>call VSCodeNotify('editor.action.showHover')<CR>
    nnoremap gd <cmd>call VSCodeNotify('editor.action.peekDefinition')<CR>
    nnoremap gD <cmd>call VSCodeNotify('editor.action.peekDeclaration')<CR>
    nnoremap gh <cmd>call VSCodeNotify('editor.action.showDefinitionPreviewHover')<CR>
    nnoremap gi <cmd>call VSCodeNotify('editor.action.goToImplementation')<CR>
    nnoremap gI <cmd>call VSCodeNotify('editor.showIncomingCalls')<CR>
    nnoremap gO <cmd>call VSCodeNotify('editor.showOutgoingCalls')<CR>
    nnoremap gr <cmd>call VSCodeNotify('editor.action.goToReferences')<CR>
    vnoremap <leader>tt <cmd>call VSCodeNotifyVisual('translates.translates', 1)<cr>
    nnoremap <leader>ff <cmd>call VSCodeNotify('workbench.action.quickOpen')<cr>
    nnoremap <leader>fg <cmd>call VSCodeNotify('workbench.view.search')<cr>
    nnoremap <leader>fb <cmd>call VSCodeNotify('workbench.action.quickOpenPreviousRecentlyUsedEditor')<CR>
    nnoremap <C-n> <cmd>call VSCodeNotify('workbench.action.quickOpenPreviousRecentlyUsedEditor')<CR>
    nnoremap <C-p> <cmd>call VSCodeNotify('workbench.action.quickOpenLeastRecentlyUsedEditor')<CR>
    nnoremap <leader>mm <cmd>call VSCodeNotify('editor.action.formatDocument')<CR>
    vnoremap <leader>mm <cmd>call VSCodeNotifyVisual('editor.action.formatSelection')<CR>
    nnoremap <leader>ca <cmd>call VSCodeNotify('editor.action.quickFix')<CR>
    vnoremap <leader>ca <cmd>call VSCodeNotifyVisual('editor.action.quickFix')<CR>
endif
