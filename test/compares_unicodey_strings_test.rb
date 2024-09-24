require_relative "test_helper"

module TranslationTools
  class ComparesUnicodeyStringsTest < Minitest::Test
    def test_identical_strings
      assert ComparesUnicodeyStrings.equal?("hello", "hello")
    end

    def test_different_strings
      refute ComparesUnicodeyStrings.equal?("hello", "world")
    end

    def test_unicode_and_escaped_unicode
      assert ComparesUnicodeyStrings.equal?("café", "caf\u00E9")
    end

    def test_multiple_unicode_characters
      assert ComparesUnicodeyStrings.equal?("こんにちは", "\u3053\u3093\u306B\u3061\u306F")
    end

    def test_mixed_unicode_and_ascii
      assert ComparesUnicodeyStrings.equal?("hello world!", "hello\u0020world!")
    end

    def test_case_sensitivity
      refute ComparesUnicodeyStrings.equal?("Hello", "hello")
    end

    def test_empty_strings
      assert ComparesUnicodeyStrings.equal?("", "")
    end

    def test_nil_strings
      assert_raises(NoMethodError) { ComparesUnicodeyStrings.equal?(nil, nil) }
    end
  end
end
