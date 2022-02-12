" File: plugin/possession.vim
" Maintainer: Robertus Diawan Chris <https://github.com/bruhtus>
" License:
" Copyright (c) Robertus Diawan Chris. Distributed under the same terms as Vim itself.
" See :h license
"
" Description:
" flexible vim session management with git root and branch support

if exists('g:loaded_possession') || v:version < 700 || &cp
  finish
endif

let g:loaded_possession = 1

let g:possession_window_name = get(g:, 'possession_window_name',
      \ 'possession')

let g:possession_dir = get(g:, 'possession_dir',
      \ has('nvim-0.3.1') ?
      \ stdpath('data') . '/session' :
      \ has('nvim') ?
      \ '~/.local/share/nvim/session' :
      \ '~/.vim/session'
      \ )

" Note: remove the last slice in directory path
let g:possession_git_root = !get(g:, 'possession_no_git_root') ?
      \ fnamemodify(
      \   trim(system('git rev-parse --show-toplevel 2>/dev/null')), ':p:s?\/$??'
      \ ) :
      \ getcwd()

let g:possession_git_branch = !get(g:, 'possession_no_git_branch') ?
      \ trim(system("git branch --show-current 2>/dev/null")) :
      \ ''

" Note: change `~`, `.`, and `/` in directory to `%`
let g:possession_file_pattern = g:possession_dir . '/' . substitute(
      \ fnamemodify(g:possession_git_root, ':.'), '[\.\/]', '%', 'g'
      \ ) . (g:possession_git_branch !=# '' ?
      \ '%' . substitute(g:possession_git_branch, '\/', '%', 'g') : '')

command! PLoad call s:possession_load()

command! -bang Possess
      \ call possession#init(<bang>0) |
      \ call possession#refresh_list()

command! PList
      \ call possession#show_list()

command! PMove
      \ call possession#move() |
      \ call possession#refresh_list()

function! s:possession_load() abort
  let file = filereadable(expand(g:possession_git_root . '/Session.vim')) ?
        \ g:possession_git_root . '/Session.vim' :
        \ filereadable(expand(g:possession_file_pattern)) ?
        \ g:possession_file_pattern : ''
  if empty(v:this_session) && file !=# '' && !&modified
    exe 'source ' . fnameescape(file)
    " Note: remove the echo of file name at startup, vim change the shortmess option
    " when using session temporary
    redraw
    let g:current_possession = v:this_session
    if bufexists(0) && !filereadable(bufname('#'))
      bw #
    endif
    echom 'Tracking session in ' . fnamemodify(g:current_possession, ':~:.')
  elseif !empty(v:this_session)
    echo 'There is another session going on'
  elseif &modified
    echo 'Please save the current buffer first'
  endif
endfunction

function! possession#persist() abort
  " Note: more info :h SessionLoad-variable
  " Note: can also be used to not save the session
  if exists('g:SessionLoad')
    return ''
  endif

  if exists('g:current_possession')
    try
      exe 'mksession! ' . fnameescape(g:current_possession)
    catch
      unlet g:current_possession
      let &l:readonly = &l:readonly
      return 'echoerr ' . string(v:exception)
    finally
      let &l:readonly = &l:readonly
    endtry
  endif
  return ''
endfunction

augroup possession
  autocmd!
  autocmd VimLeavePre * call possession#persist()
augroup END

" vim:et sta sw=2 sts=-69
