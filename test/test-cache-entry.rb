require_relative "helper"

class CacheEntryTest < Test::Unit::TestCase
  data("no path",     ["example.com/data",     "https://example.com"])
  data("root",        ["example.com/data",     "https://example.com/"])
  data("file",        ["example.com/file",     "https://example.com/file"])
  data("query",       ["example.com+a=-/file", "https://example.com/file?a=+"])
  data("directory",   ["example.com-a/data",   "https://example.com/a/"])
  data("nested file", ["example.com-a/file",   "https://example.com/a/file"])
  data("nested dir",  ["example.com-a-b/file", "https://example.com/a/b/file"])
  def test_url_equal_path(data)
    cache_path, url = data
    assert_equal(RemoteInput::CacheEntry.new(Pathname(cache_path)),
                 RemoteInput::CacheEntry.new(URI(url)))
  end

  def test_path_split
    cache_path = Pathname("example/sub-directory/data.csv")
    cache_entry = RemoteInput::CacheEntry.new(cache_path)
    assert_equal(["example", "sub-directory/data.csv"],
                 [cache_entry.send(:id), cache_entry.send(:path_in_cache)])
  end

  data("absolute",         "/data.csv")
  data("no cache ID",      "data.csv")
  data("no path in cache", "example/")
  data("root cache",       "./data.csv")
  data("path traversal",   "../example/data.csv")
  def test_invalid_path(cache_path)
    assert_raise(ArgumentError) do
      RemoteInput::CacheEntry.new(Pathname(cache_path))
    end
  end

  def test_invalid_target
    assert_raise(ArgumentError) do
      RemoteInput::CacheEntry.new("https://example.com/file")
    end
  end
end
