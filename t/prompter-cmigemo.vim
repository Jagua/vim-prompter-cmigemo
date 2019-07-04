scriptencoding utf-8


if !empty($PROFILE_LOG)
  profile start $PROFILE_LOG
  profile! file autoload/*.vim
  profile! file plugin/*.vim
endif


runtime! plugin/prompter/cmigemo.vim


call vspec#hint({'sid' : 'prompter#cmigemo#_sid()'})


if empty($MIGEMODICT_PATH)
  let $MIGEMODICT_PATH = '/usr/share/cmigemo/utf-8/migemo-dict'
endif


function! s:check_dependencies() abort "{{{
  if !executable('cmigemo')
    SKIP 'cmigemo is not installed'
  endif

  if !filereadable($MIGEMODICT_PATH)
    execute printf('SKIP "%s is not readable"', $MIGEMODICT_PATH)
  endif
endfunction "}}}


describe 'prompter-cmigemo'
  it 'should be only available if cmigemo is installed'
    call s:check_dependencies()

    Expect executable('cmigemo') to_be_true
  end
end


describe '<Plug>'
  context '(prompter-cmigemo-forward)'
    it 'should provide in normal mode'
      Expect maparg('<Plug>(prompter-cmigemo-forward)', 'n') =~# 'prompter#cmigemo#input'
    end
  end

  context '(prompter-cmigemo-backward)'
    it 'should provide in normal mode'
      Expect maparg('<Plug>(prompter-cmigemo-backward)', 'n') =~# 'prompter#cmigemo#input'
    end
  end
end


describe 's:'
  before
    let g:prompter_cmigemo_migemodicts = [$MIGEMODICT_PATH]
  end

  describe 'migemodicts()'
    it 'should work'
      call s:check_dependencies()

      Expect Call('s:migemodicts') ==# g:prompter_cmigemo_migemodicts

      unlet g:prompter_cmigemo_migemodicts
      Expect expr { Call('s:migemodicts') } to_throw '^prompter-cmigemo:'
    end
  end

  describe 'cmigemo_cmdlns()'
    it 'should work'
      call s:check_dependencies()

      Expect system(join(Call('s:cmigemo_cmdlns', 'neko', g:prompter_cmigemo_migemodicts), ' ')) =~# '猫'
    end
  end
end


describe '<Plug>'
  before
    let g:prompter_cmigemo_migemodicts = [$MIGEMODICT_PATH]

    nmap ;/ <Plug>(prompter-cmigemo-forward)
    nmap ;? <Plug>(prompter-cmigemo-backward)

    let texts = [
          \ '我輩は猫である．',
          \ '名前はまだ無い．',
          \]
    new
    put = texts
    1 delete _
  end

  after
    bdelete!
  end

  context '(prompter-cmigemo-forward)'
    it 'should work'
      call s:check_dependencies()

      silent execute "normal ;/neko\<CR>"
      Expect getpos('.')[1 : 2] == [1, 10]

      silent execute "normal ;/namae\<CR>"
      Expect getpos('.')[1 : 2] == [2, 1]
    end
  end

  context '(prompter-cmigemo-backward)'
    it 'should work'
      call s:check_dependencies()

      silent execute "normal ;?neko\<CR>"
      Expect getpos('.')[1 : 2] == [1, 10]

      silent execute "normal ;?namae\<CR>"
      Expect getpos('.')[1 : 2] == [2, 1]
    end
  end
end
