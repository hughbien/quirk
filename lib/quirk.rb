require 'date'
require 'colorize'

module Quirk
  VERSION = '0.0.5'
  QUIRKFILE = ENV['QUIRKFILE'] || "#{ENV['HOME']}/.quirk"
  EDITOR = ENV['EDITOR'] || 'vi'

  def self.today
    @today || Date.today
  end

  def self.today=(date) # for testing
    @today = date
  end

  class App
    def initialize(quirkfile = QUIRKFILE)
      @quirkfile = quirkfile
    end

    def calendar(habit_id)
      puts cal.output(habit_id)
    end

    def edit
      `#{EDITOR} #{QUIRKFILE} < \`tty\` > \`tty\``
    end

    def mark(habit_id)
      contents = File.read(@quirkfile)
      return if !cal.has_habit?(habit_id)

      date = Quirk.today.strftime('%Y/%m/%d')
      match = contents.match(/^(#{date} .*)$/)
      if match # already has date, add habit to line
        old_line = match.captures[0]
        ids = old_line.strip.split(/\s+/, 2)[1].split(',').map(&:strip)
        ids << habit_id
        ids = ids.sort.uniq
        new_line = "#{date} #{ids.join(', ')}"
        contents.sub!(old_line, new_line)
        File.open(@quirkfile, 'w') { |f| f.print(contents) }
      else
        File.open(@quirkfile, 'a') { |f| f.puts("#{date} #{habit_id}") }
      end
    end

    def streaks
      puts cal.streaks
    end

    def year=(year)
      raise "Invalid year: #{year}" if year !~ /\d\d\d\d/
      cal.year = year.to_i
    end

    private
    def cal
      @cal ||= Calendar.parse(File.read(@quirkfile))
    end
  end

  class Habit
    attr_reader :id, :days, :marks

    def initialize(id, days)
      @id, @days, @marks = id, days, []
      raise "No days found for #{id}" if @days.empty?
    end

    def mark!(date)
      @marks << date
      @marks.sort
    end

    def mark_first!(date)
      @first_date = date
    end

    def mark_last!(date)
      @last_date = date
    end

    def first_date
      @first_date || @marks.first
    end

    def pending?(date)
      weekday = date.strftime("%w").to_i
      days.include?(weekday) && color_on(date) != :light_green
    end

    def color_on(date)
      hit_color = :light_green
      miss_color = :light_red
      last_date = [@last_date, Quirk.today].compact.min
      if first_date.nil? ||
         date < first_date ||
         date > last_date ||
         !days.include?(date.wday)
        :white
      elsif @marks.include?(date)
        hit_color
      else
        date == last_date ? :white : miss_color
      end
    end

    def streak
      return 0 if first_date.nil?

      count = 0
      deltas = {:light_red => -1, :light_green => 1, :white => 0}
      date = Quirk.today
      while date >= first_date && (color = color_on(date)) == :white
        date -= 1
      end

      init_color = color
      while date >= first_date
        color = color_on(date)
        break if color != init_color && days.include?(date.wday)
        date -= 1
        count += deltas[color]
      end
      count
    end

    def self.parse(line)
      line.strip!
      line.gsub!(/\s+/, ' ')

      id, days = line.split(':', 2).map(&:strip)
      self.new(id, parse_days(days))
    end

    def self.parse_days(text)
      originals = text.split(',').map(&:strip)
      days = []
      if originals.include?('everyday')
        (0..6).to_a
      else
        %w(sunday monday tuesday wednesday
           thursday friday saturday).each_with_index do |day, index|
          days << (index) if originals.include?(day)
        end
        days
      end
    end
  end
  
  class Calendar
    attr_writer :year
    attr_reader :habits

    def initialize(habits)
      @habits = habits.reduce({}) {|hash,habit| hash[habit.id] = habit; hash}
      @ids = habits.map(&:id)
    end

    def year
      @year || Quirk.today.year
    end

    def has_habit?(habit_id)
      raise "No habit found: #{habit_id}" if !@habits.has_key?(habit_id)
      true
    end

    def output(habit_id)
      return if !has_habit?(habit_id)
      habit = @habits[habit_id]
      months = (1..12).map do |month|
        first = Date.new(year, month, 1)
        out = "#{first.strftime('         %b        ')}\n"
        out += "Su Mo Tu We Th Fr Sa\n"
        out += ("   " * first.wday)
        while first.month == month
          out += (first..(first + (6 - first.wday))).map do |date|
            if date.year != year || date.month != month
              '  '
            else
              len = date.day.to_s.length
              "#{' ' * (2 - len)}#{date.day.to_s.colorize(habit.color_on(date))}"
            end
          end.join(" ")
          out += "\n"
          first += 7 - first.wday
        end
        out.split("\n")
      end
      out = "#{(' ' * 32)}#{year}\n"
      index = 0
      while index < 12
        line = 0
        max_line = [months[index], months[index+1], months[index+2]].
          map(&:length).max
        while line <= max_line
          out += "#{months[index][line] || (' ' * 20)}   "
          out += "#{months[index+1][line] || ( ' ' * 20)}   "
          out += "#{months[index+2][line]}\n"
          line += 1
        end
        index += 3
      end
      out
    end

    def mark!(line)
      date = Date.parse(line.strip.split(/\s+/)[0])
      originals = line.strip.split(/\s+/, 2)[1].split(',').map(&:strip)
      originals.each do |original|
        if original =~ /^\^\s*/
          original = original.sub(/^\^\s*/, '')
          habit = @habits[original] if has_habit?(original)
          habit.mark_first!(date)
        elsif original =~ /^\$\s*/
          original = original.sub(/^\$\s*/, '')
          habit = @habits[original] if has_habit?(original)
          habit.mark_last!(date)
        elsif has_habit?(original)
          @habits[original].mark!(date)
        end
      end
    end

    def streaks
      pairs = @ids.map do |id|
        [@habits[id].streak, id]
      end
      len = pairs.map {|p| p.first.to_s.length}.max
      pairs.map do |count, id|
        "#{' ' * (len - count.to_s.length)}#{count} #{id}"
      end.join("\n")
    end

    def self.parse(text)
      marks, habits = [], []
      text.strip.each_line do |line|
        line = line.split(';')[0].to_s.strip # remove comments
        if line =~ /^\d\d\d\d\/\d\d?\/\d\d?\s+/
          marks << line
        elsif line !~ /^\s*$/
          habits << Habit.parse(line)
        end
      end
      cal = Calendar.new(habits)
      marks.each { |mark| cal.mark!(mark) }
      cal
    end
  end
end
