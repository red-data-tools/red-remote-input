require_relative "remote_input/cache-path"
require_relative "remote_input/downloader"
require_relative "remote_input/tmp-path"
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

  def initialize(url, fallback_urls: [], **http_options)
    @downloader = Downloader.new(url, *fallback_urls, **http_options)
    @tmp_path = TmpPath.new("#{Process.pid}-#{object_id}")
    @local_file = nil
    @closed = false
  end

  def read(maxlen=nil, out_string=nil)
    local_file.read(maxlen, out_string)
  end

  def close
    @local_file.close if @local_file and not @local_file.closed?
    @tmp_path.remove
    @closed = true
  end

  def local_path
    @tmp_path.base_dir + "data"
  end

  private

  def local_file
    raise IOError, "closed stream" if @closed
    return @local_file if @local_file
    @downloader.download(local_path)
    @local_file = local_path.open
  end
end
