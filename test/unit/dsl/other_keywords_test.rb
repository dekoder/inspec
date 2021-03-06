require "helper"
require "inspec/runner_mock"
require "inspec/runner"

describe "inspec keyword" do
  def load(content)
    runner = Inspec::Runner.new({ backend: "mock", test_collector: Inspec::RunnerMock.new })
    runner.eval_with_virtual_profile(content)
  end

  def load_in_profile(cmd)
    MockLoader.load_profile("complete-profile").runner_context.load(cmd)
  end

  it "is a vailable as a global keyword" do
    load("inspec") # wont raise anything
  end

  it "is a vailable inside of control blocks" do
    load("control 1 do inspec end") # wont raise anything
  end

  it "provides version information" do
    _(load("inspec.version")).must_equal Inspec::VERSION
  end

  it "is associated with resources" do
    i = load("os.inspec")
    _(i).wont_be_nil
    _(i.backend).must_be_kind_of Train::Transports::Mock::Connection
  end

  it "prints a nice to_s" do
    _(load("inspec").to_s).must_equal "Inspec::Backend::Class"
  end

  it "prints a nice inspect line" do
    _(load("inspec").inspect).must_equal "Inspec::Backend::Class @transport=Train::Transports::Mock::Connection"
  end

  describe "inspec.profile.files" do
    it "lists an empty array when calling #files without any files loaded" do
      _(load("inspec.profile.files")).must_equal([])
    end

    it "lists all profile files when calling #files" do
      _(load_in_profile("inspec.profile.files").sort).must_equal %w{a_sub_dir/sub_items.conf items.conf}
    end
  end

  describe "inspec.profile.file" do
    it "raises an error if a file was not found" do
      _(proc { load('inspec.profile.file("test")') }).must_raise RuntimeError
    end

    it "provides file contents when calling file(...)" do
      _(load_in_profile('inspec.profile.file("items.conf")')).must_equal "one\ntwo\nthree\n"
    end
  end
end
