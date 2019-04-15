#!/usr/bin/env ruby
# Written by Sourav Goswami <souravgoswami@protonmail.com>. Thanks to Ruby2D community!
# GNU General Public License v3.0
require_relative 'x'

@path = File.dirname(__FILE__)
Font = File.join(@path, 'fonts', 'Merienda-Regular.ttf')

define_method(:main) do
	$width, $height, $fps = 640, 480, 50
	set title: 'Chalkboard Challenge Statistics', width: $width, height: $height, fps_cap: $fps, background: 'white', resizable: true
	Image.load(File.join(@path, 'images', 'bg_stat_window.png'), width: $width, height: $height, opacity: 0.3)

	scores = IO.readlines(File.join(@path, 'data', 'scorelist.data')).map { |data| [data].pack('h*').to_i }
	read_score = scores.last(5)
	last_score = read_score[-2] ? read_score[-2] : read_score[-1]
	score = read_score[-1]

	read_score, score = 'Not enough data', 0 if read_score.empty?

	you_in = case score
		when 0...3000 then 0
		when 3000...6000 then 1
		when 6000...9000 then 2
		when (9000...12000).to_a then 3
		else 4
	end

	game_details = <<~EOF.split("\n")
		WordBubble is a word game intended to focus on your
		English word recalling capability.

		How to play: You have to complete words you will
		see above the virtual keyboard. For typing, You can
		use your computer's keyboard, or the virtual keyboard
		itself.

		Scores: The graph on the right side shows the
		details.

		-------------------------------------------

		Your Recent Score: #{score}.
		Your Past Score: #{last_score}.
		Your Best Score: #{scores.max}.
		Your last 5 Scores:
				#{read_score.join(', ')}.

		-------------------------------------------
	EOF

	game_details_texts, game_details_touched = Array.new(game_details.size) { |i| Text.new(game_details[i], font: Font, x: 5, y: i * 20, size: 15, color: [1, i / 25.0, 1 - i / 10.0, 1] ) }, false
	triangles, touched_tri = 20.step(260, 60).map { |i| Triangle.new(x1: $height - i + 120, y1: 0 + i, x2: $height - i + 170, y2: 350, x3: $height - i + 70, y3: 350, color: [1, 1 - i / 260.0, i / 260.0, 1]) }.reverse, nil
	particles = Array.new(100) do
		sample, size = triangles.sample, [1, 2].sample
		Square.new(x: rand(sample.x3..sample.x2), y: sample.y2 - size , size: size, color: '#FFFFFF')
	end
	particles_opacity = Array.new(particles.size) { rand(0.003..0.03) }

	grade_texts = ['Very Low', 'Low', 'Average', 'Good', 'Excellent'].map.with_index do |el, index|
		text = Text.new(el, font: Font, color: '#000000', size: 12)
		text.x, text.y = triangles[index].x1 - text.width / 2, triangles[index].y1 - text.height
		text
	end

	you = Text.new 'YOU', font: Font , size: 12
	you.x = triangles[you_in].x1 - you.width / 2
	you.y = triangles[you_in].y1 / 2 + triangles[you_in].y2 / 2 - you.height / 2

	details_raw = <<~EOF.each_line.map { |el| ' ' * 6 + el }
					VERY LOW: (< 100) You must improve.
 					LOW: (100 - 350) You have to improve.
 					AVERAGE: (350 - 650) Normal performance.
 					GOOD: (650 - 1000) Wow! That's quick!
 					EXCELLENT: (> 1000) You are godlike!
	EOF

	a_line = Line.new color: '#000000', x1: triangles[0].x3, x2: triangles[-1].x2, y1: triangles[0].y2 + 10, y2: triangles[-1].y2 + 10
	details_info = Array.new(details_raw.size) { |i| Text.new(details_raw[i], font: Font, x: a_line.x1 - 20, y: a_line.y1 + 5 + i * 18, size: 11, color: [1, i / 5.0, 1 - i / 5.0, 1]) }

	on :key_down do |k| exit 0 if %w(escape p q space).include?(k.key) end

	on :mouse_move do |e|
		triangles.each do |el|
			if el.contain?(e)
				touched_tri = el
				break
			else
				touched_tri = nil
			end
		end

		game_details_texts.each do |el|
			if el.contain?(e)
				game_details_touched = el
				break
			else
				game_details_touched = nil
			end
		end
	end

	update do
		particles.each_with_index do |el, index|
			if el.opacity <= 0 || el.x < triangles[0].x3 || el.x > triangles[-1].x2
				sample = triangles.sample
				el.opacity = 1
				el.x, el.y = rand(sample.x3..sample.x2), sample.y2
			else
				el.x += Math.sin(index)
				el.y -= index / particles.size.to_f
				el.decrease_opacity(particles_opacity[index])
			end
		end

		game_details_touched ? game_details_texts.each { |el| el.equal?(game_details_touched) ? el.decrease_opacity(0.05, 0.4) : el.increase_opacity } : game_details_texts.each(&:increase_opacity)

		if touched_tri
			triangles.each_with_index do |el, index|
				unless el.equal?(touched_tri)
					el.increase_opacity
					details_info[index].increase_opacity
					grade_texts[index].increase_opacity
				else
					el.decrease_opacity(0.05, 0.4)
					details_info[index].decrease_opacity(0.05, 0.4)
					grade_texts[index].decrease_opacity(0.05, 0.4)
				end
			end
		else
			triangles.increase_opacity
			details_info.each(&:increase_opacity)
			grade_texts.each(&:increase_opacity)
		end
	end

	'NOTE: Neither this game nor these score statistics are based on real life mental test'.each_char.with_index do |c, i|
		Text.new(c, font: Font, x: 5 + i * 6, size: 10, y: $height - 18, color: [1, i / 100.0, 1 - i / 10.0, 1])
	end
end

main

Window.show
