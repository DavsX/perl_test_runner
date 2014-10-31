" Import guard {{{
if exists('g:vim_test_runner_loaded')
    "finish
endif
let g:vim_test_runner_loaded = 1
" }}}

" Plugin settings {{{
let g:test_runner_single_args = get( g:, 'test_runner_single_args', '' )
let g:test_runner_single_command = get( g:, 'test_runner_single_command', 'bash' )
let g:test_runner_multiple_args = get( g:, 'test_runner_multiple_args', '' )
let g:test_runner_multiple_command = get( g:, 'test_runner_multiple_command', 'bash' )
let g:test_runner_test_dir = get( g:, 'test_runner_test_dir', 'test' )
let g:test_runner_lib_dir = get( g:, 'test_runner_lib_dir', 'lib' )
let g:test_runner_test_ext = get( g:, 'test_runner_test_ext', '' )
let g:test_runner_test_prefix = get( g:, 'test_runner_test_prefix', '' )
let g:test_runner_test_suffix = get( g:, 'test_runner_test_suffix', '' )
let g:test_runner_code_ext = get( g:, 'test_runner_code_ext', '' )
" }}}

function! Is_test_file_in_test_dir(path)
    return a:path =~# '^.\+'
       \ .'/'.g:test_runner_test_dir.'/'
       \ .g:test_runner_test_prefix.'.\+'.g:test_runner_test_suffix
       \ .'\.'.g:test_runner_test_ext.'$'
endfunction

function! Get_single_test_path()
    let l:path = expand('%:p')

    if Is_test_file_in_test_dir(l:path)
        let g:vim_test_last_test = l:path
        return l:path
    else
        if exists('g:vim_test_last_test')
            return g:vim_test_last_test
        endif
    endif
endfunction

function! Build_test_file_path(path)
    let l:path = a:path
    let l:path = substitute(l:path, g:test_runner_lib_dir.'/', g:test_runner_test_dir.'/', '')
    let l:path = substitute(l:path, '\.'.g:test_runner_code_ext.'$', '', '')
    return l:path
endfunction

function! Create_test_file()
    let l:path = Build_test_file_path(expand('%'))

    execute "silent :!mkdir -p ".l:path." >> /tmp/vim_test_runner_log 2>&1"
    redraw!

    call feedkeys(':vs '.l:path.'/')
endfunction

function! Open_test_dir()
    let l:path = expand('%')

    if Is_test_file_in_test_dir(expand('%:p'))
        execute ":e %:h"
    else
        let l:path = Build_test_file_path(l:path)
        execute "silent :!mkdir -p ".l:path." >> /tmp/vim_test_runner_log 2>&1"
        redraw!
        execute ":vs ".l:path."/"
    endif
endfunction

<<<<<<< HEAD
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

function! Run_command(cmd)
    write
    call s:RunTestFile(g:perl_test_file_command)
endfunction

function! PerlTestDir()
    write

    let l:path = expand('%')

    if Is_test_file_in_test_dir(expand('%:p'))
        let l:path = expand('%:h')
    else
        let l:path = Build_test_file_path(l:path)
    endif

    let l:cmd = ':!unbuffer '.g:test_runner_multiple_command.' '.g:test_runner_multiple_args.' '.l:path
    call Run_command(l:cmd)
endfunction

command! Run_single_test  :call Run_single_test()
command! Run_all_tests    :call Run_all_tests()
command! Run_tests_in_dir :call Run_tests_in_dir()
command! Create_test_file :call Create_test_file()
command! Open_test_dir    :call Open_test_dir()
