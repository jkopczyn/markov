#require "yaml"

class Markov

  def initialize(prefix_size=3)
    @prefix_size = prefix_size
    @probability_random = 0
    @seed = None
    @data = {}
    @recent_data = {}
    @final_clear_length = prefix_size
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

end
