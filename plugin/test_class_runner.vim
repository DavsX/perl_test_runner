" Vim plugin to enable running various perl tests from vim

if exists('g:loaded_test_class_runner')
    "finish
endif
let g:loaded_test_class_runner = 1

if !exists('g:test_class_perl_args')
    let g:test_class_perl_args = '-Ilib -It/lib'
endif

if !exists('g:test_class_prove_args')
    let g:test_class_prove_args = '-Ilib -It/lib'
endif

if !exists('g:test_class_path')
    let g:test_class_path = 't/Test/'
endif

function! s:Path_inside_perl_project(path)
    return a:path =~# '^' . '.\+' . '/\(t\|lib\)/' . '.\+'
endfunction

function! s:Path_contains_t(path)
    return a:path =~# '/t/'
endfunction

function! s:Path_contains_lib(path)
    return a:path =~# '/lib/'
endfunction

function! s:Path_contains_test_class_path(path)
    return a:path =~# '/' . g:test_class_path
endfunction

function! s:Get_test_class_path_for_module(path)
    return substitute(a:path,"/lib/","/" . g:test_class_path ,"")
endfunction

function! s:Get_path_for_module(path)
    if s:Path_contains_test_class_path(a:path)
        return a:path
    elseif s:Path_contains_lib(a:path)
        return s:Get_test_class_path_for_module(a:path)
    else
        echo "ERROR! .pm files are supported only in ". g:test_class_path ." and lib/"
    endif
endfunction

function! s:Get_path_for_test(path)
    if s:Path_contains_t(a:path)
        return a:path
    else
        echo "ERROR! .t files are supported only in t/"
    endif
endfunction

function! s:Get_path_for(path, ext)
    if a:ext ==? 'pm'
        let l:path = s:Get_path_for_module(a:path)
    elseif a:ext ==? 't'
        let l:path = s:Get_path_for_test(a:path)
    else
        echo "ERROR! Only .pm and .t files are supported"
        let l:path = 0
    endif
    return l:path
endfunction

function! s:Get_project_root(path)
    return substitute(a:path, '/\(lib\|t\)/\(.*\)$',"/", "")
endfunction

function! s:Cd_to_root(path)
    let l:root = s:Get_project_root(a:path)
    if isdirectory(l:root)
        execute "cd " . l:root
        return 1
    else
        echo "ERROR! Directory does not exists: " . l:root
    endif
endfunction

command! PerlTestFile :call PerlTestFile()
command! ProveTestFile :call ProveTestFile()

function! s:RunTestFile(tool)
    write
    let l:path = expand('%:p')
    let l:ext = expand('%:e')

    if s:Path_inside_perl_project(l:path)
        let l:path = s:Get_path_for(l:path, l:ext)

        if s:Cd_to_root(l:path)
            if a:tool ==? 'perl'
                let l:cmd = ":!perl " . g:test_class_perl_args . " " . l:path
            else
                let l:cmd = ":!unbuffer prove " . g:test_class_prove_args . " " . l:path
            endif
            silent !clear
            execute l:cmd
        else
            echo "ERROR! Could not process: " . l:path
        endif
    else
        echo "ERROR! Invalid path: ".l:path
    endif
endfunction

function! ProveTestFile()
    let $TEST_METHOD = ""
    call s:RunTestFile('prove')
endfunction

function! PerlTestFile()
    let $TEST_METHOD = ""
    call s:RunTestFile('perl')
endfunction

"echo s:Get_project_root('/home/davs/t/someting')
"call s:Cd_to_root('/home/davs/t/something')
"pwd
"echo s:Get_path_for('/home/davs/t/tests/Test/IK4/Reminder/ResultClass/Stuff.pm','pm')
