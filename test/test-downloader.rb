class DownloaderTest < Test::Unit::TestCase
  include Helper::Sandbox

  sub_test_case("#initialize") do
    test("single URL") do
      url = "https://example.com/file"
      downloader = RemoteInput::Downloader.new(url)
      assert_equal(URI.parse(url), downloader.instance_variable_get(:@url))
      assert_equal([], downloader.instance_variable_get(:@fallback_urls))
    end

    test("with fallback URLs") do
      url = "https://example.com/file"
      fallback1 = "https://mirror1.example.com/file"
      fallback2 = "https://mirror2.example.com/file"
      downloader = RemoteInput::Downloader.new(url, fallback1, fallback2)
      
      assert_equal(URI.parse(url), downloader.instance_variable_get(:@url))
      assert_equal([URI.parse(fallback1), URI.parse(fallback2)], 
                   downloader.instance_variable_get(:@fallback_urls))
    end

    test("with HTTP method and parameters") do
      url = "https://example.com/api"
      parameters = { key: "value", data: "test" }
      downloader = RemoteInput::Downloader.new(url, 
                                               http_method: :post, 
                                               http_parameters: parameters)
      
      assert_equal(:post, downloader.instance_variable_get(:@http_method))
      assert_equal(parameters, downloader.instance_variable_get(:@http_parameters))
    end

    test("invalid URL") do
      assert_raise(ArgumentError) do
        RemoteInput::Downloader.new("ftp://example.com/file")
      end
    end
  end

  sub_test_case("#download") do
    def setup
      setup_sandbox
    end

    def teardown
      teardown_sandbox
    end

    test("too many redirection") do
      first_url = "https://example.com/file"
      last_url = "https://example.com/last_redirection"
      expected_message = "too many redirections: #{first_url} .. #{last_url}"
      output_path = @tmp_dir + "file"
      downloader = RemoteInput::Downloader.new(first_url)

      downloader.define_singleton_method(:start_http) do |url, fallback_urls, headers|
        raise RemoteInput::Downloader::TooManyRedirects, "too many redirections: #{last_url}"
      end

      assert_raise(RemoteInput::Downloader::TooManyRedirects.new(expected_message)) do
        downloader.download(output_path)
      end
    end

    test("use cache when file exists") do
      output_path = @tmp_dir + "cached_file"
      output_path.write("cached content")
      
      downloader = RemoteInput::Downloader.new("https://example.com/file")
      
      # Should not call start_http when file exists
      downloader.define_singleton_method(:start_http) do |url, fallback_urls, headers|
        flunk("start_http should not be called when file exists")
      end
      
      downloader.download(output_path)
      assert_equal("cached content", output_path.read)
    end

    test("yield chunks when using cache") do
      output_path = @tmp_dir + "cached_file"
      content = "chunk1chunk2chunk3"
      output_path.write(content)
      
      downloader = RemoteInput::Downloader.new("https://example.com/file")
      
      chunks = []
      downloader.download(output_path) do |chunk|
        chunks << chunk
      end
      
      assert_equal(content, chunks.join)
    end
  end

  sub_test_case("fallback URLs") do
    def setup
      setup_sandbox
    end

    def teardown
      teardown_sandbox
    end

    test("fallback URLs are stored correctly") do
      main_url = "https://example.com/file"
      fallback_url = "https://mirror.example.com/file"
      
      downloader = RemoteInput::Downloader.new(main_url, fallback_url)
      
      fallback_urls = downloader.instance_variable_get(:@fallback_urls)
      assert_equal([URI.parse(fallback_url)], fallback_urls)
    end
  end
end
