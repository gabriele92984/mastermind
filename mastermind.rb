class Mastermind
  attr_reader :game_board

  def initialize
    @game_board = GameBoard.new
  end

  def play
    welcome_message
    choice = gets.chomp.downcase

    case choice
    when 'p'
      game_board.setup_game
      game_board.start_game
    when 'q'
      puts "Thanks for playing!"
    else
      puts "Invalid choice. Please enter 'p' to play or 'q' to quit."
      play
    end
  end

  private

  def welcome_message
    puts "Welcome to Mastermind!"
    puts "Would you like to (p)lay or (q)uit?"
  end
end

class GameBoard
  attr_accessor :solution, :guesses

  def initialize
    @solution = []
    @guesses = []
  end

  def setup_game
    puts "Choose your role: (1) Creator or (2) Guesser"
    role = gets.chomp.to_i

    case role
    when 1
      create_solution
      computer_guesser
    when 2
      generate_solution
      player_guesser
    else
      puts "Invalid choice. Please choose (1) or (2)."
      setup_game
    end
  end

  def generate_solution
    @solution = Array.new(4) { rand(1..6) }
    puts "The computer has generated a secret code."
  end

  def create_solution
    loop do
      puts "Enter your secret code (4 numbers between 1 and 6):"
      input = gets.chomp.split("").map(&:to_i)

      if valid_code?(input)
        @solution = input
        puts "Your secret code has been set."
        break
      else
        puts "Invalid code. Please enter exactly four numbers between 1 and 6."
      end
    end
  end

  def valid_code?(code)
    code.length == 4 && code.all? { |num| num.between?(1, 6) }
  end

  def start_game; end # Placeholder for future implementation.

  def player_guesser
    attempts = 12

    attempts.times do |turn|
      guess = prompt_guess(turn)

      if valid_code?(guess)
        correct_position, correct_color = get_feedback(guess, solution)

        puts "#{correct_position} correct position(s), #{correct_color} correct color(s)."

        if correct_position == solution.length
          puts "Congratulations! You've guessed the secret code #{solution}!"
          return
        end
      else
        puts "Invalid guess. Please enter exactly four numbers between 1 and 6."
        turn -= 1 # Do not count this turn.
      end
    end

    puts "Sorry! You've used all your turns. The secret code was #{solution}."
  end

  def computer_guesser
    attempts = 12

    possible_colors = (1..6).to_a.repeated_permutation(4).to_a.shuffle!

    attempts.times do |turn|
      guess = possible_colors.sample

      if valid_code?(guess)
        correct_position, correct_color = get_feedback(guess, solution)

        puts "Computer's Guess: #{guess.join(", ")} - Feedback: #{correct_position} correct position(s), #{correct_color} correct color(s)."

        if correct_position == solution.length
          puts "The computer has guessed the secret code #{solution}!"
          return
        else 
          filter_possible_colors(possible_colors, guess, correct_position, correct_color)
        end 
      else 
        puts "Invalid guess by computer."
      end 

      break if possible_colors.empty?

      sleep(1) # Pause for effect.
    end

    puts "The computer couldn't guess the secret code. It was #{solution}."
  end

  private

  def prompt_guess(turn)
    puts "Turn #{turn + 1}: Enter your guess (4 numbers between 1 and 6):"
    gets.chomp.split("").map(&:to_i)
  end

  def filter_possible_colors(possible_colors, guess, correct_position, correct_color)
    possible_colors.reject! do |code|
      feedback = get_feedback(code, solution)
      feedback[0] != correct_position || feedback[1] != correct_color 
    end 
  end

end 

def get_feedback(guess, solution)
   correct_position = guess.each_with_index.count { |g, i| g == solution[i] }
   correct_color = (guess & solution).size - correct_position

   [correct_position, correct_color]
end 

# Start the game.
Mastermind.new.play