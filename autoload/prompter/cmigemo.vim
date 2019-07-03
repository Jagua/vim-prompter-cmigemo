let s:save_cpo = &cpo
set cpo&vim


"
" api
"


function! prompter#cmigemo#input(direction) abort "{{{
  try
    let result = prompter#input({
          \ 'prompt' : 'prompter-cmigemo/',
          \ 'color' : 'Normal',
          \ 'histtype' : '/',
          \ 'on_change' : function('s:on_change', [s:migemodicts()]),
          \ 'on_enter' : function('s:on_enter'),
          \ 'on_cancel' : function('s:on_cancel'),
          \})
    call feedkeys(printf("%s%s\<CR>", a:direction, result), 'n')
  catch /^prompter-cmigemo:/
    echo v:exception
  endtry
endfunction "}}}


"
" common
"


function! prompter#cmigemo#_sid() abort "{{{
  nnoremap <SID> <SID>
  return maparg('<SID>', 'n')
endfunction "}}}


function! s:migemodicts() abort "{{{
  let dicts = get(g:, 'prompter_cmigemo_migemodicts', [])
  if empty(dicts)
    throw 'prompter-cmigemo: require g:prompter_cmigemo_migemodicts'
  endif
  return dicts
endfunction "}}}


function! s:cmigemo_cmdlns(pattern, dicts) abort "{{{
  let cmdlns = [
        \ 'cmigemo', '--vim', '--nonewline',
        \ '--word', a:pattern, '--dict', a:dicts[0],
        \]

  for subdict in a:dicts[1:]
    let cmdlns += ['--subdict', subdict]
  endfor

  return cmdlns
endfunction "}}}


function! s:matchdelete() abort "{{{
  if !exists('b:prompter_cmigemo_match_id')
    return
  endif
  try
    call matchdelete(b:prompter_cmigemo_match_id)
    unlet b:prompter_cmigemo_match_id
  catch
  endtry
endfunction "}}}


" Note: In the following s:on_***() functions and the other functions invoked
"       from them, you must not use :throw since errors can not be catched.


"
" for Vim
"


function! s:on_change(migemodicts, input) abort "{{{
  let input = join(a:input, '')
  if exists('s:job') && job_status(s:job) ==# 'run'
    call job_stop(s:job)
    unlet s:job
  endif
  if empty(input)
    return
  endif
  let cmdlns = s:cmigemo_cmdlns(input, a:migemodicts)
  let s:job = job_start(cmdlns, {'close_cb' : function('s:close_cb')})
endfunction "}}}


function! s:on_enter(input) abort "{{{
  if empty(join(a:input, ''))
    return ''
  endif
  while exists('s:job') && job_status(s:job) ==# 'run'
    sleep 10m
  endwhile
  while empty(get(b:, 'prompter_cmigemo_msg', ''))
    sleep 10m
  endwhile
  call s:matchdelete()
  let result = b:prompter_cmigemo_msg
  unlet b:prompter_cmigemo_msg
  return result
endfunction "}}}


function! s:on_cancel(input) abort "{{{
  if exists('s:job') && job_status(s:job) ==# 'run'
    call job_stop(s:job)
    unlet s:job
  endif
  call s:matchdelete()
  unlet b:prompter_cmigemo_msg
endfunction "}}}


function! s:close_cb(ch) abort "{{{
  let msg = ''
  while ch_status(a:ch, {'part' : 'out'}) ==# 'buffered'
    let msg .= ch_read(a:ch)
  endwhile
  if empty(msg)
    return
  endif
  call s:matchdelete()
  let b:prompter_cmigemo_msg = msg
  let b:prompter_cmigemo_match_id = matchadd('Search', msg)
  redraw
  if exists('s:job')
    unlet s:job
  endif
endfunction "}}}


if !has('nvim')
  let &cpo = s:save_cpo
  unlet s:save_cpo
  finish
endif


"
" for NeoVim
"


function! s:on_change(migemodicts, input) abort "{{{
  let input = join(a:input, '')
  if exists('s:job')
    call jobstop(s:job)
    unlet s:job
  endif
  if empty(input)
    return
  endif
  let cmdlns = s:cmigemo_cmdlns(input, a:migemodicts)
  let s:job = jobstart(cmdlns, {
        \ 'on_stdout' : function('s:on_stdout'),
        \ 'stdout_buffered' : v:true,
        \})
  if s:job <= 0
    echo printf('prompter-cmigemo: jobstart() error: error code %d', s:job)
    unlet s:job
  endif
endfunction "}}}


function! s:on_enter(input) abort "{{{
  if empty(join(a:input, ''))
    return
  endif
  while exists('s:job')
    sleep 10m
  endwhile
  while empty(get(b:, 'prompter_cmigemo_msg', ''))
    sleep 10m
  endwhile
  call s:matchdelete()
  let result = b:prompter_cmigemo_msg
  unlet b:prompter_cmigemo_msg
  return result
endfunction "}}}


function! s:on_cancel(input) abort "{{{
  if exists('s:job')
    call jobstop(s:job)
    unlet s:job
  endif
  call s:matchdelete()
  unlet b:prompter_cmigemo_msg
endfunction "}}}


function! s:on_stdout(job_id, data, event) abort "{{{
  let msg = join(a:data, '')
  if empty(msg)
    return
  endif
  call s:matchdelete()
  let b:prompter_cmigemo_msg = msg
  let b:prompter_cmigemo_match_id = matchadd('Search', msg)
  redraw
  if exists('s:job')
    unlet s:job
  endif
endfunction "}}}


let &cpo = s:save_cpo
unlet s:save_cpo


" vim:set et ts=2 fdm=marker fmr={{{,}}}:
