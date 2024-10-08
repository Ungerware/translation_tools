# frozen_string_literal: true

require_relative "translation_tools/version"
require_relative "translation_tools/cli"
require_relative "translation_tools/compares_csvs"
require_relative "translation_tools/compares_unicodey_strings"
require_relative "translation_tools/diff_generator"

module TranslationTools
  class Error < StandardError; end
end
