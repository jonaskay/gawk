require 'yaml'
require 'erb'

module Gawk
  class CLI
    def initialize(config_file: '.gawk.yaml', report_key: nil, engine: Gawk::Engine.new)
      @config_file = config_file
      @report_key = report_key
      @engine = engine
    end

    def output
      requests = get_data_from_config_file('request')
      tables = get_data_from_config_file('table')
      @engine.get_reports(requests).each.with_index do |report, i|
        puts generate_table(tables[i], requests, report).to_s
      end
    end

    def get_data_from_config_file(data_type)
      data = []
      if @report_key
        data << load_config_file.dig(@report_key, data_type)
      else
        load_config_file.each {|k, v| data << v.fetch(data_type) }
      end
      data
    end

    private

    def load_config_file
      erb = ERB.new(File.read(@config_file))
      YAML.load(erb.result(binding))
    end

    def generate_table(config, requests, report)
      table = Gawk::Table.new
      table.name = config['name']
      table.headings = generate_table_headings(report)
      table.rows = generate_table_rows(requests, report)
      table
    end

    def generate_table_headings(report)
      headings = []
      headings << report.column_header.dimensions.join('; ')
      report.column_header.metric_header.metric_header_entries.each do |entry|
        headings << entry.name
      end
      headings
    end

    def generate_table_rows(requests, report)
      rows = []
      if requests[0]['date_ranges'].length > 1
        # Add a row for total changes.
        rows << [
          "Total",
          report.data.totals[0].values.map.with_index do |x, i|
            get_change_in_percentage(x, report.data.totals[1].values[i])
          end
        ].flatten
        # Add data rows.
        report.data.rows.each.with_index do |row, i|
          # Add a row for dimension values.
          rows << ["#{i+1}. #{row.dimensions.join('; ')}"]
          # Add a data row for each date range.
          for j in (0..1) do
            rows << [
              get_date_range_as_string(requests[0]['date_ranges'][j]),
              row.metrics[j].values
            ].flatten
          end
          # Add a row for data changes.
          rows << [
            "% Change",
            report.column_header.metric_header.metric_header_entries.map.with_index do |entry, j|
              get_change_in_percentage(row.metrics[0].values[j], row.metrics[1].values[j])
            end
          ].flatten
        end
      else
        # Add a row for total changes.
        rows << ["Total", report.data.totals[0].values].flatten
        # Add data rows.
        report.data.rows.each.with_index do |row, i|
          rows << ["#{i+1}. #{row.dimensions.join('; ')}", row.metrics.map(&:values)].flatten
        end
      end
      rows
    end

    def get_change_in_percentage(first_value, second_value)
      if second_value == 0
        if first_value == second_value
          return "#{second_value.to_f}%"
        else
          return "∞"
        end
      else
        return "#{((first_value.to_f / second_value.to_f - 1) * 100).round(2)}%"
      end
    end

    def get_date_range_as_string(date_range)
      "#{format_date(date_range['start_date'])} - #{format_date(date_range['end_date'])}"
    end

    def format_date(date)
      Date.parse(date.to_s).strftime("%b %-d, %Y")
    end
  end
end
