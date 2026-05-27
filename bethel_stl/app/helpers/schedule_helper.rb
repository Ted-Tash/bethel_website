module ScheduleHelper
  # Memorial Day = last Monday of May
  def memorial_day(year = Date.today.year)
    d = Date.new(year, 5, 31)
    d -= 1 until d.monday?
    d
  end

  # Labor Day = first Monday of September
  def labor_day(year = Date.today.year)
    d = Date.new(year, 9, 1)
    d += 1 until d.monday?
    d
  end

  # Summer schedule: Memorial Day (inclusive) through the day before Labor Day
  def summer_schedule?(date = Date.today)
    date >= memorial_day(date.year) && date < labor_day(date.year)
  end

  # 4th Saturday of September (anchor for Pinecrest weekend)
  def pinecrest_saturday(year = Date.today.year)
    d = Date.new(year, 9, 1)
    d += 1 until d.saturday?
    d + 21 # 1st Saturday + 3 weeks = 4th Saturday
  end

  # Returns a banner message string or nil based on the date.
  # Checks Memorial Day weekend, Pinecrest weekend, and Christmas/New Year's.
  def banner_message(date = Date.today)
    memorial_day_banner(date) || pinecrest_banner(date) || holiday_banner(date)
  end

  private

  # Memorial Day weekend: Sunday before Memorial Day through Memorial Day (Mon)
  def memorial_day_banner(date)
    md = memorial_day(date.year)
    md_sunday = md - 1 # Sunday before Memorial Day Monday
    return unless date >= md_sunday && date <= md

    "We are celebrating Memorial Day and our spring retreat at Dayspring Bible Camp. " \
      "There will be no meeting at 210 Chestnut Avenue."
  end

  # Pinecrest weekend: Sunday before the 4th Saturday of September
  # through the Sunday after (Pinecrest Sunday).
  # Pinecrest runs Fri–Sun around the 4th Saturday.
  def pinecrest_banner(date)
    ps = pinecrest_saturday(date.year)
    pinecrest_sunday = ps + 1
    pinecrest_friday = ps - 1
    sunday_before = pinecrest_friday - pinecrest_friday.wday # previous Sunday
    return unless date >= sunday_before && date <= pinecrest_sunday

    "We are having our annual fall retreat at Pinecrest. " \
      "There will be no meeting at 210 Chestnut Avenue."
  end

  # Christmas / New Year's: Dec 23 – Jan 2
  def holiday_banner(date)
    return unless (date.month == 12 && date.day >= 23) || (date.month == 1 && date.day <= 2)

    "Heads up — meeting times may be affected due to the holidays. " \
      "Reach out if you have any questions."
  end
end
