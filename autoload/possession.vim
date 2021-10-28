" File: autoload/possession.vim
" Maintainer: Robertus Diawan Chris <https://github.com/bruhtus>
" License:
" Copyright (c) Robertus Diawan Chris. Distributed under the same terms as Vim itself.
" See :h license
"
" Description:
" flexible vim session management with git root and branch support

function! possession#init(bang) abort
  if !isdirectory(fnamemodify(g:possession_dir, ':p'))
    call mkdir(fnamemodify(g:possession_dir, ':p'), 'p')
  endif

  let session = get(g:, 'current_possession', v:this_session)

  try
    if a:bang && filereadable(session)
      echom 'Deleting session in ' . fnamemodify(session, ':~:.')
      call delete(session)
      unlet! g:current_possession
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

" TODO: need to simplify this
function! possession#list() abort
  let replace_first_percentage = map(globpath(g:possession_dir, '%%*', 0, 1),
        \ {-> substitute(v:val, '^.*[/\\]%', '\~', '')})

  let g:possession_list = map(
        \ map(replace_first_percentage,
        \   {-> substitute(v:val, '^\~%%', '\~%.', '')}),
        \ {-> substitute(v:val, '%', '\/', 'g')}
        \ )
endfunction

function! possession#move() abort
  let renamed = g:possession_git_root . '/Session.vim'

  if !filereadable(expand(renamed)) && filereadable(expand(g:possession_file_pattern))
    call rename(expand(g:possession_file_pattern), expand(renamed))
    let g:current_possession = renamed
    echom 'Tracking session in ' . fnamemodify(g:current_possession, ':~:.')

  elseif filereadable(expand(renamed)) && !filereadable(expand(g:possession_file_pattern))
    call rename(expand(renamed), expand(g:possession_file_pattern))
    let g:current_possession = g:possession_file_pattern
    echom 'Tracking session in ' . fnamemodify(g:current_possession, ':~:.')

  elseif filereadable(expand(renamed)) && filereadable(expand(g:possession_file_pattern))
    let choice = confirm('Session file exist, replace it?',
          \ "&Yes\n&No", 2)
    if choice == 1
      redraw
      let decide = confirm('Move from current working directory or possession directory?',
            \ "&Current working directory\n&Possession directory\n&Quit", 3)
      if decide == 1
        redraw
        call rename(expand(renamed), expand(g:possession_file_pattern))
        let g:current_possession = g:possession_file_pattern
        echom 'Tracking session in ' . fnamemodify(g:current_possession, ':~:.')
      elseif decide == 2
        redraw
        call rename(expand(g:possession_file_pattern), expand(renamed))
        let g:current_possession = renamed
        echom 'Tracking session in ' . fnamemodify(g:current_possession, ':~:.')
      elseif decide == 3
        redraw
        echo 'Canceled, no session file moved'
      endif
    elseif choice == 2
      redraw
      echo 'No session file moved'
    endif

  else
    echo 'No session found for this path'
  endif
  let v:this_session = g:current_possession
endfunction

" vim:et sta sw=2 sts=-69
