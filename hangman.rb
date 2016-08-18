require 'yaml'

def choose_random_word
	word = ""
	until (word.length > 4) && (word.length < 13)
		word = File.readlines("dictionary.txt").sample
	end
	word.upcase
end

def word_attempt(word)
	word_array = word.split("")
	output = ""
	word_array.each do |letter|
		if @guessed_letters.include? @valid_guess
			output << letter.upcase
		else
			output << "_ "
		end
	end
	output
end

def round
	if @rounds_remaining == 0
		puts "The word was #{@word.chomp}. You lose."
		start_game
	else
		hint = ""
		puts "Choose a letter:"
		guess = gets.chomp
		if guess == 'save'
			save_game
			round
		else
			@valid_guess = guess.upcase[0]
			@guessed_letters << @valid_guess
			@word.each_char do |letter|
				if @guessed_letters.include? letter
					hint << "#{letter} "
				else
					hint << "_ "
				end
			end
			hint = hint[0..-3]
			@rounds_remaining -= 1 if @hint_count == hint.scan(/_/).count
			@hint_count = hint.scan(/_/).count
			puts "Letters used: #{@guessed_letters.join(", ")}"
			puts hint
			if hint.include?("_")
				puts "#{@rounds_remaining} rounds remaining"
				round
			else
				puts "You win!"
				start_game
			end
		end
		
	end
end

def start_game
	if File.exist?('games/saved.yaml')
		puts "Would you like to load last saved game? (y/n)"
		answer = gets.chomp.downcase
		if answer == 'y'
			load_game
		else
			puts "-- NEW GAME --"
			@guessed_letters = []
			@rounds_remaining = 10
			@word = choose_random_word
			@hint_count = @word.length
			puts word_attempt(@word)
			round
		end
	else
		puts "-- NEW GAME --"
		@guessed_letters = []
		@rounds_remaining = 10
		@word = choose_random_word
		@hint_count = @word.length
		puts word_attempt(@word)
		round
	end
end

def save_game
  Dir.mkdir('games') unless Dir.exist? 'games'
  filename = 'games/saved.yaml'
  File.open(filename, 'w') do |file|
    file.puts YAML.dump(self)
    puts "Game saved"
  end
end

def load_game
  # assumes file exists
  content = File.open('games/saved.yaml', 'r') { |file| file.read }
  YAML.load(content) # returns a Hangman object
  round
end

start_game