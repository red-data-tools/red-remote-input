require_relative "cache-path"

class RemoteInput
  # @api private
  class CacheEntry
    def initialize(target)
      if target.is_a?(URI)
        initialize_url(target)
      elsif target.is_a?(Pathname)
        initialize_path(target)
      else
        raise ArgumentError,
              "target must be URI or Pathname: #{target.inspect}"
      end
      @cache_path = CachePath.new(@id)
    end

    def path
      @cache_path.base_dir + @path_in_cache
    end

    def remove
      @cache_path.remove
    end

    def ==(other)
      other.is_a?(self.class) and
        @id == other.id and
        @path_in_cache == other.path_in_cache
    end

    protected
    attr_reader :id
    attr_reader :path_in_cache

    private
    def initialize_url(url)
      url_path = url.path
      url_path = "/" if url_path.empty?
      url_path += "data" if url_path.end_with?("/")
      dirname = File.dirname(url_path).delete_suffix("/")
      @id = to_id("#{url.host}#{dirname}")
      query = url.query
      @id += "+#{to_id(query)}" if query and not query.empty?
      @path_in_cache = File.basename(url_path)
    end

    def initialize_path(path)
      if path.absolute?
        raise ArgumentError,
              "cache path must be relative: #{path.inspect}"
      end
      @id, *rest_filenames = path.each_filename.to_a
      if [@id, *rest_filenames].intersect?([".", ".."])
        raise ArgumentError,
              "cache path must not include '.' or '..': #{path.inspect}"
      end
      if rest_filenames.empty?
        raise ArgumentError,
              "cache path must be <cache ID>/<path in cache>: " +
              path.inspect
      end
      @path_in_cache = File.join(*rest_filenames)
    end

    def to_id(s)
      allow_list = "0-9A-Za-z._~=-"
      s.tr("^#{allow_list}", "-")
    end
  end
end
