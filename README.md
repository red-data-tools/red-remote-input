# Red DataStock (tentative name)

## Description

Red DataStock provides a library for downloading and caching data.

## Install

```
gem install red-datastock
```

## Usage


```ruby
module YourModule
  class YourClass
    # some nice code here...

    def clear_cache!
      cache_path.remove
    end

    private

    def cache_dir_path
      cache_path.base_dir
    end

    def cache_path
      @cache_path ||= CachePath.new(@metadata.id)
    end

    def download(output_path, url)
      downloader = Downloader.new(url)
      downloader.download(output_path)
    end
  end
end
```

## Development

Pull requests are welcome.

## License

The MIT license.

