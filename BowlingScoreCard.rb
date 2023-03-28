# warn_indent: true

# File: BowlingScoreCard.rb
# Author: Chad Maniccia
# Date: 3/24/2023

require "test/unit"

# Class BowlingScoreCard
#
# This class represents a bowling score card
# It can calculate the score by frame given an array with the following format...
#
# 0-9 Number of pins knocked down
# '/' A spare
# 'X' A Strike
class BowlingScoreCard

	# Given an array of rolls creates an array of frames.
	# BadDataError is raised if data is not 0-9, X or /  
	def initialize(rolls)
		@rolls = rolls
		@frames = Array.new()
		@frameCount = 0
		@bowlingScore = 0

		class << self
    		attr_accessor :bowlingScore
  		end

		lastRoll = nil
		@rolls.each_with_index do | roll, index |

			# print "Roll #{index + 1} score #{roll}\n"
   			
			if roll == "X"
				@frames[@frameCount] = Frame.new(@frameCount, Roll.new("X"), nil)
				@frameCount = @frameCount + 1
				lastRoll = nil
				next
			end

			if roll == "/"
				@frames[@frameCount] = Frame.new(@frameCount, Roll.new(lastRoll), Roll.new("/"))
				@frameCount = @frameCount + 1
				lastRoll = nil
				next
			end

			if  roll == nil or !roll.is_a? Numeric or roll < 0 or roll > 9
				raise BadDataError.new roll
			end

			if lastRoll != nil
				@frames[@frameCount] = Frame.new(@frameCount, Roll.new(lastRoll), Roll.new(roll))
				@frameCount = @frameCount + 1
				lastRoll = nil
			else
				lastRoll = roll
			end
		end

		if lastRoll != nil
			@frames[@frameCount] = Frame.new(@frameCount, Roll.new(lastRoll), nil)
		end	

	end

	# Calculate each frame of the score card
	# A total bowling score is compiled by summing the frames.
	def calculate
		@frames.each_with_index do | frame, index |
			frame.calculate(@frames)
			if frame.totalPoints != nil
				@bowlingScore += frame.totalPoints
			end	
		end	
	end

	# Generates an Array of frame scores. You must call calculate first.
	# This is the primary function.
	def getFrameScores()
		frameScores = Array.new()
		@frames.each_with_index do | frame, index |
			frameScores[index] = frame.totalPoints
		end	
		return frameScores
	end	

	def to_s
		"#{@frames}\nBowling Score:#{bowlingScore}"
	end
end

# Class Frame
#
# This class reperesents a bowling frame
# A frame consists of two potential rolls.
# The second roll can be nil in the case of strikes
# or an incomplete frame.
class Frame 
	
	def initialize(frame, firstRoll, secondRoll)
		@frame = frame
		@firstRoll = firstRoll
		@secondRoll = secondRoll
		@points = 0
		@bonusPoints = 0
		@totalPoints = 0

		@firstRoll.calculate(nil)
		if @secondRoll != nil
			@secondRoll.calculate(@firstRoll)
		end

		class << self
    		attr_accessor :frame
    		attr_accessor :firstRoll
    		attr_accessor :secondRoll
    		attr_accessor :totalPoints
  		end

	end	

	# Calculate the total points of the frame
	# 
	# arg:frames = Array of frames
	#
	# A frames score is sometimes dependent upon the score of future frames.
	def calculate(frames)

		if @firstRoll.pinsKnockedDown == "X"
			@points = 10
			if frames.length > @frame + 1
				@bonusPoints += frames[@frame + 1].firstRoll.points
				if frames[frame + 1].secondRoll != nil
					@bonusPoints += frames[@frame + 1].secondRoll.points
					@totalPoints = @points + @bonusPoints
				elsif frames.length > @frame + 2
					@bonusPoints += frames[@frame + 2].firstRoll.points
					@totalPoints = @points + @bonusPoints
				else
					@totalPoints = nil	
				end
			else
				@totalPoints = nil
			end
			return
		end

		if @secondRoll != nil and @secondRoll.pinsKnockedDown == "/"
			@points = 10
			if frames.length > @frame + 1
				@bonusPoints = frames[@frame + 1].firstRoll.points
				@totalPoints = @points + @bonusPoints
			else
				@totalPoints = nil
			end
			return
		end

		if @secondRoll == nil
			@totalPoints = nil
			return
		end	

		@totalPoints = @firstRoll.points + @secondRoll.points
	end

	def inspect
    	"Frame:#{@frame + 1}: First Roll:#{@firstRoll} Second Roll:#{@secondRoll} Points:#{@totalPoints}\n"
  	end
