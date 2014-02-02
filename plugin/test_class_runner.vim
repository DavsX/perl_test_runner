" Vim plugin to enable running various perl tests from vim
"
" Tests can be ran only from a Perl project directory, which is a directory
" containing lib/ and t/
"
" This plugin assumes, that the tests are written using Test::Class, however
" traditional .t tests can be ran too
"
" Typical directory structure this plugin assumes is like this, assuming
" g:test_class_path_folder is set to 'tests' and g:test_class_path_prefix is
" set to 'Test':
"   
"   -lib/
"       My/
"           Plugin.pm
"   -t/
"       0001-test.t
"       tests/
"           Test/
"               Plugin.pm
"
" This plugin enables to run tests right inside Vim without the need to open a
" separate terminal for tests (*.t) inside the 't/' directory, for modules
" (*.pm) inside 'lib/' directory and for their corresponding Test::Class test
" modules (inside tests/Test/)
"
" ProveTestAll
"   -it will run the 'prove t/' command, thus running all the tests inside t/
"   -!It changes the current directory to the project root (where t/ and lib/
"   are)
"
" ProveTestFile / PerlTestFile
"   -it tests only the current file via 'prove' or 'perl'
"   -for *.t and *.pm files under 't/' it tests that file
"   -for *.pm modules inside 't/' it tests the corresponding Test::Class test
"   module inside 't/tests/Test'
"   -!It changes the current directory to the project root (where t/ and lib/
"   are)
"
"   *NOTE: For a Test::Class test module, you should put this at the end of the 
"   file (right before 1;) so it can be called as standalone test:
"   __PACKAGE__->runtests unless caller;
"
" ProveTestSub / PerlTestSub
"   -it test only the current subroutine in the current file
"   -this assumes, that there is a test with the same name as the subroutine
"   -works for *.pm modules inside 'lib/' and 't/tests/Test/' as well
"   -!It changes the current directory to the project root (where t/ and lib/
"   are)
"
" ProveTestSubLike / PerlTestSubLike
"   -same, as ProveTestSub/PerlTestSub, but it runs all the tests for the
"   current file, which starts with the name of the subroutine
"   -!It changes the current directory to the project root (where t/ and lib/
"   are)
"
" Subroutine names are parsed with regex from the current line upwards.
"
" You can map these functions to any key:
"   nnoremap <leader>ptt PerlTestFile
"
" CONFIGURATION
"
"   g:test_class_perl_args
"
"       Arguments for the perl executable. Default is:
"           let g:test_class_perl_args = '-Ilib -It/lib'
"
"   g:test_class_prove_args
"
"       Arguments for the prove executable. Default is:
"           let g:test_class_prove_args = '-Ilib -It/lib'
"
"   g:test_class_path_folder
"
"       The name of the directory inside 't/', where the Test::Class test
"       modules are. Default is:
"           let g:test_class_path_folder = 'tests'
"
"   g:test_class_path_prefix
"
"       This prefix will be used for executing tests. This assumes that there
"       is a directory with this name inside the test_class_path_folder.
"       Default is:
"           let g:test_class_path_prefix = 'Test'
"

if exists('g:loaded_test_class_runner')
    finish
endif
let g:loaded_test_class_runner = 1

" Plugin settings {{{
if !exists('g:test_class_perl_args')
    let g:test_class_perl_args = '-Ilib -It/lib'
endif

if !exists('g:test_class_prove_args')
    let g:test_class_prove_args = '-Ilib -It/lib'
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

" {{{ create g:test_class_path
let g:test_class_path = g:test_class_path_folder
if g:test_class_path != ''
    let g:test_class_path = g:test_class_path . '/'
endif
if g:test_class_path_prefix != ''
    let g:test_class_path = g:test_class_path_prefix . '/'
endif
" }}}
" }}}

" Path query functions {{{
function! s:Path_inside_perl_project(path)
    return a:path =~# '^' . '.\+' . '/\(t\|lib\)/' . '.\+'
endfunction

function! s:Path_is_test_inside_t(path)
    return a:path =~# '^' . '.\+' . '/t/' . '.\+' . '\.t$'
endfunction

function! s:Path_is_module_inside_test_class_dir(path)
    return a:path =~# '^' . '.\+' . '/t/' . g:test_class_path . '.\+' . '\.pm$'
endfunction

function! s:Path_is_module_inside_lib(path)
    return a:path =~# '^' . '.\+' . '/lib/' . '.\+' . '\.pm$'
endfunction

function! s:Path_contains_test_class(path)
    return a:path =~# '/t/' . g:test_class_path
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

" Project root functions {{{
function! s:Get_project_root(path)
    " /some/path/lib/X/Y.pm => /some/path/
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

" s:RunTestFile {{{
function! s:RunTestFile(tool)
    write
    let l:path = expand('%:p')

    if s:Path_inside_perl_project(l:path)
        let l:path = s:Get_path_for(l:path)

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

" Subroutine name{{{
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
" }}}

function! ProveTestAll()
    write
    let $TEST_METHOD = ""
    let l:path = expand('%:p')

    if s:Path_inside_perl_project(l:path)
        if s:Cd_to_root(l:path)
            silent !clear
            execute ":!unbuffer prove " . g:test_class_prove_args . " t/"
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
