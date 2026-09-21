require_relative "helper"

class RemoteInputTest < Test::Unit::TestCase
  def test_read_once
    open_input do |input|
      input.local_path.parent.mkpath
      input.local_path.write("12")
      assert_equal("12", input.read)
    end
  end

  def test_read_twice
    open_input do |input|
      input.local_path.parent.mkpath
      input.local_path.write("12")
      assert_equal("1", input.read(1))
      assert_equal("2", input.read(1))
    end
  end

  def test_read_with_encoding
    open_input(encoding: "Windows-31J:UTF-8") do |input|
      input.local_path.parent.mkpath
      input.local_path.write("入力", encoding: "Windows-31J:UTF-8")
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

  class WithoutCacheTest < self
    def test_open_with_block
      local_path = nil
      open_input do |input|
        input.local_path.parent.mkpath
        input.local_path.write("12")
        local_path = input.local_path
      end
      assert do
        not local_path.parent.exist?
      end
    end

    def test_open_with_block_raised
      local_path = nil
      assert_raise(RuntimeError.new("error in block")) do
        open_input do |input|
          input.local_path.parent.mkpath
          input.local_path.write("12")
          local_path = input.local_path
          raise "error in block"
        end
      end
      assert do
        not local_path.parent.exist?
      end
    end

    def test_local_path
      open_input do |input|
        tmp_path = RemoteInput::TmpPath.new("#{Process.pid}-#{input.object_id}")
        assert_equal(tmp_path.base_dir + "data", input.local_path)
      end
    end

    def test_close_deletes_local_path
      open_input do |input|
        input.local_path.parent.mkpath
        input.local_path.write("12")
        input.close
        assert do
          not input.local_path.parent.exist?
        end
      end
    end
  end

  private

  def open_input(**options, &block)
    RemoteInput.open("https://example.com/file", **options, &block)
  end
end
