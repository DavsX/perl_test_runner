if exists('g:perl_test_runner_loaded')
    finish
endif
let g:perl_test_runner_loaded = 1

" Plugin settings {{{
if !exists('g:perl_test_args_perl')
    let g:perl_test_args_perl = '-It/lib -Ilib'
endif

if !exists('g:perl_test_args_prove')
    let g:perl_test_args_prove = '-It/lib -Ilib'
endif

if !exists('g:perl_test_all_command')
    let g:perl_test_all_command = 'prove'
endif
" }}}

function! s:Path_is_test_inside_t(path)
    return a:path =~# '^' . '.\+' . '/t/' . '.\+' . '\.t$'
endfunction

function! s:GetTestPath()
    let l:path = expand('%:p')

    if s:Path_is_test_inside_t(l:path)
        let g:perl_test_last_path = l:path
        return l:path
    else
        if exists('g:perl_test_last_path')
            return g:perl_test_last_path
        endif
    endif
endfunction

function! PerlTestCreate()
    let l:path = expand('%')

    let l:path = substitute(l:path, 'lib/', 't/', '')
    let l:path = substitute(l:path, '.pm', '', '')

    execute "silent :!mkdir -p ".l:path." > /dev/null 2>&1"
    redraw!

    call feedkeys(':vs '.l:path.'/')
endfunction

function! PerlTestDirOpen()
    let l:path = expand('%')

    let l:path = substitute(l:path, 'lib/', 't/', '')
    let l:path = substitute(l:path, '.pm', '', '')
    let l:path = substitute(l:path, '\v/.*?\.t', '', '')

    execute "silent :!mkdir -p ".l:path." > /dev/null 2>&1"
    redraw!

    execute ":vs ".l:path."/"
endfunction

function! s:RunTestFile(tool)
    write

    let l:path = s:GetTestPath()

    if a:tool ==? 'perl'
        let $PERL_TEST_COMMAND = "perl"
        let l:cmd = ":!time perl " . g:perl_test_args_perl . " " . l:path
    else
        let $PERL_TEST_COMMAND = "prove"
        let l:cmd = ":!unbuffer prove " . g:perl_test_args_prove . " " . l:path
    endif

    silent !clear
    execute l:cmd
endfunction

function! PerlTestAll()
    write
    let $PERL_TEST_COMMAND = "prove"
    let $TEST_METHOD = ""

    silent !clear
    execute ":!unbuffer " . g:perl_test_all_command . " " . g:perl_test_args_prove . " t/"
endfunction

function! PerlTestFile()
    let $TEST_METHOD = ""
    call s:RunTestFile('perl')
endfunction

command! PerlTestFile     :call PerlTestFile()
command! PerlTestAll      :call PerlTestAll()
command! PerlTestCreate   :call PerlTestCreate()
command! PerlTestDirOpen  :call PerlTestDirOpen()
