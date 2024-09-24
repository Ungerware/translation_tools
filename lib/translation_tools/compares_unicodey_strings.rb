class ComparesUnicodeyStrings
  def self.equal?(str1, str2)
    normalize(str1) == normalize(str2)
  end

  def self.normalize(str)
    str.gsub(/\\u([0-9a-fA-F]{4})/) { [$1.hex].pack("U") }
      .encode("UTF-8", "UTF-8")
  end
end
