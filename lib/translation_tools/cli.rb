require "optparse"
require "csv"
require "diffy"

require_relative "compares_unicodey_strings"
require_relative "compares_csvs"
require_relative "diff_generator"

module TranslationTools
  class CLI
    def initialize
      @options = {}
    end

    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} [options] <string1> <string2> OR <csv1_path> <csv2_path>"

        opts.on("-v", "--verbose", "Run verbosely") do
          @options[:verbose] = true
        end

        opts.on("-c", "--csv", "Compare CSVs") do
          @options[:csv] = true
        end

        opts.on("-i", "--identifier COLUMN[S]", "Identifier column(s) for CSV comparison (format: column or csv1_col:csv2_col)") do |columns|
          @options[:identifier] = columns.include?(":") ? columns.split(":") : [columns, columns]
        end

        opts.on("-m", "--compare COLUMNS", Array, "Columns to compare in CSV (format: csv1_col:csv2_col or just col for same name)") do |columns|
          @options[:compare_columns] = columns.map do |col|
            if col.include?(":")
              col.split(":", 2)
            else
              [col, col]
            end
          end
        end

        opts.on("--format FORMAT", "Output format (e.g., CSV, DIFF, HTML)") do |format|
          @options[:format] = format.upcase
        end

        opts.on("-h", "--help", "Show this help message") do
          puts opts
          exit
        end
      end.parse!

      @options[:arg1] = ARGV.shift
      @options[:arg2] = ARGV.shift
    end

    def run
      parse_options

      if @options[:arg1].nil? || @options[:arg2].nil?
        puts "Error: Two arguments are required for comparison."
        puts "Usage: #{$PROGRAM_NAME} [options] <string1> <string2> OR <csv1_path> <csv2_path>"
        exit 1
      end

      differences_count = if @options[:csv]
        compare_csvs
      else
        compare_strings
      end

      exit differences_count
    end

    private

    def compare_strings
      result = ComparesUnicodeyStrings.equal?(@options[:arg1], @options[:arg2])
      puts "String 1: #{@options[:arg1]}"
      puts "String 2: #{@options[:arg2]}"
      puts "Result: #{result ? "Equal" : "Not equal"}"
      result ? 0 : 1
    end

    def compare_csvs
      unless @options[:identifier] && @options[:compare_columns]
        puts "Error: CSV comparison requires --identifier and --compare options."
        exit 1
      end

      csv1 = File.read(@options[:arg1])
      csv2 = File.read(@options[:arg2])

      differences = ComparesCSVs.compare(
        csv1,
        csv2,
        @options[:identifier],
        @options[:compare_columns],
        ComparesUnicodeyStrings
      )

      if differences.empty?
        puts "CSVs are identical for the specified columns."
      else
        case @options[:format]
        when "CSV"
          output_csv_differences(differences)
        when "DIFF", "HTML"
          output_diff_differences(differences)
        else
          puts "Differences found:"
          differences.each do |diff|
            puts diff.inspect
          end
        end
      end

      differences.size
    end

    def output_csv_differences(differences)
      return unless @options[:format] == "CSV"
      headers = [
        *@options[:identifier],
        *@options[:compare_columns].flatten,
        "Notes",
        "Identifier Presence"
      ]

      CSV do |csv|
        csv << headers
        differences.each do |diff|
          row = [
            diff.identifier,
            diff.identifier,
            *@options[:compare_columns].map { |col| [diff.csv1_value, diff.csv2_value] }.flatten,
            diff.message || "Values differ",
            diff.identifier_presence
          ]
          csv << row
        end
      end
    end

    def output_diff_differences(differences)
      return unless ["DIFF", "HTML"].include?(@options[:format])

      if @options[:format] == "HTML"
        output_html_differences(differences)
      else
        differences.each do |diff|
          puts "Difference for identifier: #{diff.identifier} (Present in: #{diff.identifier_presence})"
          puts "Column: #{diff.column}"
          puts DiffGenerator.generate_diff(diff.csv1_value.to_s, diff.csv2_value.to_s)
          puts
        end
      end
    end

    def output_html_differences(differences)
      html_output = <<~HTML
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>CSV Differences</title>
          <style>
            body { font-family: Arial, sans-serif; }
            .diff { margin-bottom: 20px; }
            .diff-header { font-weight: bold; }
            .identifier-presence { font-style: italic; }
            #{Diffy::CSS}
          </style>
        </head>
        <body>
          <h1>CSV Differences</h1>
      HTML

      differences.each do |diff|
        html_output << <<~HTML
          <div class="diff">
            <p class="diff-header">Difference for identifier: #{diff.identifier}</p>
            <p class="identifier-presence">Present in: #{diff.identifier_presence}</p>
            <p>Column: #{diff.column}</p>
            #{DiffGenerator.generate_diff(diff.csv1_value.to_s, diff.csv2_value.to_s, format: :html)}
          </div>
        HTML
      end

      html_output << "</body></html>"

      output_file = "csv_differences.html"
      File.write(output_file, html_output)
      puts "HTML output has been saved to #{output_file}"
    end
  end
end
