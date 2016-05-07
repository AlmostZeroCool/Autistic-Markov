class MarkovChain
	def initialize(layers=3)
		@chain = {}
		@layers = layers
	end

	# Data should be a fucking array
	# Polymorphism is bullshit
	#                                                  I didn't really mean that btw
	def seed(data)
		if not data.is_a? Array
			# YELL LOUDLY
			puts "NO FUCK YOU, YOU THINK YOU CAN COME INTO MY HOUSE WITH THIS FUCKING \"OH I DONT NEED TO GIVE AN ARRAY AS AN ARGUMENT\" BULLSHIT? FUCK YOU. FUCK OFF."
			exit -9001
		end

		return if data.size < @layers

		# Yeah I know
		data.map! do |e|
			e.downcase if e.is_a? String
		end

		data_paired = []
		# This block needs to be cleaned up or at least commented
		# (I honestly barely know what I was thinking but it works)
		data.each_with_index do |elem, i|
			next if i < @layers
			data_paired[i - @layers] = []
			0.upto @layers do |l|
				data_paired[i - @layers] << data[l + (i - @layers)]
			end
		end

		data_paired.each do |pair|
			key = []
			value = pair.last
			@layers.times do |i|
				key << pair[i]
			end
			if @chain.has_key? key
				@chain[key] << value
			else
				@chain[key] = [value]
			end
		end
	end

	def seed_file(file)
		if file.is_a? String
			file = File.open(file, 'r')	
		end

		dat = file.read
		file.close

		#seperate line because I might remove this
		#dat = dat.gsub(/[^A-Za-z0-9 ]/, '')

		dat = dat.gsub("\n", ' ').split(' ')
		seed(dat)
	end

	def generate(len=rand(256))
		generated = []
		cur_seed = @chain.keys.sample(1).first
		
		len.times do |i|
			generated += cur_seed
			begin
				dat = @chain[cur_seed].sample(1).first
			rescue Exception
				break 
			end
			cur_seed.shift
			cur_seed.unshift dat
		end
		generated
	end

	attr_reader :chain # here because debugging
end

testchain = MarkovChain.new 5

seed_files = Dir.glob('./seeds/*.txt')
seed_files.each do |seed_file|
	testchain.seed_file(seed_file)
end

dat = []
until dat.size == 200 do
	print "#{dat.size}\r"
	faggot = testchain.generate(256)
	if faggot.size > 10
		dat << faggot.join(' ')
	end
end
puts dat
