require 'random'

class Markov

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
  end
end
