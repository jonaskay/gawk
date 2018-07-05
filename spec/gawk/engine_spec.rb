RSpec.describe Gawk::Engine do
  subject {
    Gawk::Engine.new(
      secrets_file: 'spec/fixtures/files/example_secrets.json',
      token_file: 'spec/fixtures/files/example_tokens.yaml'
    )
  }

  describe "#get_reports" do
    let(:view_id)    {'XXXX'}
    let(:metrics)    {['ga:sessions']}
    let(:dimensions) {['ga:browser']}
    let(:request) {
      {
        'viewId'      => view_id,
        'date_ranges' => [
          { 'start_date' => '2015-01-01', 'end_date' => '2015-01-31' },
          { 'start_date' => '2015-03-01', 'end_date' => '2015-03-31' },
        ],
        'metrics'     => metrics,
        'dimensions'  => dimensions
      }
    }

    it "returns service reports" do
      VCR.use_cassette('single_date_range') do
        reports = subject.get_reports([request])

        reports.each {|r| expect(r).to be_instance_of(Google::Apis::AnalyticsreportingV4::Report)}
      end
    end
  end
end
