" File: plugin/possession.vim
" Maintainer: Robertus Diawan Chris <https://github.com/bruhtus>
" License:
" Copyright (c) Robertus Diawan Chris. Distributed under the same terms as Vim itself.
" See :h license
"
" Description:
" decoupled vim session management with git root and branch support

if exists('g:loaded_possession') || v:version < 700 || &cp
  finish
endif

let g:loaded_possession = 1

let g:possession_dir = get(g:, 'possession_dir',
      \ has('nvim-0.3.1') ?
      \ stdpath('data') . '/session' :
      \ has('nvim') ?
      \ '~/.local/share/nvim/session' :
      \ '~/.vim/session'
      \ )

let g:possession_git_root = !get(g:, 'possession_no_git_root') ?
      \ fnamemodify(finddir('.git', escape(expand('%:p:h'), ' ') . ';'), ':h') :
      \ getcwd()

let g:possession_git_branch = !get(g:, 'possession_no_git_branch') ?
      \ trim(system("git branch --show-current 2>/dev/null")) :
      \ ''

let g:possession_file_pattern = g:possession_dir . '/' . substitute(
      \ fnamemodify(g:possession_git_root, ':~:.'), '[\~\.\/]', '%', 'g'
      \ ) . (g:possession_git_branch !=# '' ? '%' . g:possession_git_branch : '')

" TODO: need to simplify this
let replace_first_percentage = map(globpath(g:possession_dir, '%%*', 0, 1), {-> substitute(v:val, '^.*[/\\]%', '\~', '')})
let g:possession_list = map(
      \ map(replace_first_percentage,
      \   {-> substitute(v:val, '^\~%%', '\~%.', '')}),
      \ {-> substitute(v:val, '%', '\/', 'g')}
      \ )

command! -bang Possess
      \ call possession#init(<bang>0) |
      \ let replace_first_percentage = map(globpath(g:possession_dir, '%%*', 0, 1), {-> substitute(v:val, '^.*[/\\]%', '\~', '')}) |
      \ let g:possession_list = map(
      \   map(replace_first_percentage,
      \     {-> substitute(v:val, '^\~%%', '\~%.', '')}),
      \   {-> substitute(v:val, '%', '\/', 'g')}
      \   )

command! PLoad call s:possession_load()

command! PList echo join(g:possession_list, "\n")

function! s:possession_load()
  let file = g:possession_file_pattern
  if empty(v:this_session) && filereadable(file) && !&modified
    exe 'source ' . fnameescape(file)
    let g:current_possession = v:this_session
    if bufexists(0) && !filereadable(bufname('#'))
      bw #
    endif
  elseif !empty(v:this_session)
    echo 'There is another session going on'
  elseif &modified
    echo 'Please save the current buffer first'
  endif
endfunction

augroup possession
  autocmd!
  autocmd VimLeavePre * call possession#persist()
augroup END
