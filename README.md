# CSV Comparison Tool

This command-line tool allows you to compare two CSV files or two strings, with support for Unicode characters and various output formats.

## Features

- Compare two strings for equality, considering Unicode characters
- Compare two CSV files, focusing on specific columns
- Output differences in various formats: plain text, CSV, colored diff, or HTML
- Flexible identifier column specification for CSV comparisons

## Installation

1. Ensure you have Ruby installed on your system.
2. Clone this repository or download the source code.
3. Install the required gems:

```bash
bundle install
```

## Usage

```
ruby main.rb [options] <string1> <string2> OR <csv1_path> <csv2_path>
```

### Options

- `-v`, `--verbose`: Run verbosely
- `-c`, `--csv`: Compare CSVs (required for CSV comparison)
- `-i`, `--identifier COLUMN[S]`: Identifier column(s) for CSV comparison (format: column or csv1_col:csv2_col)
- `-m`, `--compare COLUMNS`: Columns to compare in CSV (format: csv1_col:csv2_col or just col for same name)
- `--format FORMAT`: Output format (CSV, DIFF, or HTML)
- `-h`, `--help`: Show help message

### Examples

1. Compare two strings:
   ```
   ruby main.rb "Hello, world!" "Hello, World!"
   ```

2. Compare two CSV files:
   ```
   ruby main.rb -c -i ID -m Name:FullName,Age --format DIFF file1.csv file2.csv
   ```

3. Compare CSVs with different column names and output as HTML:
   ```
   ruby main.rb -c -i ID1:ID2 -m "First Name":"Full Name",Age --format HTML file1.csv file2.csv
   ```

## Output

- For string comparisons: Displays whether the strings are equal or not.
- For CSV comparisons:
  - Plain text: Lists all differences found.
  - CSV: Outputs a new CSV file with differences.
  - DIFF: Shows colored diff output in the terminal.
  - HTML: Generates an HTML file with colorized diffs.

The tool will also indicate in which file(s) each identifier is present (csv1, csv2, both, or none).

## Exit Code

The program exits with the number of differences found (0 if no differences).
