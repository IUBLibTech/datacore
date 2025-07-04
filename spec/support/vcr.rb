require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.ignore_localhost = true
  c.ignore_hosts 'fcrepo', 'solr', 'redis', 'chrome'
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :once }
  c.hook_into :webmock
end
