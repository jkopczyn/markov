require_relative 'markov'

class MarkovState

  def initialize
    @markov = nil
    @generator = nil
  end

  def load(filename)
    @generator = nil
    @markov = Markov.new
    @markov.load(filename)
  end

  def dump(filename)
    if @markov
      @markov.dump(filename)
    else
      puts "No Markov chain loaded!"
  end

  def train(prefix_length, filename, options)
    @markov = Markov.new(prefix_length)
    File.open(filename, 'r') do |f|
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

  def generate(chunks, options)
    throw "No markov chain loaded!" unless @markov
    #options.seed ||= nil
    options.prob ||= 0
    options.initial_skip ||= 0
    #options.final_clear_length ||= nil
    options.start_condition ||= lambda { |x| true }
    options.end_condition   ||= lambda { |x| true }
    options.final_discard ||= 0
    options.previous ||= []
    unless options.seed
      t= Time.now.to_i
      puts "Using epoch time as seed, #{t}"
      options.seed = t
    end
    if options.previous.length > @markov.previous_tokens
      options.previous = options.previous[-@markov.previous_tokens..-1]
      puts "Truncating prefix to #{options.previous}"
    end
    @markov.reset(options)

    
    options.initial_skip.times do
      next_token = @markov.yield_token
    end
    
    until options.start_condition.call(next_token)
      next_token = @markov.yield_token
    end

    enum = Enumerator.new do |y|
      y.yield @markov.yield_token
    end

    @generator = lambda { |n|
      output = []
      while n > 0
        output << next_token
        if options.end_condition.call(next_token) or @markov.last_state_saturated
          n -= 1
          @markov.clean_recent_data
        end
        next_token = enum.first
      end
      return ' '.join(output[0..(-1-options.final_discard)])
    }

    @generator.call(chunks)
  end

  def more(chunks=1)
    throw "No markov chain loaded!" unless @markov
    @generator.call(chunks)
  end

end
