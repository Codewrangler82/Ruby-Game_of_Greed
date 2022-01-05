
require 'io/console'

class Game
	class Player
		attr_accessor :totalScore
		attr_accessor :turnScore
		attr_accessor :inGame
		attr_accessor :lastTurn
		
		def initialize
			@totalScore = 0
			@inGame = false
			@lastTurn = false
		end
	end
	
	class DiceSet
		def values
			@vals
		end
		
		def initialize
			@vals = []
		end
		
		def roll(numDice)
			@vals = Array.new(numDice) { Random.rand(1..6) }
		end
	end

	def initialize
		@players = []
		@curPlayer = 0
		@curDice = DiceSet.new
		@rollScore = 0
		@turnScore = 0
		@endGame = false
		@gameOver = false
	end
	
	def run
		# Players prompt
		system("cls")
		numPlayers = 0
		while numPlayers == 0
			print "Number of players (1-4)? "
			s = gets.chomp
		
			if s =~ /[1-4]/
				numPlayers = s.to_i
			else
				puts "Invalid Entry!"
			end
		end
		
		#Create player array
		@players = Array.new(numPlayers) { |e| Player.new }
		
#GAME LOOP-------------------------------------------------------------------------------
		while !@gameOver
			system("cls")
		
			#Display player scores.  Highlight active player
			displayScoreboard
			
			#Display inGame status
			if !@players[@curPlayer].inGame
				puts "\e[1;31mYou have not scored in yet.  (300+ roll required)\e[0m"
			end
			
			#Check for end game
			if @endGame
				puts "\e[1;41m--LAST TURN--\e[0m"
			end
			
			#Roll dice
			puts "\e[1;32m<ROLL>\e[0m"
			STDIN.getch
			
			if @curDice.values.size == 0
				@curDice.roll(5)
			else
				@curDice.roll(@curDice.values.size)
			end
			
			#Score and display dice
			displayDiceRoll
			
			#ROLL score 0
			if @rollScore == 0
				#END TURN
				@turnScore = 0
				endTurn
				
				puts "\e[1;31mYou rolled zero!\n<END OF TURN>\e[0m"
				STDIN.getch
				next
			end
			
			#Not enough points to get in game
			if @players[@curPlayer].inGame == false && @rollScore < 300
				#END TURN
				@turnScore = 0
				endTurn
				
				puts "\e[1;31mNot enough points!\n<END OF TURN>\e[0m"
				STDIN.getch
				next
			end
			
			#Ensure inGame
			if @players[@curPlayer].inGame == false
				@players[@curPlayer].inGame = true
				puts "\e[1;32mYou're in!\e[0m"
			end
			
			#Update turn score
			@turnScore += @rollScore
			
			#Display remaining dice
			puts "\e[1;32m<REMAINING DICE>\e[0m"
			displayDiceRoll
			
			#Display turn score
			puts "\e[1;33;42mBank: #{@turnScore}\e[0m"
			
			#Roll again?
			puts "\e[1;33mRoll again? [Y/N]"
			
			s = ''
			until s =~ /[yYnN]/ do s = STDIN.getch end
			
			if s =~ /[nN]/
				puts "\e[1;34m#{@turnScore} added!\e[0m"
				puts "\e[1;31m<END OF TURN>\e[0m"
				
				STDIN.getch
				endTurn
			end
		end
		
		#Game Over
		system("cls")
		
		displayScoreboard
		winner = 1 + @players.index( @players.max { |a, b| a.totalScore <=> b.totalScore } )
		puts "\e[1;32mP#{winner} wins!\e[0m"
	end
	
	def score(dice)
		totalScore = 0
		
		dice.sort!
		
		if dice.any? { |e| dice.count(e) >= 3}
			dice.each do |e|
				if dice.count(e) >=3
					totalScore += e == 1 ? 1000 : 100 * e
					dice.slice!(dice.index(e), 3)
					break
				end
			end
		end
		
		totalScore += 100 * dice.count(1)
		dice.delete(1)
		
		totalScore += 50 * dice.count(5)
		dice.delete(5)
		
		totalScore
	end
	
	def displayScoreboard
		s = ""
		@players.each_index do |i|
			if i == @curPlayer
				s << "\e[1;33;42m"
			else
				s << "\e[1;32m"
			end
			s << "P#{i+1} [#{@players[i].totalScore}]\e[0m\t"
		end
		puts s + "\n"
	end
	
	def displayDiceRoll
		s = "\n\e[1;33;44m"
		@curDice.values.each do |e|
			s << "{#{e}}\t"
		end
		s << "\e[0m"
		
		@rollScore = score(@curDice.values)
		puts s + "\e[1;33m= #{@rollScore}\e[0m\n\n"
	end
	
	def endTurn
		#Update player score
		@players[@curPlayer].totalScore += @turnScore
		@turnScore = 0
		
		#Check for end game trigger
		if @players[@curPlayer].totalScore >= 3000 
			@players[@curPlayer].lastTurn = true
			@endGame = true
		end
		
		#Check for end game
		if @endGame
			@players[@curPlayer].lastTurn = true
		end
		
		#Check for game over
		if @endGame && @players.all? { |e| e.lastTurn }
			@gameOver = true
		end
		
		#Next player
		@curPlayer = (@curPlayer + 1) % @players.size
		@curDice = DiceSet.new
	end
end

game = Game.new
game.run
STDIN.getch