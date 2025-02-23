# typed: false

class Game
  attr_reader :secret_word, :lettersGuessed, :lives, :word_rack

  def initialize
    @secret_word = get_random_word.chomp.split('')
    @lettersGuessed = []
    @lives = 10
    @word_rack = Array.new(secret_word.length, '_')

    new_turn
  end

  def add_guessed_letter(letter)
    @lettersGuessed << letter
  end

  def remove_life
    @lives -= 1
  end

  # Gets a random word from the dictionary file located in the assets folder
  def get_random_word
    dictionary = File.readlines('./assets/google-10000-english-no-swears.txt')

    word = ''
    until word.length > 5 && word.length < 12
      word = dictionary.sample
    end

    word
  end

  # Main game loop
  def new_turn
    update_game_display

    guessed_letter = get_user_guess
    if secret_word.include?(guessed_letter)
      handle_correct_guess(guessed_letter)
    else
      add_guessed_letter(guessed_letter)
      remove_life
    end

    handle_game_completed
  end

  # Clears the console and displays the current game state
  def update_game_display
    system('clear')
    # puts "\n/------------------------------/\n\n"
    puts "Lives: #{lives}"
    puts "Wrong letters guessed: #{lettersGuessed.sort.join(' ')}\n\n"
    puts word_rack.join(' ')
  end

  # Prompts the user for a a valid letter guess or to save the game
  def get_user_guess
    puts

    # Gets a valid letter guess from the user
    guess = ''
    until (guess.match?(/[a-z]/) && guess.length == 1 && lettersGuessed.include?(guess) == false) || guess == 'save'
      print "Guess a letter: "
      guess = gets.chomp.downcase
    end

    # Saves the current game state to a file
    if guess == 'save'
      File.open('saved-games/saved_game.hangman', 'w') do |file|
        file.write(Marshal.dump(self))
      end

      puts 'Game saved!'
      exit
    end

    guess
  end

  # Updates the word rack with the correctly guessed letter
  def handle_correct_guess(guessed_letter)
    secret_word.each_with_index do |letter, index|
      if letter == guessed_letter
        word_rack[index] = guessed_letter
      end
    end
  end

  # Checks if the game is over and prompts the user for a new game
  def handle_game_completed
    if word_rack.include?('_') == false
      puts "\nCongratulations! You won! The word was: " + secret_word.join
      prompt_for_new_game
    elsif lives == 0
      puts "\nGame over. The word was: " + secret_word.join
      prompt_for_new_game
    else
      new_turn
    end
  end

  # Prompts the user for a new game
  def prompt_for_new_game
    userResponse = ''
    until userResponse.match?(/[yn]/)
      print 'Would you like to play again? [y/n] '
      userResponse = gets.chomp.downcase
    end

    if userResponse == 'y'
      Game.new.new_turn
    else
      exit
    end
  end
end
