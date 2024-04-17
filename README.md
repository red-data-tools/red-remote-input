# Red DataStock

## Description

Red DataStock is a Ruby library designed to manage data download, cache, and extraction from specific URLs.
Useful when you need to consistently retrieve, cache, and process data files from the Internet.

## Installation

To install Red DataStock:

```
gem install red-datastock
```

## Usage

To use Red DataStock in your code, you need to require it first:

```rb
require 'datastock'
```

Now you can use the `Downloader`, `CachePath`, and `ZipExtractor` classes for managing your data.

Here's an example of how to download, cache, and extract a zip file using Red DataStock:

```rb
require 'datastock'

# Prepare the Downloader with your desired URL
downloader = DataStock::Downloader.new("http://example.com/data.zip")

# Define where you want to cache the downloaded data
cache_path = DataStock::CachePath.new("my_data_id")

# Define your output path
output_path = cache_path.base_dir + "data.zip"

# Download and cache the data if it's not already cached
downloader.download(cache_path) unless File.exist?(output_path)

# Prepare the ZipExtractor with your cached data
zip_extractor = DataStock::ZipExtractor.new(output_path)

# Extract files from the zip
zip_extractor.extract_files do |input|
  # Your code to process each input file
end

# Clean up the cache directory
cache_path.clean
```

In this example, we download a zip file from `http://example.com/data.zip`, store it in a cache directory, and then extract all files from the zip. You can replace the URL with your actual data source.

## Contributing

Please create a fork, make your proposed changes, and submit a pull request.

## License

The MIT License
