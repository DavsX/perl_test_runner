" Import guard {{{
if exists('g:vim_test_runner_loaded')
    "finish
endif
let g:vim_test_runner_loaded = 1
" }}}

" Plugin settings {{{
let g:test_runner_single_args      = get( g:, 'test_runner_single_args', '' )
let g:test_runner_single_command   = get( g:, 'test_runner_single_command', 'bash' )
let g:test_runner_multiple_args    = get( g:, 'test_runner_multiple_args', '' )
let g:test_runner_multiple_command = get( g:, 'test_runner_multiple_command', 'bash' )
let g:test_runner_test_dir         = get( g:, 'test_runner_test_dir', 'test' )
let g:test_runner_lib_dir          = get( g:, 'test_runner_lib_dir', 'lib' )
let g:test_runner_test_ext         = get( g:, 'test_runner_test_ext', '' )
let g:test_runner_test_prefix      = get( g:, 'test_runner_test_prefix', '' )
let g:test_runner_test_suffix      = get( g:, 'test_runner_test_suffix', '' )
let g:test_runner_code_ext         = get( g:, 'test_runner_code_ext', '' )
" }}}

function! s:IsTestFileInsideTestDir(path)
    return a:path =~# '^.\+'
       \ .'/'.g:test_runner_test_dir.'/.\{-}'
       \ .g:test_runner_test_prefix.'.\+'.g:test_runner_test_suffix
       \ .'\.'.g:test_runner_test_ext.'$'
endfunction

function! s:GetSingleTestPath()
    let l:path = expand('%:p')

    if s:IsTestFileInsideTestDir(l:path)
        let g:vim_test_last_test = l:path
        return l:path
    else
        if exists('g:vim_test_last_test')
            return g:vim_test_last_test
        endif
    endif
endfunction

function! s:BuildTestFilePath(path)
    let l:path = a:path
    let l:path = substitute(l:path, g:test_runner_lib_dir.'/', g:test_runner_test_dir.'/', '')
    let l:path = substitute(l:path, '\.'.g:test_runner_code_ext.'$', '', '')
    return l:path
endfunction

function! s:CreateTestFile()
    let l:path = s:BuildTestFilePath(expand('%'))

    execute "silent :!mkdir -p ".l:path." >> /tmp/vim_test_runner_log 2>&1"
    redraw!

    call feedkeys(':vs '.l:path.'/')
endfunction

function! s:OpenTestDir()
    let l:path = expand('%')

    if s:IsTestFileInsideTestDir(expand('%:p'))
        execute ":e %:h"
    else
        let l:path = s:BuildTestFilePath(l:path)
        execute "silent :!mkdir -p ".l:path." >> /tmp/vim_test_runner_log 2>&1"
        redraw!
        execute ":vs ".l:path."/"
    endif
endfunction

function! s:RunSingleTest()
    let l:path = s:GetSingleTestPath()
    let l:cmd = ':!unbuffer '.g:test_runner_single_command.' '.g:test_runner_single_args.' '.l:path
    call s:RunCommand(l:cmd)
endfunction

function! s:RunAllTests()
    let l:cmd = ':!unbuffer '.g:test_runner_multiple_command.' '.g:test_runner_multiple_args.' '.g:test_runner_test_dir
    call s:RunCommand(l:cmd)
endfunction

function! s:RunCommand(cmd)
    write
    silent !clear
    execute a:cmd
endfunction

function! s:RunTestsInDir()
    let l:path = expand('%')

    if s:IsTestFileInsideTestDir(expand('%:p'))
        let l:path = expand('%:h')
    else
        let l:path = s:BuildTestFilePath(l:path)
    endif

    let l:cmd = ':!unbuffer '.g:test_runner_multiple_command.' '.g:test_runner_multiple_args.' '.l:path
    call s:RunCommand(l:cmd)
endfunction

command! RunSingleTest  :call <SID>RunSingleTest()
command! RunAllTests    :call <SID>RunAllTests()
command! RunTestsInDir  :call <SID>RunTestsInDir()
command! CreateTestFile :call <SID>CreateTestFile()
command! OpenTestDir    :call <SID>OpenTestDir()
