RSpec.describe Gawk do
  example "get reports" do
    VCR.use_cassette('example_response') do
      cli = Gawk::CLI.new
      cli.output
    end
  end
end
