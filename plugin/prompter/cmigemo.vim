if exists('g:loaded_prompter_cmigemo')
  finish
endif
let g:loaded_prompter_cmigemo = 1


let s:save_cpo = &cpo
set cpo&vim


nnoremap <silent> <Plug>(prompter-cmigemo-forward) :<C-u>call prompter#cmigemo#input('/')<CR>
nnoremap <silent> <Plug>(prompter-cmigemo-backward) :<C-u>call prompter#cmigemo#input('?')<CR>


let &cpo = s:save_cpo
unlet s:save_cpo
