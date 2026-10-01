require_relative "cache-path"

class RemoteInput
  # @api private
  class CacheEntry
    class << self
      def from_url(url)
        url = URI(url)
        path = url.path
        path = "/" if path.empty?
        path += "data" if path.end_with?("/")
        dirname = File.dirname(path).delete_suffix("/")
        id = to_id("#{url.host}#{dirname}")
        query = url.query
        id += "+#{to_id(query)}" if query and not query.empty?
        new(id, File.basename(path))
      end

      def from_path(cache_path)
        path = Pathname(cache_path)
        if path.absolute?
          raise ArgumentError,
                "cache_path must be relative: #{cache_path.inspect}"
        end
        id, *rest_filenames = path.each_filename.to_a
        if [id, *rest_filenames].intersect?([".", ".."])
          raise ArgumentError,
                "cache_path must not include '.' or '..': #{cache_path.inspect}"
        end
        if rest_filenames.empty?
          raise ArgumentError,
                "cache_path must be <cache ID>/<path in cache>: " +
                cache_path.inspect
        end
        new(id, File.join(*rest_filenames))
      end

      private
      def to_id(s)
        allow_list = "0-9A-Za-z._~=-"
        s.tr("^#{allow_list}", "-")
      end
    end

    def initialize(id, path_in_cache)
      @id = id
      @path_in_cache = path_in_cache
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
  end
end
