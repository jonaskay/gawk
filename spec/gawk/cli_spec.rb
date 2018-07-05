RSpec.describe Gawk::CLI do
  let(:engine) {
    Gawk::Engine.new(
      secrets_file: 'spec/fixtures/files/example_secrets.json',
      token_file: 'spec/fixtures/files/example_tokens.yaml'
    )
  }
  let(:config_file) {'spec/fixtures/files/example_config.yaml'}

  subject {Gawk::CLI.new(config_file: config_file, engine: engine)}

  describe "#output" do
    let(:report) {
      Google::Apis::AnalyticsreportingV4::Report.new(
        data: Google::Apis::AnalyticsreportingV4::ReportData.new(
          totals: Google::Apis::AnalyticsreportingV4::DateRangeValues.new(values: [42])
        )
      )
    }

    context "when there is a single date range" do
      subject {Gawk::CLI.new(config_file: config_file, report_key: 'first', engine: engine)}

      it "outputs the reports" do
        VCR.use_cassette('single_date_range') do
          expect {subject.output}.to output(<<-TEXT

=====================================
Single Date Range
-------------------------------------
ga:browser                ga:sessions

Total                     3866
1. Firefox                2161
2. Internet Explorer      1705
TEXT
          ).to_stdout
        end
      end
    end

    context "when there are multiple date ranges" do
      subject {Gawk::CLI.new(config_file: config_file, report_key: 'second', engine: engine)}

      it "outputs the reports" do
        VCR.use_cassette('multiple_date_ranges') do
          expect {subject.output}.to output(<<-TEXT

===========================================
Multiple Date Ranges
-------------------------------------------
ga:browser                      ga:sessions

Total                           -7.73%
1. Firefox
Jan 1, 2015 - Jan 31, 2015      2161
Mar 1, 2015 - Mar 31, 2015      2171
% Change                        -0.46%
2. Internet Explorer
Jan 1, 2015 - Jan 31, 2015      1705
Mar 1, 2015 - Mar 31, 2015      2019
% Change                        -15.55%
TEXT
          ).to_stdout
        end
      end
    end
  end

  describe "#get_requests_from_config_file" do
    let(:table)       {{ 'name' => 'Single Date Range' }}
    let(:other_table) {{ 'name' => 'Multiple Date Ranges' }}
    let(:request) {
      {
        'view_id' => 'XXXX',
        'date_ranges' => [
          {
            'start_date' => Date.new(2015,6,15),
            'end_date' => Date.new(2015,6,30)
          }
        ],
        'dimensions' => ['ga:browser'],
        'metrics' => ['ga:sessions']
      }
    }
    let(:other_request) {
      {
        'view_id' => 'XXXX',
        'date_ranges' => [
          {
            'start_date' => Date.new(2015,1,1),
            'end_date' => Date.new(2015,1,31)
          },
          {
            'start_date' => Date.new(2015,3,1),
            'end_date' => Date.new(2015,3,31)
          }
        ],
        'dimensions' => ['ga:browser'],
        'metrics' => ['ga:sessions']
      }
    }

    context "when report_key is nil" do
      it "returns requests" do
        result = subject.get_data_from_config_file('request')

        expect(result).to eq([request, other_request])
      end

      it "returns tables" do
        result = subject.get_data_from_config_file('table')

        expect(result).to eq([table, other_table])
      end
    end

    context "when report_key is not nil" do
      subject {
        Gawk::CLI.new(config_file: config_file, report_key: 'first', engine: engine)
      }

      it "returns requests" do
        result = subject.get_data_from_config_file('request')

        expect(result).to eq([request])
      end

      it "returns tables" do
        result = subject.get_data_from_config_file('table')

        expect(result).to eq([table])
      end
    end
  end

  describe "#get_change_in_percentage" do
    context "second_values is 0" do
      context "first_value is 0" do
        it "returns 0.0" do
          result = subject.send(:get_change_in_percentage, 0, 0)

          expect(result).to eq("0.0%")
        end
      end

      context "first_value is not 0" do
        it "returns infinity" do
          result = subject.send(:get_change_in_percentage, 1,0)

          expect(result).to eq("∞")
        end
      end
    end

    context "second_value is not 0" do
      it "returns the percentage change" do
        result = subject.send(:get_change_in_percentage, 4, 3)

        expect(result).to eq("33.33%")
      end
    end
  end
end
