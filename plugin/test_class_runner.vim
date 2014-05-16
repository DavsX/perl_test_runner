if exists('g:loaded_test_class_runner')
    finish
endif
let g:loaded_test_class_runner = 1

" Plugin settings {{{
if !exists('g:test_class_perl_args')
    let g:test_class_perl_args = '-Ilib -It/lib -It/tests'
endif

if !exists('g:test_all_command')
    let g:test_all_command = 'prove'
endif

if !exists('g:test_class_prove_args')
    let g:test_class_prove_args = '-Ilib -It/lib -It/tests'
endif

if !exists('g:test_class_path_folder')
    let g:test_class_path_folder = 'tests'
else 
    let g:test_class_path_folder = substitute(g:test_class_path_folder, '^/', '', '')
    let g:test_class_path_folder = substitute(g:test_class_path_folder, '/$', '', '')
endif

if !exists('g:test_class_path_prefix')
    let g:test_class_path_prefix = 'Test'
else 
    let g:test_class_path_prefix = substitute(g:test_class_path_prefix, '^/', '', '')
    let g:test_class_path_prefix = substitute(g:test_class_path_prefix, '/$', '', '')
endif

let g:test_class_path = join([ g:test_class_path_folder, g:test_class_path_prefix ], "/") . "/"
" }}}

" Path query functions {{{
function! s:Path_is_test_inside_t(path)
    return a:path =~# '^' . '.\+' . '/t/' . '.\+' . '\.t$'
endfunction

function! s:Path_is_module_inside_test_class_dir(path)
    return a:path =~# '^' . '.\+' . '/t/' . g:test_class_path . '.\+' . '\.pm$'
endfunction

function! s:Path_is_module_inside_lib(path)
    return a:path =~# '^' . '.\+' . '/lib/' . '.\+' . '\.pm$'
endfunction
" }}}

" Get_path functions {{{
function! s:Get_test_class_path_for_module(path)
    return substitute(a:path, "/lib/", "/t/".g:test_class_path , "")
endfunction

function! s:Get_path_for(path)
    let l:path = 0
    if s:Path_is_module_inside_lib(a:path)
        let l:path = s:Get_test_class_path_for_module(a:path)
    elseif s:Path_is_module_inside_test_class_dir(a:path)
        let l:path = a:path
    elseif s:Path_is_test_inside_t(a:path)
        let l:path = a:path
    else
        echo "ERROR! Only .pm and .t files are supported"
    endif
    return l:path
endfunction
" }}}

" s:RunTestFile {{{
function! s:RunTestFile(tool)
    write

    let l:path = s:Get_path_for( expand('%:p') )

    if a:tool ==? 'perl'
        let $PERL_TEST_COMMAND = "perl"
        let l:cmd = ":!time perl " . g:test_class_perl_args . " " . l:path
    else
        let $PERL_TEST_COMMAND = "prove"
        let l:cmd = ":!unbuffer prove " . g:test_class_prove_args . " " . l:path
    endif

    silent !clear
    execute l:cmd
endfunction
" }}}

" Subroutine name{{{
function! s:Match_sub_name(line)
    return ""
endfunction

function! s:Get_sub_name()
    let l:line_num = line(".")
    while l:line_num >= 0
        let l:line = getline(l:line_num)

        let l:list = matchlist(l:line, '\v^\w*sub ([0-9a-zA-Z_]+)')
        if !empty(l:list)
            return l:list[1]
        endif
        
        let l:line_num -= 1
    endwhile
    return ""
endfunction
" }}}

function! ProveTestAll()
    write
    let $PERL_TEST_COMMAND = "prove"
    let $TEST_METHOD = ""

    silent !clear
    execute ":!unbuffer " . g:test_all_command . " " . g:test_class_prove_args . " t/"
endfunction

function! ProveTestFile()
    let $TEST_METHOD = ""
    call s:RunTestFile('prove')
endfunction

function! PerlTestFile()
    let $TEST_METHOD = ""
    call s:RunTestFile('perl')
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

command! PerlTestFile     :call PerlTestFile()
command! PerlTestSub      :call PerlTestSub()
command! PerlTestSubLike  :call PerlTestSubLike()
command! ProveTestFile    :call ProveTestFile()
command! ProveTestSub     :call ProveTestSub()
command! ProveTestSubLike :call ProveTestSubLike()
command! ProveTestAll     :call ProveTestAll()
