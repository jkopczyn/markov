require 'random'
require 'set'

class Markov

  CLAUSE_ENDS = Set.new([',', '.', ';', ':'])

  def initialize(prefix_size=3)
    @prefix_size = prefix_size
    @probability_of_random = 0
    @seed = nil
    @data = {}
    @recent_data = {}
    @final_clear_length = prefix_size
    @previous_tokens = []
  end

  def set_clear_length(cln):
    cln ||= @prefix_size
    cln = @prefix_size unless cln <= @prefix_size
    @final_clear_length = cln
  end

  def train(training_date)
    @previous_tokens = []
    training_data.each do |token|
      token = token.to_sym
      (0...@previous_tokens.length).map do |i|
        prefix = @previous_tokens[i..-1]
        unless @data[prefix]:
          @data[prefix] = [0,{}]
        end
        unless @data[prefix][1]:
          @data[prefix][1][token] = 0
        end
        @data[prefix][0] += 1
        @data[prefix][1][token] += 1
      end
      @previous_tokens = (@previous_tokens + [token])[-@prefix_size..-1]
    end
  end

  def load(filename)
    begin
      serialized = nil
      data_store = File.open(filename, 'r')
      copy, @data = Marshal::load(data_store.read)
      data_store.close
    rescue 
      puts "Could not save to file #{filename}."
    end
  end

  def dump(filename)
    begin
      serialized = Marshal::dump(@prefix_size, @data)
      File.open(filename, 'w'){ |file| file.print(serialized) }
    rescue 
      puts "Could not read from file #{filename}."
    end
  end

  def reset(options)
    @seed = options.seed if options.seed
    @probability_of_random = options.prob if options.prob
    @previous_tokens = options.previous if options.previous
    set_clear_length(options.final_clear_length) if options.final_clear_length
    clean_recent_data
    srand(@seed)
  end

  def yield_token
    while true:
      if @previous_tokens == [] or rand < @probability_of_random:
        next_token = select_token([])
      else:
        begin
          next_token = select_token(@previous_tokens)
        rescue
        @previous_tokens = []
        next_token = select_token([])
        end
      end
      @previous_tokens = (@previous_tokens + [next_token])[-@prefix_size..-1]
      if CLAUSE_ENDS.include?(next_token[-1]):
        @previous_tokens = @previous_tokens[-@final_clear_length..-1]
      end
      return next_token
    end
  end

  def last_state_saturated
    return false unless @recent_data.include?(@previous_tokens)
    @recent_data[@previous_tokens] > @data[@previous_tokens][0]
  end

  def clean_recent_data
    @recent_data = {}
  end

  private
  def select_token(state=nil)
    state ||= @previous_tokens
    @recent_data[state] ||= 0
    @recent_data[state] += 1
    choose(@data[state])
  end
  def choose(freqdict)
    total_count, choice_hash = freqdict
    idx = rand(0...total_count)
    choice_hash.each_pair do |token, occurences|
      return token if idx < occurences
      idx -= occurences
    end
  end
end
#{a: 2, b: 4, c: 1, d: 6}
#13, <=
#8-13 -> 11 > 7 > 6
#0-2 > a (3)
#13, <
#0-1 > a (2)
#