end

# Class Roll
#
# Class represents the roll of a bowling ball
# and the number of pins knocked down.
class Roll
	def initialize(pinsKnockedDown)
		@pinsKnockedDown = pinsKnockedDown
		@points = 0

		class << self
    		attr_accessor :pinsKnockedDown
    		attr_accessor :points
  		end
	end

	# Calculates the points earned on this roll
	def calculate(previousRoll)

		if @pinsKnockedDown == "X"
			@points = 10
			return
		end

		if @pinsKnockedDown == "/"	
			@points = 10 - previousRoll.pinsKnockedDown
			return
		end

		@points = @pinsKnockedDown
	end	


	def to_s
		"#{@pinsKnockedDown}"
	end
end	

# Class BadDataError extends Standard Error
#
# Raised if bad data inputed to BowlingScoreCard
class BadDataError < StandardError
  def initialize(badData)
  	@msg = "Unexpected Data Found in Array EXPECTED: 0,1,2,3,4,5,6,7,8,9,/, or X FOUND: #{badData}"
    super(@msg)
  end
end

# Class UnitTest
#
# Holds the data you want to test
# and the expected output of the test.
class UnitTest
	def initialize(data, assert)
		@data = data
		@assert = assert

		class << self
			attr_accessor :data
			attr_accessor :assert
		end	
	end

	def to_s
    	"#{@data}"
  	end

end

# Class UnitTests Extends TestCase
#
# This class will run if you build the file.
#
# There are three types of tests...
# 1. Test a given Array of rolls for a final score
# 2. Test a given Array of rolls for the expected scores of each frame
# 3. Test a given Array of rolls raises a BadDataError.
class UnitTests < Test::Unit::TestCase

 	def test_BowlingScoreCard_scores
	    unitTests = Array.new()
		unitTests[0] = UnitTest.new(Array['X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', "X", "X"], 300)
		unitTests[1] = UnitTest.new(Array[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'X', 'X', 'X'], 30)
		unitTests[2] = UnitTest.new(Array["X",0, 0, "X", "X", 1, "/", 5, "/", 0, 0, "X", 0, 0, "X", 0, 0], 96)
		unitTests[3] = UnitTest.new(Array[4, 5, "X", 8], 9)
		unitTests[4] = UnitTest.new(Array[4, 5, "X", 8, 1], 37)

		unitTests.each_with_index do | unitTest, index |
			puts unitTest
			bowlingScoreCard = BowlingScoreCard.new(unitTest.data)
			bowlingScoreCard.calculate()
			puts bowlingScoreCard
			print "Assert #{unitTest.assert} == #{bowlingScoreCard.bowlingScore}\n"
			assert_equal(unitTest.assert, bowlingScoreCard.bowlingScore)
			print "\n"
		end
	end

	def test_BowlingScoreCard_frameScores
	    unitTests = Array.new()
	    unitTests[0] = UnitTest.new(Array["X",0, 0, "X", "X", 1, "/", 5, "/", 0, 0, "X", 0, 0, "X", 0, 0], Array[10, 0, 21, 20, 15, 10, 0, 10, 0, 10, 0])
		unitTests[1] = UnitTest.new(Array[4, 5, "X", 8], Array[9, nil, nil])
		unitTests[2] = UnitTest.new(Array[4, 5, "X", 8, 1], Array[9, 19, 9])

		unitTests.each_with_index do | unitTest, index |
			puts unitTest
			bowlingScoreCard = BowlingScoreCard.new(unitTest.data)
			bowlingScoreCard.calculate()
			puts bowlingScoreCard
			print "Assert #{unitTest.assert} == #{bowlingScoreCard.getFrameScores()}\n"
			assert_equal(unitTest.assert.to_s, bowlingScoreCard.getFrameScores().to_s)
			print "\n"
		end
	end

	def test_BowlingScoreCard_badDataError		
		unitTests = Array.new()
    	unitTests[0] = UnitTest.new(Array[0, 1, 2, 3, 4, 186282, "Light"], Array[0])
    	unitTests[1] = UnitTest.new(Array[nil], Array[0])

		unitTests.each_with_index do | unitTest, index |
			assert_raise(BadDataError) {
				puts unitTest
				print "Assert BadDataError Raised\n\n"
				bowlingScoreCard = BowlingScoreCard.new(unitTest.data)
				bowlingScoreCard.calculate()
			}	
		end
	end
end





