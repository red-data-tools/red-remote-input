require_relative "remote_input/cache-entry"
require_relative "remote_input/cache-path"
require_relative "remote_input/downloader"
require_relative "remote_input/zip-extractor"

class RemoteInput
  class << self
    def open(...)
      input = new(...)
      if block_given?
        begin
          yield(input)
        ensure
          input.close
        end
      else
        input
      end
    end
  end

  def initialize(url,
                 *fallback_urls,
                 cache_path: nil,
                 encoding: nil,
                 internal_encoding: nil,
                 external_encoding: nil,
                 **http_options)
    @encoding = encoding
    @internal_encoding = internal_encoding
    @external_encoding = external_encoding
    @downloader = Downloader.new(url, *fallback_urls, **http_options)
    if cache_path
      @cache_entry = CacheEntry.new(Pathname(cache_path))
    else
      @cache_entry = CacheEntry.new(URI(url))
    end
    @local_file = nil
    @closed = false
  end

  def read(maxlen=nil, out_string=nil)
    local_file.read(maxlen, out_string)
  end

  def each_chunk(&block)
    return to_enum(__method__) unless block_given?
    download(&block)
  end

  def close
    @local_file.close if @local_file and not @local_file.closed?
    @closed = true
  end

  def clear_cache
    @cache_entry.remove
  end

  private

  def path
    @cache_entry.path
  end

  def download(&block)
    raise IOError, "closed stream" if @closed
    @downloader.download(path, &block)
  end

  def local_file
    return @local_file if @local_file
    download
    options = {}
    options[:encoding] = @encoding if @encoding
    options[:internal_encoding] = @internal_encoding if @internal_encoding
    options[:external_encoding] = @external_encoding if @external_encoding
    @local_file = path.open(**options)
  end
end
