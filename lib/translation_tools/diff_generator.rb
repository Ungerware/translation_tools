require "diffy"

class DiffGenerator
  def self.generate_diff(str1, str2, format: :color)
    diff = Diffy::Diff.new(str1, str2, context: 2)
    case format
    when :color
      diff.to_s(:color)
    when :html
      diff.to_s(:html)
    else
      raise ArgumentError, "Unsupported format: #{format}"
    end
  end
end
