# typed: false
class Game
  attr_reader :secret_word, :lettersGuessed, :lives, :word_rack

  def initialize
    @secret_word = get_random_word.split
    @lettersGuessed = []
    @lives = 7
    @word_rack = Array.new(secret_word.length, '_')

    new_turn
  end

  def add_guessed_letter(letter)
    @lettersGuessed << letter
  end

  def remove_life
    @lives -= 1
  end

  def get_random_word
    words = File.readlines('../assets/google-10000-english-no-swears.txt')
    return words.sample
  end

  def new_turn
    update_game_display

    guessed_letter = get_user_guess
    add_guessed_letter(guessed_letter)
    if secret_word.include?(guessed_letter)
      handle_correct_guess(guessed_letter)
    else
      remove_life
    end

    handle_game_completed
  end

  def update_game_display
    puts "Lives: #{lives}"
    puts "Letters guessed: #{lettersGuessed.join(' ')}"
    puts
    puts word_rack.join(' ')
  end

  def get_user_guess
    puts 'Guess a letter: '
    guess = ''
    until (guess.match?(/[a-z]/) && guess.length == 1) || guess == 'save'
      guess = gets.chomp.downcase
    end

    if guess == 'save'
      File.open('saved-games/saved_game.hangman', 'w') do |file|
        file.write(Marshal.dump(self))
      end

      puts 'Game saved!'
      exit
    end

    guess
  end

  def handle_correct_guess(guessed_letter)
    secret_word.each_with_index do |letter, index|
      if letter == guessed_letter
        word_rack[index] = guessed_letter
      end
    end
  end

  def handle_game_completed
    if !word_rack.include?('_')
      puts 'Congratulations! You won! The word was: ' + secret_word.join
      prompt_for_new_game
    elsif lives == 0
      puts 'Game over. The word was: ' + secret_word.join
      prompt_for_new_game
    else
      new_turn
    end
  end

  def prompt_for_new_game
    userResponse = ''
    until userResponse.match?(/[yn]/)
      puts 'Would you like to play again? [y/n]'
      userResponse = gets.chomp.downcase
    end

    if userResponse == 'y'
      Game.new.new_turn
    else
      exit
    end
  end
end
