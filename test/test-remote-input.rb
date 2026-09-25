require_relative "helper"

class RemoteInputTest < Test::Unit::TestCase
  def test_read_once
    open_input do |input|
      input.send(:path).parent.mkpath
      input.send(:path).write("12")
      assert_equal("12", input.read)
    end
  end

  def test_read_twice
    open_input do |input|
      input.send(:path).parent.mkpath
      input.send(:path).write("12")
      assert_equal("1", input.read(1))
      assert_equal("2", input.read(1))
    end
  end

  def test_read_with_encoding
    open_input(encoding: "Windows-31J:UTF-8") do |input|
      input.send(:path).parent.mkpath
      input.send(:path).write("入力", encoding: "Windows-31J:UTF-8")
      assert_equal("入力", input.read)
    end
  end

  def test_read_after_close
    open_input do |input|
      input.close
      assert_raise(IOError.new("closed stream")) do
        input.read
      end
    end
  end

  def test_open_with_block
    opened_input = nil
    open_input do |input|
      opened_input = input
    end
    assert_raise(IOError.new("closed stream")) do
      opened_input.read
    end
  end

  def test_open_with_block_raised
    opened_input = nil
    assert_raise(RuntimeError.new("error in block")) do
      open_input do |input|
        opened_input = input
        raise "error in block"
      end
    end
    assert_raise(IOError.new("closed stream")) do
      opened_input.read
    end
  end

  data("no path",       ["/example.com/data",     "https://example.com"])
  data("root",          ["/example.com/data",     "https://example.com/"])
  data("file",          ["/example.com/file",     "https://example.com/file"])
  data("query",         ["/example.com/file",     "https://example.com/file?a=b"])
  data("directory",     ["/example.com-a/data",   "https://example.com/a/"])
  data("nested file",   ["/example.com-a/file",   "https://example.com/a/file"])
  data("deeply nested", ["/example.com-a-b/file", "https://example.com/a/b/file"])
  def test_path(data)
    expected, url = data
    RemoteInput.open(url) do |input|
      assert do
        input.send(:path).to_s.end_with?(expected)
      end
    end
  end

  def test_clear_cache
    open_input do |input|
      input.send(:path).parent.mkpath
      input.send(:path).write("1")
      input.clear_cache
      assert do
        not input.send(:path).parent.exist?
      end
    end
  end

  private

  def open_input(**options)
    input = RemoteInput.open("https://example.com/file", **options)
    begin
      yield(input)
    ensure
      input.close
      input.clear_cache
    end
  end
end
