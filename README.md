# Translation Tools

Translation Tools is a Ruby gem that provides a command-line interface for comparing CSV files and strings, with support for Unicode characters and various output formats.

## Features

- Compare two strings for equality, considering Unicode characters
- Compare two CSV files, focusing on specific columns
- Output differences in various formats: plain text, CSV, colored diff, or HTML
- Flexible identifier column specification for CSV comparisons

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'translation_tools'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install translation_tools
```

## Usage

The gem provides a command-line tool called `diff-translations`. Here's how to use it:

```
diff-translations [options] <string1> <string2> OR <csv1_path> <csv2_path>
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
   diff-translations "Hello, world!" "Hello, World!"
   ```

2. Compare two CSV files:
   ```
   diff-translations -c -i ID -m Name:FullName,Age --format DIFF file1.csv file2.csv
   ```

3. Compare CSVs with different column names and output as HTML:
   ```
   diff-translations -c -i ID1:ID2 -m "First Name":"Full Name",Age --format HTML file1.csv file2.csv
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Ungerware/translation_tools.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
