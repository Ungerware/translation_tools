require_relative "test_helper"

module TranslationTools
  class ComparesCSVsTest < Minitest::Test
    def setup
      @csv1 = <<~CSV
        id,name,age
        1,Alice,30
        2,Bob,25
        3,Charlie,35
      CSV

      @csv2 = <<~CSV
        id,name,age
        1,Alice,30
        2,Bob,26
        4,David,40
      CSV
    end

    def test_identical_csvs
      result = ComparesCSVs.compare(@csv1, @csv1, ["id", "id"], ["name", "age"])
      assert_instance_of ComparesCSVs::Result, result
      assert result.empty?, "Expected no differences for identical CSVs"
    end

    def test_csvs_with_differences
      result = ComparesCSVs.compare(@csv1, @csv2, ["id", "id"], ["name", "age"])
      assert_instance_of ComparesCSVs::Result, result
      assert_equal 3, result.size, "Expected 3 differences"

      differences = result.differences
      assert_instance_of ComparesCSVs::Difference, differences[0]
      assert_equal "2", differences[0].identifier
      assert_equal "age/age", differences[0].column
      assert_equal "25", differences[0].csv1_value
      assert_equal "26", differences[0].csv2_value

      assert_instance_of ComparesCSVs::Difference, differences[1]
      assert_equal "3", differences[1].identifier
      assert_equal "Row not found in second CSV", differences[1].message

      assert_instance_of ComparesCSVs::Difference, differences[2]
      assert_equal "4", differences[2].identifier
      assert_equal "Row not found in first CSV", differences[2].message
    end

    def test_compare_specific_columns
      result = ComparesCSVs.compare(@csv1, @csv2, ["id", "id"], [["name"]])
      assert_instance_of ComparesCSVs::Result, result
      assert_equal 2, result.size, "Expected 2 differences when comparing only 'name' column"

      differences = result.differences
      assert_equal "3", differences[0].identifier
      assert_equal "Row not found in second CSV", differences[0].message
      assert_equal "4", differences[1].identifier
      assert_equal "Row not found in first CSV", differences[1].message
    end

    def test_compare_columns_with_different_names
      csv1 = <<~CSV
        id,first_name,age
        1,Alice,30
        2,Bob,25
      CSV

      csv2 = <<~CSV
        id,last_name,years
        1,Smith,30
        2,Johnson,26
      CSV

      result = ComparesCSVs.compare(csv1, csv2, ["id", "id"], [["first_name", "last_name"], ["age", "years"]])
      assert_instance_of ComparesCSVs::Result, result
      assert_equal 3, result.size, "Expected 3 differences"

      differences = result.differences
      assert_equal "1", differences[0].identifier
      assert_equal "first_name/last_name", differences[0].column
      assert_equal "Alice", differences[0].csv1_value
      assert_equal "Smith", differences[0].csv2_value

      assert_equal "2", differences[1].identifier
      assert_equal "first_name/last_name", differences[1].column
      assert_equal "Bob", differences[1].csv1_value
      assert_equal "Johnson", differences[1].csv2_value

      assert_equal "2", differences[2].identifier
      assert_equal "age/years", differences[2].column
      assert_equal "25", differences[2].csv1_value
      assert_equal "26", differences[2].csv2_value
    end

    def test_empty_csvs
      empty_csv = ""
      result = ComparesCSVs.compare(empty_csv, empty_csv, ["id", "id"], ["name", "age"])
      assert_instance_of ComparesCSVs::Result, result
      assert result.empty?, "Expected no differences for empty CSVs"
    end

    def test_csvs_with_different_headers
      csv_different_headers = <<~CSV
        id,full_name,years
        1,Alice,30
        2,Bob,25
        3,Charlie,35
      CSV
      assert_raises(KeyError) do
        ComparesCSVs.compare(@csv1, csv_different_headers, ["id", "id"], ["name", "age"])
      end
    end

    def test_result_enumerable
      result = ComparesCSVs.compare(@csv1, @csv2, ["id", "id"], ["name", "age"])
      assert_respond_to result, :each
      assert_respond_to result, :map
      assert_respond_to result, :any?

      identifiers = result.map(&:identifier)
      assert_equal ["2", "3", "4"], identifiers

      assert result.any? { |diff| diff.message == "Row not found in second CSV" }
    end

    def test_difference_inspect
      result = ComparesCSVs.compare(@csv1, @csv2, ["id", "id"], ["name", "age"])
      differences = result.differences

      assert_equal "Difference(identifier: 2, column: age/age, csv1_value: 25, csv2_value: 26, csv1_column: age, csv2_column: age, identifier_presence: both)", differences[0].inspect
      assert_equal "Difference(identifier: 3, message: Row not found in second CSV, identifier_presence: csv1)", differences[1].inspect
      assert_equal "Difference(identifier: 4, message: Row not found in first CSV, identifier_presence: csv2)", differences[2].inspect
    end

    def test_different_identifier_column_names
      csv1 = <<~CSV
        id,name,age
        1,Alice,30
        2,Bob,25
      CSV

      csv2 = <<~CSV
        identifier,name,age
        1,Alice,30
        2,Bob,26
      CSV

      result = ComparesCSVs.compare(csv1, csv2, ["id", "identifier"], ["name", "age"])
      assert_instance_of ComparesCSVs::Result, result
      assert_equal 1, result.size, "Expected 1 difference"

      difference = result.differences.first
      assert_equal "2", difference.identifier
      assert_equal "age/age", difference.column
      assert_equal "25", difference.csv1_value
      assert_equal "26", difference.csv2_value
    end

    def test_with_unicodey_string_comparison
      csv1 = <<~CSV
        id,name
        1,café
        2,résumé
      CSV

      csv2 = <<~CSV
        id,name
        1,caf\u00E9
        2,r\u00E9sum\u00E9
      CSV

      result = ComparesCSVs.compare(csv1, csv2, ["id", "id"], ["name"], ComparesUnicodeyStrings)
      assert_instance_of ComparesCSVs::Result, result
      assert result.empty?, "Expected no differences when using ComparesUnicodeyStrings"
    end
  end
end
