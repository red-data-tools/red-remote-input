require_relative "helper"

class RemoteInputTest < Test::Unit::TestCase
  include Helper::Sandbox

  def setup
    setup_sandbox
    cache_dir = ENV["RED_REMOTE_INPUT_CACHE_DIR"]
    ENV["RED_REMOTE_INPUT_CACHE_DIR"] = @tmp_dir.to_s
    begin
      yield
    ensure
      ENV["RED_REMOTE_INPUT_CACHE_DIR"] = cache_dir
      teardown_sandbox
    end
  end

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

  def test_read_after_read_and_close
    open_input do |input|
      input.send(:path).parent.mkpath
      input.send(:path).write("12")
      input.read
      input.close
      assert_raise(IOError.new("closed stream")) do
        input.read
      end
    end
  end

  def test_each_chunk
    open_input do |input|
      expected_chunks = ["1" * (1024 * 1024), "2"]
      input.send(:path).parent.mkpath
      input.send(:path).write(expected_chunks.join)
      input.each_chunk do |chunk|
        assert_equal(expected_chunks.shift, chunk)
      end
      assert_empty(expected_chunks)
    end
  end

  def test_each_chunk_without_block
    open_input do |input|
      input.send(:path).parent.mkpath
      input.send(:path).write("12")
      assert_equal("12", input.each_chunk.first)
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

  def test_cache_path
    open_input(cache_path: "example/sub-directory/data.csv") do |input|
      assert_equal(@tmp_dir + "red-remote-input/example/sub-directory/data.csv",
                   input.send(:path))
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

  def open_input(**options, &block)
    RemoteInput.open("https://example.com/file", **options, &block)
  end
end
