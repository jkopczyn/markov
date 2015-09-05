require_relative 'markov'

class MarkovState

  def initialize
    @markov = nil
    @generator = nil
  end

  def load(filename)
  end

  def save(filename)
  end

  def train(prefix_length, filename, options)
    @markov = Markov.new(prefix_length)
    File.open(filename) do |f|
      enumerator = f.each_line.lazy.map(&:split)
      if options.noparagraphs
        enumerator = enumerator.inject(&:+).map(&:to_sym)
      else
        enumerator = enumerator.inject {|l1,l2| l1+['\n']+l2}.map(&:to_sym)
      end
      @markov.train(enumerator)
      @generator = nil
    end
  end
end
