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
                 encoding: nil,
                 internal_encoding: nil,
                 external_encoding: nil,
                 **http_options)
    @url = URI(url)
    @encoding = encoding
    @internal_encoding = internal_encoding
    @external_encoding = external_encoding
    @downloader = Downloader.new(url, *fallback_urls, **http_options)
    @cache_path = nil
    @local_file = nil
    @closed = false
  end

  def read(maxlen=nil, out_string=nil)
    local_file.read(maxlen, out_string)
  end

  def close
    @local_file.close if @local_file and not @local_file.closed?
    @closed = true
  end

  def clear_cache
    cache_path.remove
  end

  private

  def local_path
    cache_path.base_dir + File.basename(normalize_path)
  end

  def cache_path
    return @cache_path if @cache_path
    dirname = File.dirname(normalize_path).delete_suffix("/")
    cache_id = "#{@url.host}#{dirname}".tr("/", "-")
    @cache_path = CachePath.new(cache_id)
  end

  def normalize_path
    path = @url.path
    path = "/" if path.empty?
    path += "data" if path.end_with?("/")
    path
  end

  def local_file
    raise IOError, "closed stream" if @closed
    return @local_file if @local_file
    @downloader.download(local_path)
    options = {}
    options[:encoding] = @encoding if @encoding
    options[:internal_encoding] = @internal_encoding if @internal_encoding
    options[:external_encoding] = @external_encoding if @external_encoding
    @local_file = local_path.open(**options)
  end
end
