require 'yaml'

require_relative 'lib/input'
require_relative 'lib/game'

class Main
  # include Input

  def self.run_hangman
    system('clear')
    puts '--- Hangman ---'
    if Input.confirmation?('Load from save file? [y/n] ') then
      Main.load_game
    else
      Game.new.new_turn
    end
  end

  def self.load_game
    save_data = File.read('saved-games/saved_game.hangman')
    saved_game = Marshal.load(save_data)
    saved_game.new_turn
  end
end

Main.run_hangman
