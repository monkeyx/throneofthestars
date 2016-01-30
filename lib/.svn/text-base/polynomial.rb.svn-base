class Polynomial
    def initialize (yarr)
		@coefficients = yarr
    end

    attr_reader :coefficients

    def self.mkroll (n)
		x = [0]

		(1..n).each do |i|
	    	x[i] = 1
		end

		Polynomial.new(x)
    end

    def *(other)
		noob = []

		@coefficients.each_with_index do |xi, i|
	    	other.coefficients.each_with_index do |yj, j|
				cell = i + j

				if noob[cell].nil?
		    		noob[cell] = 0
				end

				noob[cell] += xi * yj
	    	end
		end

		Polynomial.new(noob)
    end
end