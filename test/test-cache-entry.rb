require_relative "helper"

class CacheEntryTest < Test::Unit::TestCase
  data("no path",       ["example.com",     "data", "https://example.com"])
  data("root",          ["example.com",     "data", "https://example.com/"])
  data("file",          ["example.com",     "file", "https://example.com/file"])
  data("query",         ["example.com+a=-", "file", "https://example.com/file?a=+"])
  data("directory",     ["example.com-a",   "data", "https://example.com/a/"])
  data("nested file",   ["example.com-a",   "file", "https://example.com/a/file"])
  data("deeply nested", ["example.com-a-b", "file", "https://example.com/a/b/file"])
  def test_from_url(data)
    id, path_in_cache, url = data
    cache_entry = RemoteInput::CacheEntry.from_url(URI(url))
    assert_equal(RemoteInput::CacheEntry.new(id, path_in_cache),
                 cache_entry)
  end

  def test_from_valid_path
    cache_path = "example/sub-directory/data.csv"
    cache_entry = RemoteInput::CacheEntry.from_path(cache_path)
    assert_equal(RemoteInput::CacheEntry.new("example",
                                             "sub-directory/data.csv"),
                 cache_entry)
  end

  data("absolute",         "/data.csv")
  data("no cache ID",      "data.csv")
  data("no path in cache", "example/")
  data("root cache",       "./data.csv")
  data("path traversal",   "../example/data.csv")
  def test_from_invalid_path(cache_path)
    assert_raise(ArgumentError) do
      RemoteInput::CacheEntry.from_path(cache_path)
    end
  end

  def test_equal_same_path_different_id
    cache_entry1 = RemoteInput::CacheEntry.new("example.com/a", "file")
    cache_entry2 = RemoteInput::CacheEntry.new("example.com", "a/file")
    assert_equal([
                   true,
                   false,
                 ],
                 [
                   cache_entry1.path == cache_entry2.path,
                   cache_entry1 == cache_entry2,
                 ])
  end
end
