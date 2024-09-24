require "csv"

module TranslationTools
  class ComparesCSVs
  def self.compare(csv1, csv2, identifier_columns, columns_to_compare, comparison_class = DefaultComparer)
    Result.new.tap do |result|
      csv1_data = CSV.parse(csv1, headers: true)
      csv2_data = CSV.parse(csv2, headers: true)

      csv1_id_column, csv2_id_column = identifier_columns

      all_identifiers = csv1_data.map { |row| row.fetch(csv1_id_column) } |
        csv2_data.map { |row| row.fetch(csv2_id_column) }

      all_identifiers.uniq.each do |identifier|
        row1 = csv1_data.find { |r| r[csv1_id_column] == identifier }
        row2 = csv2_data.find { |r| r[csv2_id_column] == identifier }

        identifier_presence = if row1.nil? && row2.nil?
          :none
        elsif row1.nil?
          :csv2
        elsif row2.nil?
          :csv1
        else
          :both
        end

        if identifier_presence == :none
          result.add_difference(Difference.new(identifier: identifier, message: "Row not found in either CSV", identifier_presence: identifier_presence))
        elsif identifier_presence != :both
          result.add_difference(Difference.new(identifier: identifier, message: "Row not found in #{(identifier_presence == :csv1) ? "second" : "first"} CSV", identifier_presence: identifier_presence))
        else
          columns_to_compare.each do |csv1_column, csv2_column|
            csv2_column ||= csv1_column
            value1 = row1.fetch(csv1_column)
            value2 = row2.fetch(csv2_column)

            unless comparison_class.equal?(value1.to_s, value2.to_s)
              result.add_difference(
                Difference.new(
                  identifier: identifier,
                  column: "#{csv1_column}/#{csv2_column}",
                  csv1_value: value1,
                  csv2_value: value2,
                  csv1_column: csv1_column,
                  csv2_column: csv2_column,
                  identifier_presence: identifier_presence
                )
              )
            end
          end
        end
      end
    end
  end

  class Result
    include Enumerable
    attr_reader :differences

    def initialize
      @differences = []
    end

    def add_difference(difference)
      @differences << difference
    end

    def each(&block)
      @differences.each(&block)
    end

    def size
      @differences.size
    end

    def empty?
      @differences.empty?
    end
  end

  class Difference
    attr_reader :identifier, :column, :csv1_value, :csv2_value, :message, :csv1_column, :csv2_column, :identifier_presence

    def initialize(identifier:, identifier_presence:, column: nil, csv1_value: nil, csv2_value: nil, message: nil, csv1_column: nil, csv2_column: nil)
      @identifier = identifier
      @column = column
      @csv1_value = csv1_value
      @csv2_value = csv2_value
      @message = message
      @csv1_column = csv1_column
      @csv2_column = csv2_column
      @identifier_presence = identifier_presence
    end

    def inspect
      if @message
        "Difference(identifier: #{@identifier}, message: #{@message}, identifier_presence: #{@identifier_presence})"
      else
        "Difference(identifier: #{@identifier}, column: #{@column}, csv1_value: #{@csv1_value}, csv2_value: #{@csv2_value}, csv1_column: #{@csv1_column}, csv2_column: #{@csv2_column}, identifier_presence: #{@identifier_presence})"
      end
    end
  end

  module DefaultComparer
    def self.equal?(str1, str2)
      str1 == str2
    end
  end
  end
end
