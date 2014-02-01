test_class_runner
=================

Running Test::Class style perl tests from vim


When editing any file in project directory
    -> ProveTestAll()     => prove t/
When editing lib/My/Module.pm
OK  -> PerlTestFile()     => perl t/tests/Test/My/Module.pm
OK  -> ProveTestFile()    => prove t/tests/Test/My/Module.pm
    -> PerlTestSub()      => $ENV{TEST_METHOD} = name of closest sub, then PerlTestFile
    -> ProveTestSub()     => $ENV{TEST_METHOD} = name of closest sub, then PerlProveFile
    -> OpenTestFile()     => vsplit t/tests/Test/My/Module.pm or create and then vsplit
    -> CreateTestClass()  => create t/my_module.t
                          => create t/tests/Test/My/Module.pm
When editing t/tests/Test/My/Module.pm
OK  -> PerlTestFile()     => perl t/tests/Test/My/Module.pm
OK  -> ProveTestFile()    => prove t/tests/Test/My/Module.pm
    -> PerlTestSub()      => $ENV{TEST_METHOD} = name of closest __Test__ sub, then PerlTestFile
    -> ProveTestSub()     => $ENV{TEST_METHOD} = name of closest __Test__ sub, then PerlProveFile
    -> OpenModuleFile()   => vsplit lib/My/Module.pm or create and then vsplit
When editing t/any/test.t
OK  -> PerlTestFile()     => perl t/any/test.t
OK  -> ProveTestFile()    => prove t/any/test.t
When editing t/lib/Any.pm
OK  => no action

let g:test_class_prove_args = "-Ilib -It/lib -j9"
let g:test_class_perl_args  = "-Ilib -It/lib"
let g:test_class_path       = "t/Test/"
