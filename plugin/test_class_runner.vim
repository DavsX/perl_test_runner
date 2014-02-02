" Vim plugin to enable running various perl tests from vim

if exists('g:loaded_test_class_runner')
    "finish
endif
let g:loaded_test_class_runner = 1

" Plugin settings {{{
if !exists('g:test_class_perl_args')
    let g:test_class_perl_args = '-Ilib -It/lib'
endif

if !exists('g:test_class_prove_args')
    let g:test_class_prove_args = '-Ilib -It/lib'
endif

if !exists('g:test_class_path')
    let g:test_class_path = 'Test/'
else 
    let g:test_class_path = substitute(g:test_class_path, '^/', '', '')
    let g:test_class_path = substitute(g:test_class_path, '/$', '', '')
    let g:test_class_path = g:test_class_path . '/'
endif
" }}}

" Path query functions {{{
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
    return a:path =~# '/t/' . g:test_class_path
endfunction
" }}}

" Get_path functions {{{
function! s:Get_test_class_path_for_module(path)
    " /some/path/lib/X/Y.pm => /some/path/t/g:test_class_path/X/Y.pm 
    return substitute(a:path, "/lib/", "/t/".g:test_class_path , "")
endfunction

function! s:Get_path_for_module(path)
    if s:Path_contains_test_class_path(a:path)
        " /some/path/t/g:test_class_path/X/Y.pm => /some/path/t/g:test_class_path/X/Y.pm 
        return a:path
    elseif s:Path_contains_lib(a:path)
        " /some/path/lib/X/Y.pm => /some/path/t/g:test_class_path/X/Y.pm 
        return s:Get_test_class_path_for_module(a:path)
    else
        echo "ERROR! .pm files are supported only in t/". g:test_class_path ." and lib/"
    endif
endfunction

" /some/path/t/0001-test.t => /some/path/t/0001-test.t
function! s:Get_path_for_test(path)
    if s:Path_contains_t(a:path)
        return a:path
    else
        echo "ERROR! .t files are supported only in t/"
    endif
endfunction

function! s:Get_path_for(path, ext)
    let l:path = 0
    if a:ext ==? 'pm'
        let l:path = s:Get_path_for_module(a:path)
    elseif a:ext ==? 't'
        let l:path = s:Get_path_for_test(a:path)
    else
        echo "ERROR! Only .pm and .t files are supported"
    endif
    return l:path
endfunction
" }}}

" Project root functions {{{
function! s:Get_project_root(path)
    " /some/path/lib/X/Y.pm => /some/path/
    "return substitute(a:path, '/\(lib\|t\)/\(.*\)$',"/", "")
    return substitute(a:path, '\v/(lib|t)/(.*)$',"/", "")
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
" }}}

" function s:RunTestFile {{{
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
            echo "ERROR! Could not find root: " . l:path
        endif
    else
        echo "ERROR! Path not inside Perl project directory: " . l:path
    endif
endfunction
" }}}

function! ProveTestAll()
    write
    let l:path = expand('%:p')

    if s:Path_inside_perl_project(l:path)
        if s:Cd_to_root(l:path)
            let l:cmd = ":!unbuffer prove " . g:test_class_prove_args . " t/"

            silent !clear
            execute l:cmd
        else
            echo "ERROR! Could not find root: " . l:path
        endif
    else
        echo "ERROR! Path not inside Perl project directory: " . l:path
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

function! s:Match_sub_name(line)
    let l:list = matchlist(a:line, '\v^\w*sub ([0-9a-zA-Z_]+)')
    if !empty(l:list)
        return l:list[1]
    endif
    return ""
endfunction

function! s:Get_sub_name()
    let l:line_num = line(".")
    let l:subname = ""
    while l:line_num >= 0
        let l:line = getline(l:line_num)

        let l:subname = s:Match_sub_name(l:line)
        if l:subname != ""
            break
        endif
        
        let l:line_num -= 1
    endwhile
    return l:subname
endfunction

function! ProveTestSubLike()
    let l:subname = s:Get_sub_name()
    if l:subname != ""
        let $TEST_METHOD = l:subname . '.*'
        call s:RunTestFile('prove')
    else
        echo "ERROR! No subroutine found"
    endif
endfunction

function! ProveTestSub()
    let l:subname = s:Get_sub_name()
    if l:subname != ""
        let $TEST_METHOD = l:subname
        call s:RunTestFile('prove')
    else
        echo "ERROR! No subroutine found"
    endif
endfunction

function! PerlTestSubLike()
    let l:subname = s:Get_sub_name()
    if l:subname != ""
        let $TEST_METHOD = l:subname . '.*'
        call s:RunTestFile('perl')
    else
        echo "ERROR! No subroutine found"
    endif
endfunction

function! PerlTestSub()
    let l:subname = s:Get_sub_name()
    if l:subname != ""
        let $TEST_METHOD = l:subname
        call s:RunTestFile('perl')
    else
        echo "ERROR! No subroutine found"
    endif
endfunction

command! PerlTestFile  :call PerlTestFile()
command! ProveTestFile :call ProveTestFile()

command! ProveTestSub     :call ProveTestSub()
command! ProveTestSubLike :call ProveTestSubLike()
command! PerlTestSub      :call PerlTestSub()
command! PerlTestSubLike  :call PerlTestSubLike()

command! ProveTestAll :call ProveTestAll()

command! Davs :call PerlTestSub()

"nnoremap <leader>ptf :PerlTestFile<CR> 
"nnoremap <leader>pts :PerlTestSub<CR> 
"nnoremap <leader>rtf :ProveTestFile<CR> 
