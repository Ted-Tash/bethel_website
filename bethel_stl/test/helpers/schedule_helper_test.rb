require "minitest/autorun"
require "date"
require_relative "../../app/helpers/schedule_helper"

class ScheduleHelperTest < Minitest::Test
  include ScheduleHelper

  # ===================== Memorial Day =====================

  def test_memorial_day_returns_last_monday_of_may
    # 2026: May 25 (Mon)
    assert_equal Date.new(2026, 5, 25), memorial_day(2026)
    assert memorial_day(2026).monday?

    # 2025: May 26 (Mon)
    assert_equal Date.new(2025, 5, 26), memorial_day(2025)
    assert memorial_day(2025).monday?

    # 2024: May 27 (Mon)
    assert_equal Date.new(2024, 5, 27), memorial_day(2024)
    assert memorial_day(2024).monday?

    # 2023: May 29 (Mon)
    assert_equal Date.new(2023, 5, 29), memorial_day(2023)
    assert memorial_day(2023).monday?
  end

  def test_memorial_day_when_may_31_is_a_monday
    # 2021: May 31 is Monday
    assert_equal Date.new(2021, 5, 31), memorial_day(2021)
  end

  # ===================== Labor Day =====================

  def test_labor_day_returns_first_monday_of_september
    # 2026: Sep 7 (Mon)
    assert_equal Date.new(2026, 9, 7), labor_day(2026)
    assert labor_day(2026).monday?

    # 2025: Sep 1 (Mon)
    assert_equal Date.new(2025, 9, 1), labor_day(2025)
    assert labor_day(2025).monday?

    # 2024: Sep 2 (Mon)
    assert_equal Date.new(2024, 9, 2), labor_day(2024)
    assert labor_day(2024).monday?
  end

  def test_labor_day_when_sep_1_is_a_monday
    # 2025: Sep 1 is Monday
    assert_equal Date.new(2025, 9, 1), labor_day(2025)
  end

  # ===================== Summer Schedule =====================

  def test_summer_schedule_true_on_memorial_day
    assert summer_schedule?(Date.new(2026, 5, 25))
  end

  def test_summer_schedule_true_day_after_memorial_day
    assert summer_schedule?(Date.new(2026, 5, 26))
  end

  def test_summer_schedule_true_mid_summer
    assert summer_schedule?(Date.new(2026, 7, 15))
  end

  def test_summer_schedule_true_day_before_labor_day
    # 2026 Labor Day = Sep 7; day before = Sep 6 (Sun)
    assert summer_schedule?(Date.new(2026, 9, 6))
  end

  def test_summer_schedule_false_on_labor_day
    refute summer_schedule?(Date.new(2026, 9, 7))
  end

  def test_summer_schedule_false_day_before_memorial_day
    refute summer_schedule?(Date.new(2026, 5, 24))
  end

  def test_summer_schedule_false_in_winter
    refute summer_schedule?(Date.new(2026, 1, 15))
  end

  def test_summer_schedule_false_in_october
    refute summer_schedule?(Date.new(2026, 10, 1))
  end

  # ===================== Pinecrest Saturday =====================

  def test_pinecrest_saturday_returns_4th_saturday_of_september
    # 2026: Sep 1 is Tuesday -> 1st Sat = Sep 5 -> 4th Sat = Sep 26
    assert_equal Date.new(2026, 9, 26), pinecrest_saturday(2026)
    assert pinecrest_saturday(2026).saturday?

    # 2025: Sep 1 is Monday -> 1st Sat = Sep 6 -> 4th Sat = Sep 27
    assert_equal Date.new(2025, 9, 27), pinecrest_saturday(2025)
    assert pinecrest_saturday(2025).saturday?

    # 2024: Sep 1 is Sunday -> 1st Sat = Sep 7 -> 4th Sat = Sep 28
    assert_equal Date.new(2024, 9, 28), pinecrest_saturday(2024)
    assert pinecrest_saturday(2024).saturday?
  end

  def test_pinecrest_saturday_when_sep_1_is_saturday
    # 2029: Sep 1 is Saturday -> 4th Sat = Sep 22
    assert_equal Date.new(2029, 9, 22), pinecrest_saturday(2029)
    assert pinecrest_saturday(2029).saturday?
  end

  # ===================== Banner: Memorial Day =====================

  def test_banner_memorial_day_sunday_before
    # 2026 Memorial Day = May 25 (Mon); Sunday before = May 24
    msg = banner_message(Date.new(2026, 5, 24))
    assert_includes msg, "Dayspring Bible Camp"
    assert_includes msg, "no meeting"
  end

  def test_banner_memorial_day_on_memorial_day
    msg = banner_message(Date.new(2026, 5, 25))
    assert_includes msg, "Dayspring Bible Camp"
  end

  def test_banner_nil_saturday_before_memorial_day_weekend
    assert_nil banner_message(Date.new(2026, 5, 23))
  end

  def test_banner_nil_day_after_memorial_day
    assert_nil banner_message(Date.new(2026, 5, 26))
  end

  # ===================== Banner: Pinecrest =====================

  def test_banner_pinecrest_sunday_before_retreat
    # 2026: 4th Sat = Sep 26, Fri = Sep 25, Sunday before Fri = Sep 20
    msg = banner_message(Date.new(2026, 9, 20))
    assert_includes msg, "Pinecrest"
    assert_includes msg, "no meeting"
  end

  def test_banner_pinecrest_on_friday
    msg = banner_message(Date.new(2026, 9, 25))
    assert_includes msg, "Pinecrest"
  end

  def test_banner_pinecrest_on_saturday
    msg = banner_message(Date.new(2026, 9, 26))
    assert_includes msg, "Pinecrest"
  end

  def test_banner_pinecrest_on_sunday
    msg = banner_message(Date.new(2026, 9, 27))
    assert_includes msg, "Pinecrest"
  end

  def test_banner_nil_saturday_before_pinecrest_range
    # Sunday before = Sep 20, so Saturday Sep 19 is outside
    assert_nil banner_message(Date.new(2026, 9, 19))
  end

  def test_banner_nil_monday_after_pinecrest_sunday
    assert_nil banner_message(Date.new(2026, 9, 28))
  end

  def test_pinecrest_banner_when_sep_1_is_saturday
    # 2029: Sep 1 is Sat -> 4th Sat = Sep 22, Fri = Sep 21,
    # Sunday before Fri (wday=5): Sep 21 - 5 = Sep 16
    # Pinecrest Sunday = Sep 23
    msg = banner_message(Date.new(2029, 9, 16))
    assert_includes msg, "Pinecrest"

    msg = banner_message(Date.new(2029, 9, 23))
    assert_includes msg, "Pinecrest"

    assert_nil banner_message(Date.new(2029, 9, 15))
    assert_nil banner_message(Date.new(2029, 9, 24))
  end

  # ===================== Banner: Christmas / New Year's =====================

  def test_banner_holiday_dec_23
    msg = banner_message(Date.new(2026, 12, 23))
    assert_includes msg, "holidays"
  end

  def test_banner_holiday_dec_31
    msg = banner_message(Date.new(2026, 12, 31))
    assert_includes msg, "holidays"
  end

  def test_banner_holiday_jan_1
    msg = banner_message(Date.new(2027, 1, 1))
    assert_includes msg, "holidays"
  end

  def test_banner_holiday_jan_2
    msg = banner_message(Date.new(2027, 1, 2))
    assert_includes msg, "holidays"
  end

  def test_banner_nil_dec_22
    assert_nil banner_message(Date.new(2026, 12, 22))
  end

  def test_banner_nil_jan_3
    assert_nil banner_message(Date.new(2027, 1, 3))
  end

  # ===================== Banner: No banner =====================

  def test_banner_nil_on_normal_day
    assert_nil banner_message(Date.new(2026, 3, 15))
  end

  def test_banner_nil_in_mid_summer
    assert_nil banner_message(Date.new(2026, 7, 4))
  end

  # ===================== Cross-year edge cases =====================

  def test_memorial_day_and_labor_day_correct_across_years
    (2020..2035).each do |year|
      md = memorial_day(year)
      ld = labor_day(year)

      assert md.monday?, "Memorial Day #{md} should be Monday"
      assert_equal 5, md.month, "Memorial Day #{md} should be in May"
      # Must be the LAST Monday -- no later Monday in May
      assert_equal 6, (md + 7).month, "#{md + 7} should be in June (no later Monday in May)"

      assert ld.monday?, "Labor Day #{ld} should be Monday"
      assert_equal 9, ld.month, "Labor Day #{ld} should be in September"
      # Must be the FIRST Monday -- no earlier Monday in September
      assert ld.day <= 7, "Labor Day #{ld} should be in first 7 days of September"
    end
  end

  def test_pinecrest_saturday_correct_across_years
    (2020..2035).each do |year|
      ps = pinecrest_saturday(year)
      assert ps.saturday?, "Pinecrest #{ps} should be Saturday"
      assert_equal 9, ps.month, "Pinecrest #{ps} should be in September"
      # Should be the 4th Saturday: day 22-28
      assert_includes 22..28, ps.day,
        "4th Saturday #{ps} should be between 22nd and 28th"
    end
  end
end
