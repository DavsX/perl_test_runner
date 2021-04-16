require "vimrunner"

RSpec.describe "vim_test_runner" do
  before(:each) do
    @vim = Vimrunner.start
    @vim.add_plugin('.', 'plugin/vim_test_runner.vim')
    @vim.command("let g:test_runner_test_ext = 't'")
    @vim.command("let g:test_runner_test_dir = 'test'")
  end

  after(:each) do
    @vim.kill
  end

  describe 'is_test_file_in_test_dir' do
    it "should match" do
      dirs = [
        '/home/vim/test/example_test.t',
        '/home/vim/test/test/example_test.t',
        '/home/vim/test/something/example_test.t',
        '/home/vim/test/something/else/example_test.t',
      ]

      dirs.each do |dir|
        expect(
          @vim.command("echo vim_test_runner#is_test_file_in_test_dir('#{dir}')")
        ).to eq("1")
      end
    end

    it "should not match" do
      dirs = [
        '/test/example.t',
        '/home/vim/example_test.t',
        '/home/vim/test/example.x',
        '/home/vim/test/example.tx',
        '/home/vim/test/example.xt',
      ]

      dirs.each do |dir|
        expect(
          @vim.command("echo vim_test_runner#is_test_file_in_test_dir('#{dir}')")
        ).to eq("0")
      end
    end

    it "should handle complex stuff" do
      @vim.command("let g:test_runner_test_dir = 'spec'")
      @vim.command("let g:test_runner_test_ext = 'rb'")
      @vim.command("let g:test_runner_test_prefix = 'test_'")
      @vim.command("let g:test_runner_test_suffix = '_spec'")

      dirs = [
        '/home/vim/spec/test_stuff_spec.rb',
        '/home/vim/spec/spec/test_stuff_spec.rb',
        '/home/vim/spec/test/test_stuff_spec.rb',
        '/home/vim/spec/test/dir/test_stuff_spec.rb',
      ]

      dirs_bad = [
        '/test_stuff_spec.rb',
        '/home/vim/spec/test_spec.rb',
        '/home/vim/spec/test__spec.rb',
      ]

      dirs.each do |dir|
        expect(
          @vim.command("echo vim_test_runner#is_test_file_in_test_dir('#{dir}')")
        ).to eq("1")
      end

      dirs_bad.each do |dir|
        expect(
          @vim.command("echo vim_test_runner#is_test_file_in_test_dir('#{dir}')")
        ).to eq("0")
      end
    end
  end

end
