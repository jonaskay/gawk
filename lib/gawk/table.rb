module Gawk
  class Table
    def initialize(name: "", headings: [], rows: [])
      @name = name
      @headings = headings
      @rows = rows
      @widths = get_widths
    end

    def name=(str)
      @name = str
    end

    def headings=(arr)
      @headings = arr
      @widths = get_widths
    end

    def rows=(arr)
      @rows = arr
      @widths = get_widths
    end

    def to_s
      buffer = []
      buffer << ""
      buffer << "=" * width
      buffer << @name
      buffer << "-" * width
      buffer << buffer(@headings)
      buffer << ""
      @rows.each {|row| buffer << buffer(row)}
      buffer << ""
      buffer.join("\n")
    end

    def width
      (@widths.inject(0){|sum,x| sum + x } + (@widths.length - 1) * 6)
    end

    private

    def buffer(arr)
      str = ""
      arr.each.with_index do |e, i|
        str += "   #{e}   " + " " * (@widths[i].to_i - e.length)
      end
      str.strip
    end

    def get_widths
      widths = @headings.map {|s| s.length}
      @rows.each do |row|
        row.each.with_index do |element, i|
          widths[i] = element.length if element.length > widths[i]
        end
      end
      widths.flatten
    end
  end
end
