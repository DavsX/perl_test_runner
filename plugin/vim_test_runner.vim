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

function! s:Is_test_file_in_test_dir(path)
    return a:path =~# '^.\+'
       \ .'/'.g:test_runner_test_dir.'/.\{-}'
       \ .g:test_runner_test_prefix.'.\+'.g:test_runner_test_suffix
       \ .'\.'.g:test_runner_test_ext.'$'
endfunction

function! s:Get_single_test_path()
    let l:path = expand('%:p')

    if s:Is_test_file_in_test_dir(l:path)
        let g:vim_test_last_test = l:path
        return l:path
    else
        if exists('g:vim_test_last_test')
            return g:vim_test_last_test
        endif
    endif
endfunction

function! s:Build_test_file_path(path)
    let l:path = a:path
    let l:path = substitute(l:path, g:test_runner_lib_dir.'/', g:test_runner_test_dir.'/', '')
    let l:path = substitute(l:path, '\.'.g:test_runner_code_ext.'$', '', '')
    return l:path
endfunction

function! s:Create_test_file()
    let l:path = s:Build_test_file_path(expand('%'))

    execute "silent :!mkdir -p ".l:path." >> /tmp/vim_test_runner_log 2>&1"
    redraw!

    call feedkeys(':vs '.l:path.'/')
endfunction

function! s:Open_test_dir()
    let l:path = expand('%')

    if s:Is_test_file_in_test_dir(expand('%:p'))
        execute ":e %:h"
    else
        let l:path = s:Build_test_file_path(l:path)
        execute "silent :!mkdir -p ".l:path." >> /tmp/vim_test_runner_log 2>&1"
        redraw!
        execute ":vs ".l:path."/"
    endif
endfunction

function! s:Run_single_test()
    let l:path = s:Get_single_test_path()
    let l:cmd = ':!unbuffer '.g:test_runner_single_command.' '.g:test_runner_single_args.' '.l:path
    call s:Run_command(l:cmd)
endfunction

function! s:Run_all_tests()
    let l:cmd = ':!unbuffer '.g:test_runner_multiple_command.' '.g:test_runner_multiple_args.' '.g:test_runner_test_dir
    call s:Run_command(l:cmd)
endfunction

function! s:Run_command(cmd)
    write
    silent !clear
    execute a:cmd
endfunction

function! s:Run_tests_in_dir()
    let l:path = expand('%')

    if s:Is_test_file_in_test_dir(expand('%:p'))
        let l:path = expand('%:h')
    else
        let l:path = s:Build_test_file_path(l:path)
    endif

    let l:cmd = ':!unbuffer '.g:test_runner_multiple_command.' '.g:test_runner_multiple_args.' '.l:path
    call s:Run_command(l:cmd)
endfunction

command! RunSingleTest  :call <SID>Run_single_test()
command! RunAllTests    :call <SID>Run_all_tests()
command! RunTestsInDir  :call <SID>Run_tests_in_dir()
command! CreateTestFile :call <SID>Create_test_file()
command! OpenTestDir    :call <SID>Open_test_dir()
