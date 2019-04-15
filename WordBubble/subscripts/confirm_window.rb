#!/usr/bin/ruby -w
require_relative 'x'

PATH = File.dirname(__FILE__)
ARGV.push('quit.png') if ARGV.empty?

define_method(:main) do
	@width, @height, @fps = 200, 100, 30
	@font = File.join(PATH, 'fonts', 'Merienda-Regular.ttf')

	set title: 'Quit WordBubble?', resizable: false, borderless: true, width: @width, height: @height, background: '#FFFFFF'

	quit = Image.load(File.join(PATH, 'images', ARGV[0]))
	quit.x = @width / 2 - quit.width / 2

	button1 = Image.load(File.join(PATH, 'images', 'quit_yes.png'), y: quit.total_y(10))
	button2 = button1.dup

	button1_label = Text.new('Yes', font: @font)
	button2_label = Text.new('No', font: @font)

	button1.x = @width / 2 - (button1.width + button2.width + 10) / 2
	button2.x = button1.total_x(10)

	button1_label.x, button1_label.y = button1.mid_x(button1_label), button1.mid_y(button1_label)
	button2_label.x, button2_label.y = button2.mid_x(button2_label), button2.mid_y(button2_label)

	button1_touched, button2_touched = false, false

	particles = Array.new(50) { Square.new(size: rand(1..2)) }

	on :key_down do |k|
		button1_touched = k.key == 'return' || k.key == 'keypad enter' || k.key == 'left shift' || k.key == 'left' || k.key == 'y'
		button2_touched = k.key == 'space' || k.key == 'escape' || k.key == 'right shift' || k.key == 'right' || k.key == 'n'
	end

	on :key_up do |k|
		STDOUT.print(if k.key == 'return' || k.key == 'keypad enter' || k.key == 'left shift' || k.key == 'left' || k.key == 'y'
			1
		elsif k.key == 'space' || k.key == 'escape' || k.key == 'right shift' || k.key == 'right' || k.key == 'n'
			0
		end)

		close
	end

	on :mouse_move do |e|
		button1_touched, button2_touched = button1.contain?(e), button2.contain?(e)
	end

	on :mouse_up do |e|
		STDOUT.print(0) if button2.contain?(e)
		STDOUT.print(1) if button1.contain?(e)
		close
	end

	update do
		button1_touched ? (button1.decrease_opacity(0.05, 0.3) && (button1_label.g -= 0.05 if button1_label.g > 0.3)) : (button1.increase_opacity && (button1_label.g += 0.05 if button1_label.g < 1))
		button2_touched ? (button2.decrease_opacity(0.05, 0.3) && (button2_label.g -= 0.05 if button2_label.g > 0.3)) : (button2.increase_opacity && (button2_label.g += 0.05 if button2_label.g < 1))

		particles.each_with_index do |el, index|
			el.x += Math.sin(index)
			el.y -= index / 25.0

			el.x, el.y = rand(0..@width), rand(0..@height) if el.y <= -el.height
		end
	end
end

main

Window.show
