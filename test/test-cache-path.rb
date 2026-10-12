require_relative "helper"

class CachePathTest < Test::Unit::TestCase
  def test_custom_cache_dir
    cache_dir = ENV["RED_REMOTE_INPUT_CACHE_DIR"]
    ENV["RED_REMOTE_INPUT_CACHE_DIR"] = Dir.tmpdir
    begin
      assert_equal(Pathname(Dir.tmpdir) + "red-remote-input/example",
                   RemoteInput::CachePath.new("example").base_dir)
    ensure
      ENV["RED_REMOTE_INPUT_CACHE_DIR"] = cache_dir
    end
  end
end
