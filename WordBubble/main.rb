#!/usr/bin/ruby -w
STDOUT.sync = true

PATH = ::File.dirname(__FILE__)
require_relative File.join(PATH, 'subscripts', 'x')

WORDS = ::Z.readfile(::File.join(PATH, 'words', 'small'))
VALID_WORDS = ::Z.readfile(::File.join(PATH, 'words', 'valid_words'))
VALID_WORDS_DUP = ::VALID_WORDS.clone
RECORD_SCORE = ::File.join(PATH, 'subscripts', 'data', 'scorelist.data')

define_method(:main) do
	@font = File.join(PATH, 'fonts', 'EncodeSansCondensed-Regular.ttf')
	@width, @height, @fps = 480, 640, 45
	set title: 'Word Bubble', fps_cap: @fps, width: @width, height: @height, resizable: true

	overlay = Rectangle.new(width: @width, height: @height, z: 99, color: '#000000', opacity: 0)
	Rectangle.new(width: @width, height: @height, color: ['#5A5FFF', '#FF4194', '#3ce3b4', '#FF4194'])

	keys_row1, keys_row2, keys_row3 = %w(q w e r t y u i o p), %w(a s d f g h j k l), %w(prev z x c v b n m del)
	all_keys = keys_row1 + keys_row2 + keys_row3

	# Draw the background animated particles
	particles = Array.new(50) { Square.new(size: rand(1..2), x: rand(0..@width), y:rand(0..@height), color: '#FFFFFF', z: 1000) }
	other_particles = Array.new(50) { Square.new(size: rand(1..2), x: 0, y: 0, color: '#FFFFFF', z: 1000) }
	timer_particles = Array.new(50) { Square.new(size: rand(1..2), x: 0, y: 0, color: '#FFFFFF', z: 100, opacity: 0) }
	bg_particles = Array.new(50) { Square.new(size: rand(1..2), x: 0, y: 0, color: '#FFFFFF') }
	star_particles = Array.new(50) { Image.load(File.join(PATH, 'images', 'small_star.png'), width: 10, height: 10, z: 1000, opacity: 0) }

	# Draw the keyboard layout
	keyboard_layout = Rectangle.new(width: @width, height: @height/2.5, color: ['#5A5FFF', '#FF4194', '#FFD300', '#FFD300'])
	keyboard_layout.y = @height - keyboard_layout.height

	# Draw the text box
	text_box = Rectangle.new(width: @width, height: 50, color: '#FFFFFF')
	text_box.y = keyboard_layout.y - text_box.height

	# Draw the characters
	typed = ''
	typed_text = Text.new(typed, font: @font, size: 25, color: '#000000')
	typed_text.x, typed_text.y = 5, text_box.mid_y(typed_text)

	# Draw the flashing cursor on text box after typed text
	cursor = Line.new(x1: typed_text.total_x(5), x2: typed_text.total_x(5), color: '#000000')
	cursor.y1, cursor.y2 = text_box.y + 5, text_box.total_y(-5)

	# Draw the keyboard
	keys, shadows = [], []

	keys_row1.each_with_index do |el, temp|
		keys.push(key = Image.load(File.join(PATH, 'images', 'keys.png'), x: temp.+(0.4).*(@width / 10.5), y: keyboard_layout.y + 10, width: @width / 15, height: @height / 12))

		shadow = Image.load(File.join(PATH, 'images', 'key_shadow.png'), x: key.x, y: key.y, width: key.width * 2, height: key.height * 2)
		shadow.x, shadow.y = key.x - (shadow.width - key.width) / 2, key.y - (shadow.height - key.height) / 2
		shadows.push(shadow)

		text = Text.new(el, font: @font, color: '#000000')
		text.x, text.y = key.mid_x(text), key.mid_y(text)
	end

	row = keys[-1].y + keys[-1].height + 10
	keys_row2.each_with_index do |el, temp|
		keys.push(key = Image.load(File.join(PATH, 'images', 'keys.png'), x: temp.+(1) * (@width / 10.5), y: row, width: @width / 15, height: @height / 12))

		shadow = Image.load(File.join(PATH, 'images', 'key_shadow.png'), width: key.width * 2, height: key.height * 2)
		shadow.x, shadow.y = key.x - (shadow.width - key.width) / 2, key.y - (shadow.height - key.height) / 2
		shadows.push(shadow)

		text = Text.new(el, font: @font, color: '#000000')
		text.x, text.y = key.mid_x(text), key.mid_y(text)
	end

	score_label = Text.new('Score: 0', font: @font, size: 12, z: 100, opacity: 1)
	score_label.x, score_label.y = @width - score_label.width - 10, 5

	row = keys[-1].y + keys[-1].height + 10
	keys_row3.each_with_index do |el, temp|
		if el == 'prev'
			key = Image.load(File.join(PATH, 'images', 'item.png'), x: keys[0].x, y: row, width: @width / 10, height: @height / 12)
			arrow = Image.load(File.join(PATH, 'images', 'prev_arrow.png'), color: '#000000')

			arrow.x, arrow.y = key.mid_x(arrow), key.mid_y(arrow)

			shadow = Image.load(File.join(PATH, 'images', 'items_shadow.png'), width: key.width * 2, height: key.height * 2)
			shadow.x, shadow.y = key.x - (shadow.width - key.width) / 2, key.y - (shadow.height - key.height) / 2

		elsif el == 'del'
			key = Image.load(File.join(PATH, 'images', 'item.png'), x: temp.+(0.7) * (@width / 10), y: row, width: @width / 10, height: @height / 12)

			shadow = Image.load(File.join(PATH, 'images', 'items_shadow.png'), width: key.width * 2, height: key.height * 2)
			shadow.x, shadow.y = key.x - (shadow.width - key.width) / 2, key.y - (shadow.height - key.height) / 2

			text = Text.new(el, font: @font, color: '#000000')
			text.x, text.y = key.mid_x(text), key.mid_y(text)
		else
			key = Image.load(File.join(PATH, 'images', 'keys.png'), x: temp.+(0.7) * (@width / 10), y: row, width: @width / 15, height: @height / 12)

			shadow = Image.load(File.join(PATH, 'images', 'key_shadow.png'), width: key.width * 2, height: key.height * 2)
			shadow.x, shadow.y = key.x - (shadow.width - key.width) / 2, key.y - (shadow.height - key.height) / 2

			text = Text.new(el, font: @font, color: '#000000')
			text.x, text.y = key.mid_x(text), key.mid_y(text)
		end

		keys.push(key)
		shadows.push(shadow)
	end
	keys.each { |el| el.color = '#FFFFFF' }
	shadows.each { |el| el.color = '#00ff00' }

	# The colourful timer. rainbow_lapse keeps getting incresed by a fraction and the lines change the colour based on that.
	rainbow_lapse = 0
	lines = Array.new(@width / 4) { |i| Image.load(File.join(PATH, 'images', 'circle_6_pixels.png'), x: i * 3.0 + @width / 8, y: 20, z: 100) }
	lines_size, lines_size_by_two = lines.size, lines.size./(2.0).ceil

	# The pause button, images and the pause screen.
	paused = Image.load(File.join(PATH, 'images', 'paused.png'), y: lines[0].total_y, z: 100, opacity: 0).to_centre_x

	pause_touched, pause_var = false, 0
	pause = Image.load(File.join(PATH, 'images', 'pause.png'), x: 5, y: 5, z: 100)

	pause_bar1 = Rectangle.new(width: pause.width / 5, height: pause.height / 1.5, color: %w(#995AFA #995AFA #FFFF00 #FFFF00), z: 100)
	pause_bar2 = Rectangle.new(width: pause_bar1.width, height: pause_bar1.height, color: pause_bar1.get_colour, z: pause_bar1.z)

	play_button = Image.load(File.join(PATH, 'images', 'play.png'), x: pause.x, y: pause.y, z: 100)
	play_button.x, play_button.y = pause.mid_x(play_button), pause.mid_y(play_button)
	play_button2 = Image.load(File.join(PATH, 'images', 'play_img.png'), z: 100)
	play_button2.x, play_button2.y = play_button.mid_x(play_button2), play_button.mid_y(play_button2)

	pause_bar1.x, pause_bar1.y = pause.x + pause.width / 3.5 - pause_bar1.width / 3, pause.y + pause.height / 6
	pause_bar2.x, pause_bar2.y = pause_bar1.total_x(4), pause_bar1.y

	# key sounds first
	fanfare1 = Sound.new(File.join(PATH, 'sounds', '397355__plasterbrain__tada-fanfare-a.flac'))
	fanfare2 = Sound.new(File.join(PATH, 'sounds', '397354__plasterbrain__tada-fanfare-f.flac'))
	fanfare3 = Sound.new(File.join(PATH, 'sounds', '397353__plasterbrain__tada-fanfare-g.flac'))
	key_sound1 = Sound.new(File.join(PATH, 'sounds', 'key_sound1.wav'))
	key_sound_backspace = Sound.new(File.join(PATH, 'sounds', 'key_sound_backspace.wav'))
	key_sound_enter = Sound.new(File.join(PATH, 'sounds', 'key_sound_enter.wav'))
	correct, warning, wrong = Sound.new(File.join(PATH, 'sounds', 'correct.wav')), Sound.new(File.join(PATH, 'sounds', 'warning.wav')), Sound.new(File.join(PATH, 'sounds', 'wrong.wav'))
	game_ending = Music.new(File.join(PATH, 'sounds', 'game_ending.wav'))

	# Draw the enter button
	enter_button = Rectangle.new(width: @width, y: keys[-1].y + keys[-1].height + 15, color: keys[-1].get_colour)
	enter_button.height = @height - enter_button.y
	enter_button_text = Text.new('Enter', font: @font, color: '#000000')
	enter_button_text.x, enter_button_text.y = enter_button.mid_x(enter_button_text), enter_button.mid_y(enter_button_text)
	keys.push(enter_button)

	# Other important variables
	already_typed, already_typed_messages, last = Array.new(3) { [] }
	no_enter = true
	next_typed = ''
	updated_time = Time.new.strftime('%s').to_i
	mem_index = 0
	obj = nil
	game_interrupted, game_overed = true, false
	score_recorded = false
	question, question_length = 0, 0

	# Draw the magical images!
	unlocks  = Array.new(6) do |i|
		temp = Image.load(File.join(PATH, 'images', 'unlocked.png'), z: 1)
		temp.x, temp.y = i * @width / 6.0 + 10, text_box.y - temp.height - 15
		temp
	end

	unlocked_shadows = unlocks.map do |u|
		temp = Image.load(File.join(PATH, 'images', 'unlocked_shadow.png'))
		temp.x, temp.y = u.x - (temp.width - u.width) / 2, u.y - (temp.height - u.height) / 2
		temp
	end

	coin_sprite = []
	sprite_gen = ->(object) do
		sprite = Sprite.new(File.join(PATH, 'images', 'coin_sprite.png'), loop: true, clip_width: 85, time: rand(5..20), width: 40, height: 40)
		sprite.x, sprite.y = object.mid_x(sprite), object.mid_y(sprite)
		sprite.play
		coin_sprite.push(sprite)
	end

	uhm = []
	uhs = Array.new(6) { [] }.zip([['#FFFF00', '3, 4'], ['#FF8730', '5'], ['#FF5F60', '6'], ['#FF0088', '7'], ['#E014D7', '8'], ['#8700D7', '9+']]).map.with_index do |u, i|
		4.times.map do |index|
			img = Image.load(File.join(PATH, 'images', 'unlocked_highlight.png'), opacity: 1, x: unlocks[i].x, y: unlocks[i].y, color: u[1][0], z: 1000, rotate: 90)

			# Generate text in the middle of the Ruby2D::Image objects
			t = Text.new(u[1][1], font: @font)
			t.x, t.y = unlocks[i].mid_x(t), unlocks[i].mid_y(t)

			case index
				when 1 then img.rotate += 90
				when 2 then img.rotate += 180
				when 3 then img.rotate += 270
			end

			img
		end
	end

	# Declare variables related to magic images!
	three_four = five = six = seven = eight = nine_plus = 0
	streaks = [three_four, five, six, seven, eight, nine_plus]

	stars = Array.new(6) { |el| Image.load(File.join(PATH, 'images', 'star.png'), z: 101, x: unlocks[el].x, y: unlocks[el].y, color: '#FFFF00') }

	select_word  = ->(range=1) { [(typed_text.text.clear.concat(WORDS.select { |el| el.length == range + 1 }.sample )).clone, range + 1] }

	score = level = streak = 0
	is_truncated = false

	generate_messages = ->(message='') { message.each_line.with_index { |el, index| already_typed_messages.push(Text.new(el.strip, font: @font, y: @height / (4 - index))) } }

	level_up, game_interrupted = false, false

	space_to_enter = Image.load(File.join(PATH, 'images', 'space_to_enter.png'), opacity: 0, z: 100).to_centre_x
	space_to_enter.y = unlocked_shadows[0].y - space_to_enter.height - 5

	level_img = Image.load(File.join(PATH, 'images', 'level.png'), opacity: 0, z: 100).to_centre_x
	one = Image.load(File.join(PATH, 'images', '1.png'), y: level_img.total_y(5), opacity: 0, z: 100).to_centre_x
	press_space = Image.load(File.join(PATH, 'images', 'press_space.png'), opacity: 0, z: 100).to_centre_x

	level_img.y = unlocked_shadows[0].y - level_img.height - one.height - press_space.height - 15
	one.y = level_img.total_y(5)
	press_space.y = one.total_y(5)

	two = Image.load(File.join(PATH, 'images', '2.png'), y: level_img.total_y(5), opacity: 0, z: 100).to_centre_x
	three = Image.load(File.join(PATH, 'images', '3.png'), y: level_img.total_y(5), opacity: 0, z: 100).to_centre_x

	game_over_img = Image.load(File.join(PATH, 'images', 'game_over_img.png'), y: level_img.y, opacity: 0, z: 100).to_centre_x

	correct_guessed = Text.new('Correct Words: 100', font: @font, y: lines[0].total_y, z: 100, size: 15).to_centre_x
	correct_guessed_var = 0

	stat_button = Image.load(File.join(PATH, 'images', 'stat_button.png'), y: game_over_img.total_y(20), z: 100, opacity: 0)
	stat_button.x = @width / 2 - (stat_button.width * 3 + 40) / 2
	quit_button = Image.load(File.join(PATH, 'images', 'quit_button.png'), x: stat_button.total_x(20), y: stat_button.y, z: stat_button.z, opacity: 0)
	restart_button = Image.load(File.join(PATH, 'images', 'restart_button.png'), x: quit_button.total_x(20), y: stat_button.y, z: stat_button.z, opacity: 0)
	buttons = stat_button, quit_button, restart_button

	final_score_text, final_score_var, sent_hurry_up = Text.new('Score: 1024', font: @font, size: 25, z: 100, y: stat_button.total_y(25), opacity: 0).to_centre_x, 0, false

	buttons_shadows = Array.new(3) do |i|
		temp = Image.load(File.join(PATH, 'images', 'buttons_shadow.png'), z: buttons[i].z, opacity: 0)
		temp.x, temp.y = buttons[i].x - (temp.width - buttons[i].width) / 2, buttons[i].y - (temp.height - buttons[i].height) / 2
		temp
	end

	rainbow_lapse = lines_size

	add_streak = ->(points, object) do
		streak = points
		text = Text.new("+#{streak}", font: @font)
		text.x, text.y = object.mid_x(text), object.y - text.height - 5
		uhm.push(text)
	end

	check_word = -> do
		temp, streak = typed_text.text.strip, 0

		if VALID_WORDS_DUP.include?(temp)
			already_typed.push(temp)
			VALID_WORDS_DUP.delete(temp)

			correct.play
			correct_guessed_var += 1

			score += typed_text.text.length * 10

			case temp.length
				when 0..2
				when 3..4
					three_four += 1
					sprite_gen.(unlocks[0])
					add_streak.(100, unlocks[0]) if three_four >= 4

				when 5
					five += 1
					sprite_gen.(unlocks[1])
					add_streak.(250, unlocks[1]) if five >= 4

				when 6
					six += 1
					sprite_gen.(unlocks[2])
					add_streak.(500, unlocks[2]) if six >= 4

				when 7
					seven += 1
					sprite_gen.(unlocks[3])
					add_streak.(750, unlocks[3]) if seven >= 4

				when 8
					eight += 1
					sprite_gen.(unlocks[4])
					add_streak.(1000, unlocks[4]) if eight >= 4

				else
					nine_plus += 1
					sprite_gen.(unlocks[5])
					add_streak.(1000 + temp.length * 25, unlocks[5]) if nine_plus >= 4
			end

			streaks.clear.append(three_four, five, six, seven, eight, nine_plus)

		elsif already_typed.include?(temp)
			warning.play
			generate_messages.call("Already typed: #{temp}")
		else
			wrong.play
		end

		score += streak
		typed_text.text[question_length..-1], mem_index = '', 0

		last.push(temp)
	end

	button_shadow = nil
	on :mouse_move do |e|
		keys.each { |el| el.contain?(e) ? ((obj = el) && (break)) : obj = nil }

		particle = particles.sample
		particle.x, particle.y, particle.opacity = e.x - particle.size / 2, e.y - particle.size / 2, 1
		pause_touched = pause.contain?(e)

		stars.each { |el| el.change_colour = el.contain?(e) ? '#FFFFFF' : '#FFFF00' }
		buttons.each_with_index { |el, i| el.contain?(e) ? ((button_shadow = buttons_shadows[i]) && break) : (button_shadow = false) }
	end

	on :mouse_down do |e|
		pause_var += 1 if pause.contain?(e) and not(game_overed) and not(level_up)

		star_particles.sample(rand(10..15)).each do |el|
			unless el.opacity > 0
				size = rand(5..10)
				el.x, el.y, el.opacity, el.width, el.height, el.color  = rand(e.x - 10..e.x + 10), rand(e.y - 10..e.y + 10), 1, size, size, "##{SecureRandom.hex(3)}"
			end
		end
		if game_overed || game_interrupted
			buttons.each do |el|
				if el.contain?(e)
					if el.equal?(stat_button)
						Thread.new { Open3.popen3('ruby', File.join(PATH, 'subscripts', 'stats.rb')) }

					elsif el.equal?(restart_button)
						pause_var += 1 if game_interrupted
						level = 1
						fanfare1.play

						rainbow_lapse = streak = score = 0
						is_truncated = level_up = game_overed = game_interrupted = sent_hurry_up = false
						updated_time = Time.now.strftime('%s').to_i
						question, question_length = select_word.call(level)
						generate_messages.call("Words Starting With: #{question}")
						lines.each { |el| el.color = '#FFFFFF' }

						already_typed.clear
						last.clear
						next_typed.clear

						three_four = five = six = seven = eight = nine_plus = 0
						uhs.each { |el| el.each { |ele| ele.opacity = 0 } }
						streaks.clear.append(three_four, five, six, seven, eight, nine_plus)

						VALID_WORDS_DUP.clear.concat(VALID_WORDS)

					elsif el.equal?(quit_button)
						Thread.new { close if Open3.capture2('ruby', File.join(PATH, 'subscripts', 'confirm_window.rb'), 'quit.png')[0] == '1' }
					end
				end
			end
		end
	end

	on :mouse_up do |e|
		key_index = -1
		all_keys.each do |el|
			key_index += 1
			key = keys[key_index]

			if !((game_interrupted or game_overed) || level_up)
				if key.contain?(e)
					if el.scan(/[a-z]/).size == 1
						(typed_text.text.concat(el) && (break))

					elsif el == 'prev'
						mem_index -= 1 if mem_index > -last.size
						ll = last[mem_index]

						((obj = keys.select { |el| el.path.include?('item') if Ruby2D::Image === el }[0]) && (obj.b = -0.5))
						next_typed = typed_text.text.dup if next_typed.empty?
						typed_text.text.clear.concat(ll) unless nil === ll
						((key_sound_backspace.play) || (break))

					elsif el == 'del'
						if typed_text.text.length > question.length
							typed_text.text.chop!
							obj = keys[-2]
							obj.b = -0.5
							key_sound_backspace.play
							break
						end
					end
				end

				if enter_button.contain?(e)
					shadows.each { |el| el.color, el.opacity = '#FFFFFF', 1 }
					check_word[]
					((key_sound_enter.play) | (obj, keys.last.b, no_enter = keys[-1], -0.5, false) && (break))
				end
			end
		end
	end

	on :key_down do |k|
		if !((game_interrupted or game_overed) || level_up)
			updated_time = Time.new.strftime('%s').to_i

			key_index = -1
			all_keys.each do |el|
				key_index += 1
				if k.key == el
					key = keys[key_index]
					typed_text.text.concat(el)
					key_sound1.play if typed_text.text
					obj, key.b, shadows[key_index].opacity = key, -0.5, 1
					break

				elsif ['space', 'return', 'keypad enter'].include?(k.key)
					shadows.each { |el| el.color, el.opacity = '#ffffff', 1.5 }
					check_word[]
					((key_sound_enter.play) | (obj, keys.last.b, no_enter = keys[-1], -0.5, false) && (break))

				elsif [%q(left shift), %q(up)].include?(k.key)
					mem_index -= 1 if mem_index > -last.size
					ll = last[mem_index]

					((obj = keys.select { |el| el.path.include?('item') if Ruby2D::Image === el }[0]) && (obj.b = -0.5))
					next_typed = typed_text.text.dup if next_typed.empty?
					typed_text.text.clear.concat(ll) unless nil === ll
					((key_sound_backspace.play) || (break))

				elsif ['right shift', 'down'].include?(k.key)
					if mem_index < -1
						mem_index += 1
						ll = last[mem_index]
						typed_text.text.clear.concat(ll) unless ll.nil?
					else
						typed_text.text.clear.concat(question)
						mem_index = 0
					end
					break

				elsif %w(backspace delete).include?(k.key)
					if typed_text.text.length > question_length
						obj = keys[-2]
						obj.b = -0.5
						key_sound_backspace.play
						typed.chop!
						break
					end
				end
			end

		elsif k.key == 'space' && (!game_interrupted && !game_overed)
			is_truncated = sent_hurry_up = false
			level = level_up ? level + 1 : 1

			case level
				when 1 then fanfare1.play
				when 2 then fanfare2.play
				when 3 then fanfare3.play
			end

			rainbow_lapse = correct_guessed_var = 0

			level_up = false
			updated_time = Time.now.strftime('%s').to_i
			question, question_length = select_word.call(level)
			generate_messages.call("Words Starting With: #{question}")
			lines.each { |el| el.color = '#FFFFFF' }

			already_typed.clear
			last.clear
			next_typed.clear

			three_four = five = six = seven = eight = nine_plus = 0
			uhs.each { |el| el.each { |ele| ele.opacity = 0 } }
			streaks.clear.append(three_four, five, six, seven, eight, nine_plus)

			VALID_WORDS_DUP.clear.concat(VALID_WORDS)
		elsif (k.key == 'space' && game_interrupted) && !game_overed
			pause_var += 1

		elsif k.key == 'escape'
			Thread.new { close if Open3.capture2('ruby', File.join(PATH, 'subscripts', 'confirm_window.rb'), 'quit.png')[0] == '1' }
		end
	end

	held_time, held = 0, true

	on :key_held do |k|
		unless game_interrupted or game_overed
			if typed_text.text.length > question_length
				held_time += 1
				held = true if held_time % (@fps / 3.0).to_i == 0
				if %w(backspace delete).include?(k.key) && held then
					typed.chop!
					key_sound_backspace.play
				end
			end
		end
	end

	on :key_up do |k| obj, held, held_time = nil, false, 0 end
	cursor_op_control = 0.05

	counter = 0
	update do
		# counter controls time, each second an @fps passes!!
		counter += 1

		if space_to_enter.opacity > 0
			space_to_enter.y += Math.sin(counter / 10.0)
		else
			space_to_enter.y = unlocked_shadows[0].y - space_to_enter.height - 5
		end

		if press_space.opacity > 0
			press_space.y += Math.sin(counter / 10.0)
		else
			press_space.y = unlocked_shadows[0].y - press_space.height
		end

		if rainbow_lapse >= lines_size
			case level
				when 0 then [space_to_enter]
				when 1 then [two, level_img, press_space]
				when 2 then [three, level_img, press_space]
				else game_over_img
			end.increase_opacity

			level >= 3 ? (game_overed, level_up = true, false) : (level_up = true)

		else
			interrupt_counter = 0 unless interrupt_counter == 0
			[level_img, one, two, three, press_space, space_to_enter, game_over_img].decrease_opacity
		end

		unless game_interrupted or game_overed or level_up
			stars.decrease_opacity
			timer_particles.increase_opacity

			lines[rainbow_lapse].b = rainbow_lapse / 100.0
			lines[rainbow_lapse].g = 1 - rainbow_lapse / 100.0

			temp_particle = timer_particles.sample

			enter_button_text.b = rainbow_lapse / 100.0
			enter_button_text.g = 1 - rainbow_lapse / 100.0

			temp_particle.x = rand(lines[rainbow_lapse].x - 10..lines[rainbow_lapse].x + 10)
			temp_particle.y = rand(lines[rainbow_lapse].y - 10..lines[rainbow_lapse].y + 10)

			# Should be @width / 28 for proper timing
			rainbow_lapse += 1 if counter % (@width / 28) == 0

			if (rainbow_lapse >= lines_size_by_two && question[0..question_length] == typed_text.text) && !is_truncated && level > 1
				is_truncated = true
				question = question[0..-2]
				question_length = question.length
				generate_messages.call("Words that Starts with #{question}")
				typed_text.text.clear.concat(question)
			end

			overlay.decrease_opacity

			unlocked_shadows.each do |x|
				if typed_text.text.length > question_length
					case typed_text.text.length.next
						when 0..5 then unlocked_shadows[0]
						when 6 then unlocked_shadows[1]
						when 7 then unlocked_shadows[2]
						when 8 then unlocked_shadows[3]
						when 9 then unlocked_shadows[4]
						else unlocked_shadows[5]
					end.increase_opacity
					x.decrease_opacity
				else
					x.decrease_opacity(0.1)
				end
			end

			if Time.new.strftime('%s').to_i > updated_time + 5
				generate_messages.call("How about \"#{VALID_WORDS_DUP.select { |el| el.start_with?(typed_text.text[0...question_length]) }.sample }\"")
				updated_time = Time.new.strftime('%s').to_i
			end

			# set up the score and time labels
			score_label.text = "Score: #{score}"
			score_label.x = @width - score_label.width - 10

			# Keyboard related stuffs!
			cursor_op_control = 0.1 if cursor.opacity <= 0
			cursor_op_control = -0.1 if cursor.opacity >= 1

			cursor.opacity += cursor_op_control

			typed_text.text = typed
			cursor.x1 = cursor.x2 = typed_text.total_x(3)

			if typed_text.total_x > @width - 10 then typed_text.x -= 7
			elsif typed_text.x < 10 && typed_text.total_x(20) < @width then typed_text.x += 7
			end

			if obj
				shadows.each_with_index { |el, i| el.opacity += 0.1 if keys[i].equal?(obj) && el.opacity < 1 }
				obj.b -= 0.15 if obj.b > 0
				keys.each { |el| el.b += 0.03 if el.b < 1 && !el.equal?(obj) }
			else
				shadows.each { |el| el.opacity -=  0.05 if el.opacity > 0 }
				keys.each { |el| el.b += 0.03 if el.b < 1 }
				no_enter = true if shadows.last.opacity <= 0
			end

			shadows.each { |el| el.change_colour = '#FFFF00' unless el.color == '#FFFF00' } if no_enter
		else
			game_ending.stop
			overlay.increase_opacity(0.05, 0.5)
			timer_particles.decrease_opacity(0.01)
		end

		# Code that will run regardless the game is paused/over or not.
		uhs.each_with_index { |el, index| el.take(streaks[index]).increase_opacity }
		final_score_text.x += Math.sin(counter / 10.0)

		correct_guessed.text = "Typed: #{correct_guessed_var}"
		correct_guessed.to_centre_x

		if game_interrupted
			buttons.increase_opacity
			[pause_bar1, pause_bar2].decrease_opacity
			[play_button, play_button2, paused].increase_opacity
			play_button.rotate += 5
			paused.y += Math.sin(counter / 10.0)
		else
			if counter % @fps == 0
				game_ending.play
				unless sent_hurry_up
					generate_messages.('Hurry Up!')
					sent_hurry_up = true
				end
			end if rainbow_lapse >= lines.size / 1.5 && rainbow_lapse < lines_size

			[play_button, play_button2, paused].decrease_opacity
			[pause_bar1, pause_bar2].increase_opacity
			play_button2.change_colour = '#FFFFFF' unless play_button2.color == '#FFFFFF'
			play_button2.rotate += 15
			play_button2.rotate = 0 if play_button2.opacity <= 0 and play_button2.rotate != 0
			paused.y = lines[0].total_y if paused.opacity > 0 if paused.y < lines[0].total_y
		end

		if game_overed
			stars[0].increase_opacity if three_four >= 4
			stars[1].increase_opacity if five >= 4
			stars[2].increase_opacity if six >= 4
			stars[3].increase_opacity if seven >= 4
			stars[4].increase_opacity if eight >= 4
			stars[5].increase_opacity if nine_plus >= 4

			final_score_text.increase_opacity
			unlocked_shadows.each { |el| el.increase_opacity.z = 100 }

			final_score_var += score / 10.0 unless final_score_var >= score
			final_score_text.text = "Score: #{final_score_var}" unless final_score_text.text == score_label.text

			File.open(RECORD_SCORE, 'a') { |f| f.puts(score.to_s.unpack('h*')[0]) } unless score_recorded
			score_recorded ||= true
		else
			final_score_text.decrease_opacity
			score_recorded = false if score_recorded
		end

		if game_overed || game_interrupted
			buttons.increase_opacity

			if button_shadow
				button_shadow.increase_opacity
				buttons_shadows.each { |el| el.decrease_opacity unless el.equal?(button_shadow) }
			else
				buttons_shadows.decrease_opacity
			end
		else
			buttons.decrease_opacity
			buttons_shadows.decrease_opacity
		end

		if level_up
			unlocked_shadows.each { |el| el.increase_opacity.z = 100 }

			stars[0].increase_opacity if three_four >= 4
			stars[1].increase_opacity if five >= 4
			stars[2].increase_opacity if six >= 4
			stars[3].increase_opacity if seven >= 4
			stars[4].increase_opacity if eight >= 4
			stars[5].increase_opacity if nine_plus >= 4

			other_particles.each_with_index do |el, index|
				unless el.opacity <= 0
					el.x += Math.sin(index)
					el.y += Math.cos(index) - 1
					el.opacity -= rand(0.001..0.05)
				else
					el.opacity = 1
					el.x, el.y = rand(press_space.x..press_space.total_x), rand(press_space.y..press_space.total_y)
				end
			end
		else
			other_particles.decrease_opacity
		end

		game_interrupted = pause_var % 2 == 1

		if pause_touched
			pause.decrease_opacity(0.05, 0.2)
			play_button2.change_colour = '#FFFFFF' unless play_button2.color == '#FFFFFF'
			play_button2.rotate += 10 unless play_button2.rotate >= 180 and game_interrupted
		else
			play_button2.b -= 0.03 unless play_button2.b <= 0
			play_button2.g -= 0.03 unless play_button2.g <= 0
			play_button2.rotate -= 10 unless play_button2.rotate <= 0 and game_interrupted
			pause.increase_opacity
		end

		coin_sprite.each do |el|
			el.y -= 3
			el.opacity -= 0.03

			if el.y <= -el.height
				el.remove
				coin_sprite.delete(el)
			end
		end

		# animate already typed message
		already_typed_messages.each_with_index do |el, index|
			el.opacity -= 0.0075

			unless el.opacity <= 0 || el.y < -el.height
				el.x = @width / 2 - el.width / 2
				el.y -= index + 1
			else
				el.remove
				already_typed_messages.delete(el)
			end
		end

		# animate streak texts
		uhm.each do |el|
			el.y -= 1
			el.opacity -= 0.005
		end

		# particles animations
		particles.each_with_index do |el, index|
			unless el.opacity <= 0
				el.x += Math.cos(index)
				el.y += Math.sin(index)
				el.opacity -= 0.01
			end
		end

		timer_particles.each_with_index do |el, index|
			unless el.opacity <= 0
				el.x += Math.sin(index)
				el.y += Math.cos(index)
				el.g = rainbow_lapse / 100.0
			else
				el.x = rand(lines[rainbow_lapse].x - 10..lines[rainbow_lapse].x + 10) if lines[rainbow_lapse]
				el.y = rand(lines[rainbow_lapse].y - 10..lines[rainbow_lapse].y + 10) if lines[rainbow_lapse]
			end
		end

		bg_particles.each_with_index do |el, index|
			unless el.y < -el.height
				el.x += Math.cos(index)
				el.y -= index / 10.0
			else
				el.x, el.y = rand(0..@width), @height
			end
		end

		star_particles.each_with_index do |el, index|
			unless el.opacity <= 0
				el.x += Math.sin(index)
				el.y += Math.cos(index)
				el.decrease_opacity(0.025)
				el.rotate += index / 10.0
			end
		end
	end

	%q(Good::LUCK)
end

main && Window.show
