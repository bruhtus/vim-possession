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

" Ref:
" https://github.com/itchyny/vim-gitbranch/blob/1a8ba866f3eaf0194783b9f8573339d6ede8f1ed/autoload/gitbranch.vim#L11-L24
function! GitBranch() abort
  if get(b:, 'gitbranch_pwd', '') !=# expand('%:p:h') || !has_key(b:, 'gitbranch_path')
    call s:gitbranch_detect(expand('%:p:h'))
  endif
  if has_key(b:, 'gitbranch_path') && filereadable(b:gitbranch_path)
    let branch = get(readfile(b:gitbranch_path), 0, '')
    if branch =~# '^ref: '
      return substitute(branch, '^ref: \%(refs/\%(heads/\|remotes/\|tags/\)\=\)\=', '', '')
    elseif branch =~# '^\x\{20\}'
      return branch[:6]
    endif
  endif
  return ''
endfunction

" Ref:
" https://github.com/itchyny/vim-gitbranch/blob/1a8ba866f3eaf0194783b9f8573339d6ede8f1ed/autoload/gitbranch.vim#L26-L47
function! GitDir(path) abort
  let path = a:path
  let prev = ''
  let git_modules = path =~# '/\.git/modules/'
  while path !=# prev
    let dir = path . '/.git'
    let type = getftype(dir)
    if type ==# 'dir' && isdirectory(dir.'/objects') && isdirectory(dir.'/refs') && getfsize(dir.'/HEAD') > 10
      return dir
    elseif type ==# 'file'
      let reldir = get(readfile(dir), 0, '')
      if reldir =~# '^gitdir: '
        return simplify(reldir[8:])
      endif
    elseif git_modules && isdirectory(path.'/objects') && isdirectory(path.'/refs') && getfsize(path.'/HEAD') > 10
      return path
    endif
    let prev = path
    let path = fnamemodify(path, ':h')
  endwhile
  return ''
endfunction

" Ref:
" https://github.com/itchyny/vim-gitbranch/blob/1a8ba866f3eaf0194783b9f8573339d6ede8f1ed/autoload/gitbranch.vim#L49-L59
function! s:gitbranch_detect(path) abort
  unlet! b:gitbranch_path
  let b:gitbranch_pwd = expand('%:p:h')
  let dir = GitDir(a:path)
  if dir !=# ''
    let path = dir . '/HEAD'
    if filereadable(path)
      let b:gitbranch_path = path
    endif
  endif
endfunction

function! PossessionGitRoot() abort
  if !get(g:, 'possession_no_git_root')
    let l:dir = GitDir(getcwd())
    return !empty(l:dir) ?
          \ fnamemodify(l:dir, ':h') :
          \ getcwd()
  endif

  return getcwd()
endfunction

function! PossessionGitBranch() abort
  if !get(g:, 'possession_no_git_branch')
    return GitBranch()
  endif

  return ''
endfunction

function! PossessionFilePattern(...) abort
  let l:dir = get(a:000, 0)
  let l:branch = get(a:000, 1)

  if !empty(l:dir)
    return g:possession_dir . '/' . substitute(
          \ fnamemodify(l:dir, ':.'), '[\.\/]', '%', 'g'
          \ ) . (l:branch !=# '' ?
          \ '%' . substitute(l:branch, '\/', '%', 'g') : '')
  endif

  return g:possession_dir . '/' . substitute(
      \ fnamemodify(PossessionGitRoot(), ':.'), '[\.\/]', '%', 'g'
      \ ) . (PossessionGitBranch() !=# '' ?
      \ '%' . substitute(PossessionGitBranch(), '\/', '%', 'g') : '')
endfunction

command! PLoad call s:possession_load()

command! -bang Possess
      \ call possession#init(<bang>0) |
      \ call possession#update_list()

command! PList
      \ call possession#show_list()

command! PMove
      \ call possession#move() |
      \ call possession#update_list()

" Ref: vim-lsp/autoload/lsp/utils.vim (lsp#utils#echo_with_truncation())
function! PossessionMsgTruncation(msg) abort
  let l:msg = a:msg

  if &laststatus == 0 || (&laststatus == 1 && winnr('$') == 1)
    let l:winwidth = winwidth(0)

    if &ruler
      let l:winwidth -= 18
    endif
  else
    let l:winwidth = &columns - 20
  endif

  if &showcmd
    let l:winwidth -= 12
  endif

  if l:winwidth > 5 && l:winwidth < strdisplaywidth(a:msg)
    let l:msg = l:msg[:l:winwidth - 5] . '...'
  endif

  return l:msg
endfunction

function! s:possession_load() abort
  if filereadable(expand(getcwd() . '/Session.vim'))
    let file = getcwd() . '/Session.vim'
  elseif filereadable(expand(PossessionFilePattern(getcwd(), PossessionGitBranch())))
    let file = PossessionFilePattern(getcwd(), PossessionGitBranch())
  elseif filereadable(expand(PossessionGitRoot() . '/Session.vim'))
    let file = PossessionGitRoot() . '/Session.vim'
  elseif filereadable(expand(PossessionFilePattern()))
    let file = PossessionFilePattern()
  else
    let file = ''
  endif

  if empty(v:this_session) && file !=# '' && !&modified
    exe 'silent source ' . fnameescape(file)
    let g:current_possession = v:this_session
    if bufexists(0) && !filereadable(bufname('#'))
      bw #
    endif
    " Note: make sure that the echo message appear
    redraw
    echom 'Loading session in '
          \ . PossessionMsgTruncation(fnamemodify(g:current_possession, ':~:.'))
  elseif !empty(v:this_session)
    echo 'There is another session going on'
  elseif &modified
    echo 'Please save the current buffer first'
  endif
endfunction

function! PossessionPersist() abort
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
  autocmd VimLeavePre * call PossessionPersist()
augroup END

" vim:et sta sw=2 sts=-69
