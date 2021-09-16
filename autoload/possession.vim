" File: autoload/possession.vim
" Maintainer: Robertus Diawan Chris <https://github.com/bruhtus>
" License:
" Copyright (c) Robertus Diawan Chris. Distributed under the same terms as Vim itself.
" See :h license
"
" Description:
" decoupled vim session management with git root and branch support

function! possession#init(bang) abort
  if !isdirectory(fnamemodify(g:possession_dir, ':p'))
    call mkdir(fnamemodify(g:possession_dir, ':p'), 'p')
  endif

  let session = get(g:, 'current_possession', v:this_session)

  try
    if a:bang && filereadable(session)
      echom 'Deleting session in ' . fnamemodify(session, ':~:.')
      call delete(session)
      " TODO: need to simplify this
      let g:possession_replace_first_percentage = map(globpath(g:possession_dir, '%%*', 0, 1), {-> substitute(v:val, '^.*[/\\]%', '\~', '')})
      let g:possession_list = map(
      \ map(g:possession_replace_first_percentage,
      \   {-> substitute(v:val, '^\~%%', '\~%.', '')}),
      \ {-> substitute(v:val, '%', '\/', 'g')}
      \ )
      if exists('g:current_possession') | unlet g:current_possession | endif
      return ''
    elseif a:bang && !filereadable(session)
      echo 'Session for this path not found, nothing deleted'
      return ''
    elseif exists('g:current_possession')
      echom 'Pausing session in ' . fnamemodify(session, ':~:.')
      unlet g:current_possession
      return ''
    elseif !empty(session)
      let file = session
    else
      let file = g:possession_file_pattern
    endif

    let g:current_possession = file

    let error = possession#persist()
    if empty(error)
      echom 'Tracking session in ' . fnamemodify(file, ':~:.')
      let v:this_session = file
      return ''
    else
      return error
    endif

  finally
    let &l:readonly = &l:readonly
  endtry
endfunction

function! possession#persist() abort
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
