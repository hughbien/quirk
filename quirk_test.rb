require 'rubygems'
require "#{File.dirname(__FILE__)}/quirk"
require 'minitest/autorun'

Quirk.today = Date.new(2012, 1, 5) # 1 Su, 2 Mo, 3 Tu, 4 We, 5 Th

class QuirkAppTest < MiniTest::Unit::TestCase
  def setup
    @app = Quirk::App.new(File.join(File.dirname(__FILE__), 'quirkfile'))
  end
end

class QuirkHabitTest < MiniTest::Unit::TestCase
  def test_parse
    habit = Quirk::Habit.parse(' running:  monday , tuesday, wednesday')
    assert_equal('running', habit.id)
    assert_equal([1, 2, 3], habit.days)
    refute(habit.quitting?)

    habit2 = Quirk::Habit.parse('walk-dog: everyday')
    assert_equal('walk-dog', habit2.id)
    assert_equal([0, 1, 2, 3, 4, 5, 6], habit2.days)
    refute(habit2.quitting?)

    habit3 = Quirk::Habit.parse('^quit-tv: everyday')
    assert_equal('quit-tv', habit3.id)
    assert_equal([0, 1, 2, 3, 4, 5, 6], habit3.days)
    assert(habit3.quitting?)
  end

  def test_color_on
    habit = Quirk::Habit.parse('running: sunday, monday, wednesday, thursday')
    habit.mark!(Date.new(2012, 1, 2))
    habit.mark!(Date.new(2012, 1, 3))
    assert_equal(:white, habit.color_on(Date.new(2012, 1, 1)))
    assert_equal(:green, habit.color_on(Date.new(2012, 1, 2)))
    assert_equal(:white, habit.color_on(Date.new(2012, 1, 3)))
    assert_equal(:red, habit.color_on(Date.new(2012, 1, 4)))
    assert_equal(:white, habit.color_on(Date.new(2012, 1, 5)))
  end

  def test_color_on_quit
    quit = Quirk::Habit.parse('^quit-tv: sunday, monday, wednesday, thursday')
    quit.mark!(Date.new(2012, 1, 2))
    assert_equal(:white, quit.color_on(Date.new(2012, 1, 1)))
    assert_equal(:red, quit.color_on(Date.new(2012, 1, 2)))
    assert_equal(:white, quit.color_on(Date.new(2012, 1, 3)))
    assert_equal(:green, quit.color_on(Date.new(2012, 1, 4)))
    assert_equal(:green, quit.color_on(Date.new(2012, 1, 5)))

    quit.mark_first!(Date.new(2012, 1, 1))
    assert_equal(:green, quit.color_on(Date.new(2012, 1, 1)))
  end

  def test_streak
    missing = Quirk::Habit.parse('running: everyday')
    assert_equal(0, missing.streak)

    perfect = Quirk::Habit.parse('running: monday, wednesday')
    perfect.mark!(Date.new(2012, 1, 2))
    perfect.mark!(Date.new(2012, 1, 4))
    assert_equal(2, perfect.streak)

    bad = Quirk::Habit.parse('running: monday, tuesday, wednesday')
    bad.mark!(Date.new(2012, 1, 1))
    bad.mark!(Date.new(2012, 1, 2))
    assert_equal(-2, bad.streak)
  end

  def test_streak_quit
    missing = Quirk::Habit.parse('^quit-tv: everyday')
    assert_equal(0, missing.streak)

    perfect = Quirk::Habit.parse('^quit-tv: monday, tuesday')
    perfect.mark!(Date.new(2011, 12, 31))
    perfect.mark!(Date.new(2012, 1, 4))
    assert_equal(2, perfect.streak)

    bad = Quirk::Habit.parse('^quit-tv: sunday, thursday')
    bad.mark!(Date.new(2012, 1, 1)) # sunday
    bad.mark!(Date.new(2012, 1, 5)) # thursday
    assert_equal(-2, bad.streak)
  end
end

class QuirkCalendarTest < MiniTest::Unit::TestCase
  def setup
    @running = Quirk::Habit.parse('running: everyday')
    @walking = Quirk::Habit.parse('walk-dog: sunday, saturday')
    @smoking = Quirk::Habit.parse('^smoking: everyday')
    @cal = Quirk::Calendar.new([@running, @walking, @smoking])
    @cal.mark!('2012/01/01 ^smoking')
    @cal.mark!('2012/01/01 running, walk-dog')
    @cal.mark!('2012/01/02 running, walk-dog')
  end

  def test_mark
    assert_equal([Date.new(2012,1,1), Date.new(2012,1,2)], @running.marks)
    assert_equal([Date.new(2012,1,1), Date.new(2012,1,2)], @walking.marks)
  end

  def test_mark_first
    assert_equal(Date.new(2012, 1, 1), @smoking.first_date)
  end

  def test_streaks
    assert_equal("-2 running\n 0 smoking\n 1 walk-dog", @cal.streaks)
  end
end
