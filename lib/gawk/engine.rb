require 'google/apis/analyticsreporting_v4'
require 'googleauth/stores/file_token_store'

module Gawk
  class Engine
    USER_ID = 'gawk'
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

    def initialize(scope: 'https://www.googleapis.com/auth/analytics.readonly',
      secrets_file: 'client_secrets.json', token_file: 'tokens.yaml')

      @secrets_file = secrets_file
      @token_file = token_file
      @authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)
      @service = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
      @service.authorization = auth_client
    end

    def get_reports(requests)
      report_requests = []
      requests.each do |r|
        report_request = Google::Apis::AnalyticsreportingV4::ReportRequest.new

        report_request.view_id            = r['view_id'].to_s
        report_request.date_ranges        = r['date_ranges'].map {|h| generate_date_range(h)}
        report_request.dimensions         = r['dimensions'].map {|s| generate_dimension(s)}
        report_request.metrics            = r['metrics'].map {|s| generate_metric(s)}
        report_request.filters_expression = r['filters_expression']

        report_requests << report_request

      end

      get_reports_request = \
        Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(report_requests: report_requests)

      response = @service.batch_get_reports(get_reports_request)

      response.reports
    end

    private

    def client_id
      Google::Auth::ClientId.from_file(@secrets_file)
    end

    def token_store
      Google::Auth::Stores::FileTokenStore.new(file: @token_file)
    end

    def auth_client
      credentials = @authorizer.get_credentials(USER_ID)
      if credentials.nil?
        url = @authorizer.get_authorization_url(base_url: OOB_URI )
        puts "Open #{url} in your browser and enter the resulting code:"
        code = gets
        credentials = @authorizer.get_and_store_credentials_from_code(
                        user_id: USER_ID,
                        code: code,
                        base_url: OOB_URI
                      )
      end
      credentials
    end

    def generate_date_range(hash)
      Google::Apis::AnalyticsreportingV4::DateRange.new(
        start_date: format_date(hash['start_date']),
        end_date: format_date(hash['end_date'])
      )
    end

    def format_date(date)
      Date.parse(date.to_s).strftime
    end

    def generate_dimension(name)
      Google::Apis::AnalyticsreportingV4::Dimension.new(name: name)
    end

    def generate_metric(expression)
      Google::Apis::AnalyticsreportingV4::Metric.new(expression: expression)
    end
  end
end
