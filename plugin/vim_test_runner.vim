if exists('g:vim_test_runner_loaded')
    "finish
endif
let g:vim_test_runner_loaded = 1

" Plugin settings {{{
if !exists('g:perl_test_file_args')
    let g:perl_test_file_args = '-It/lib -Ilib'
endif

if !exists('g:perl_test_all_args')
    let g:perl_test_all_args = '-It/lib -Ilib'
endif

if !exists('g:perl_test_file_command')
    let g:perl_test_file_command = 'perl '.g:perl_test_file_args
endif

if !exists('g:perl_test_all_command')
    let g:perl_test_all_command = 'unbuffer prove '.g:perl_test_all_args
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

    execute "silent :!mkdir -p ".l:path." >> /tmp/perl_test_runner_log 2>&1"
    redraw!

    call feedkeys(':vs '.l:path.'/')
endfunction

function! PerlTestDirOpen()
    let l:path = expand('%')

    if s:Path_is_test_inside_t(expand('%:p'))
        execute ":e %:h"
    else
        let l:path = substitute(l:path, 'lib/', 't/', '')
        let l:path = substitute(l:path, '.pm', '', '')

        execute "silent :!mkdir -p ".l:path." >> /tmp/perl_test_runner_log 2>&1"
        redraw!

        execute ":vs ".l:path."/"
    endif
endfunction

function! s:RunTestFile(tool)
    let l:path = s:GetTestPath()

    let l:cmd = ":!" . a:tool . " " . l:path

    silent !clear
    execute l:cmd
endfunction

function! PerlTestAll()
    write

    silent !clear
    execute ":!" . g:perl_test_all_command . " t/"
endfunction

function! PerlTestFile()
    write
    call s:RunTestFile(g:perl_test_file_command)
endfunction

function! PerlTestDir()
    write

    let l:path = expand('%')

    if s:Path_is_test_inside_t(expand('%:p'))
        let l:path = expand('%:h')
    else
        let l:path = substitute(l:path, 'lib/', 't/', '')
        let l:path = substitute(l:path, '.pm', '', '')
    endif

    echom "PerlTestDir: " . l:path

    silent !clear
    execute ":!" . g:perl_test_all_command . " " . l:path
endfunction

command! PerlTestFile     :call PerlTestFile()
command! PerlTestAll      :call PerlTestAll()
command! PerlTestDir      :call PerlTestDir()
command! PerlTestCreate   :call PerlTestCreate()
command! PerlTestDirOpen  :call PerlTestDirOpen()
