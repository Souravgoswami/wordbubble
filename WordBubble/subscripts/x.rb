#!/usr/bin/env ruby
# Written by Sourav Goswami <souravgoswami@protonmail.com>. Thanks to the Ruby2D community!
# GNU General Public License v3.0
STDOUT.sync = true

%w(ruby2d securerandom zlib thread open3).each do |el|
	begin
		require(el)
	rescue LoadError
		print "\n\a" + '=' * 5 + '> '
		puts "Uh Oh! Can't load '#{el}'. Please make sure you have a proper Ruby and Ruby2D installation. Exiting!"
		exit! 127
	end
end

module Ruby2D
	def total_x(padding = 0)
		x + width + padding
	end

	def total_y(padding = 0)
		y + height + padding
	end

	def to_centre_x(padding = 0)
		@x = Window.get(:width) / 2 - width / 2 + padding
		self
	end

	def to_centre_y(padding = 0)
		@y = Window.get(:height) / 2 - height / 2 + padding
		self
	end

	def mid_x(object)
		x + width / 2 - object.width / 2
	end

	def mid_y(object)
		y + height / 2 - object.height / 2
	end

	def change_colour=(colour)
		self.color, __opacity__ = colour, self.opacity
		self.opacity = __opacity__
		self
	end

	def get_colour
		if color.is_a?(Ruby2D::Color::Set)
			color[0..-1].map do |c|
				'#' + [c.r * 255, c.g * 255, c.b * 255].map do |x|
						v = x.truncate.to_s(16)
						v[0, 0] = '0' if v.length == 1
						v
				end.join
			end
		else
			[r, g, b, 1]
		end
	end

	def increase_opacity(step = 0.05, threshold = 1)
		self.opacity += step unless opacity >= threshold
		self
	end

	def decrease_opacity(step = 0.05, threshold = 0)
		self.opacity -= step unless opacity <= threshold
		self
	end

	def contain?(object)
		contains?(object.x, object.y)
	end
end

class Ruby2D::Image
	def dup(hash = {})
		x_, y_, z_, opacity_, color_, rotate_ = hash[:x], hash[:y], hash[:z], hash[:opacity], hash[:color], hash[:rotate]
		Image.new(path, x: x_ ? x_ : x, y: y_ ? y_ : y, z: z_ ? z_ : z, opacity: opacity_ ? opacity_ : opacity, color: color_ ? color_ : color, rotate: rotate_ ? rotate_ : rotate)
	end
end

class Array
	# [1, 2, 3].decrease_opacity will simply crash the program.
	# It's unreliable and we are not checking if the object is a mixin of Ruby2D module because of speed.
	# We'll be only using Ruby2D object array while using this method.
	def decrease_opacity(step = 0.05, threshold = 0)
		each { |x| x.decrease_opacity(step, threshold) }
	end

	def increase_opacity(step=0.05, threshold=1)
		each { |x| x.increase_opacity(step, threshold) }
	end

end

class Ruby2D::Image
	include Ruby2D

	define_singleton_method(:load) do |path, opts={}|
		begin
			Image.new(path, opts)
		rescue Exception => e
			if e.to_s.start_with?('Cannot find image file')
				warn "#{path} -> not found"
			else
				puts "\e[1;31;4;5m#{e}\e[0m"
				warn e.backtrace
			end
			exit!
		end
	end
end

module Z
	# lets us decompress, decrypt, read the word files and return an array of words
	define_singleton_method(:readfile) do |file|
		 file.concat('.gz') unless file.end_with?('.gz')
		[::Zlib::GzipReader.new(File.open(file, 'rb')).read].pack('h*').split("\n")
	end
end
