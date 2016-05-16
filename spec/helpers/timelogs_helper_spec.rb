require 'rails_helper'

RSpec.describe TimelogsHelper, type: :helper do

  fixtures :employees
  fixtures :timelogs

  let(:valid_timelog) { timelogs(:john) }

  describe '#timelog_moment_in_time' do
    it "returns formatted string if recorded moment has value and claimed = nil" do
      time = 17.hours
      timelog = valid_timelog
      timelog.arrive_sec = time
      timelog.claim_arrive_sec = nil
      res = timelog_moment_in_time(:arrive, timelog)
      expect(res.index '5:00 PM').to be >= 0
    end

    it "returns formatted string if claimed moment has value and recorded = nil" do
      time = 17.hours
      timelog = valid_timelog
      timelog.arrive_sec = nil
      timelog.claim_arrive_sec = time
      res = timelog_moment_in_time(:arrive, timelog)
      expect(res.index '5:00 PM').to be >= 0
    end

    it "returns formatted string of claimed if claimed and recorded moments have value" do
      time = 17.hours
      timelog = valid_timelog
      timelog.arrive_sec = time + 2.hours
      timelog.claim_arrive_sec = time
      res = timelog_moment_in_time(:arrive, timelog)
      expect(res.index '5:00 PM').to be >= 0
    end

    it "returns string if recorded and claimed moments are nil" do
      if_nil = 'Not Good'
      timelog = valid_timelog
      timelog.arrive_sec = nil
      timelog.claim_arrive_sec = nil
      res = edit_form_moment_as_time(timelog.arrive_sec, if_nil)
      expect(res).to be_a(String)
    end
  end

  describe '#edit_form_moment_as_time' do
    it "returns formatted string if moment has value" do
      timelog = valid_timelog
      timelog.arrive_sec = 17.hours
      res = edit_form_moment_as_time(timelog.arrive_sec, nil)
      expect(res.index '5:00 PM').to be >= 0
    end

    it "returns the if_nil value if moment = nil" do
      if_nil = 'Not Good'
      timelog = valid_timelog
      timelog.arrive_sec = nil
      res = edit_form_moment_as_time(timelog.arrive_sec, if_nil)
      expect(res).to eq if_nil
    end
  end

  describe '#print_late_by' do
    let(:today) { Date.new 2016,5 }
    let(:scheduled_arrive_time) { 9.hours }

    it "returns time difference if arrive_sec > scheduled" do
      late_by = 35.minutes
      timelog = Timelog.new(
        employee: employees(:john),
        log_date: today,
        arrive_sec: scheduled_arrive_time + late_by
      )
      expect(print_late_by(scheduled_arrive_time, timelog)).to eq "#{late_by / 60} minutes"
    end

    it "returns time difference if claim_arrive_sec > scheduled and claim_status = pending" do
      late_by = 35.minutes
      timelog = Timelog.new(
        employee: employees(:john),
        log_date: today,
        claim_arrive_sec: (scheduled_arrive_time + late_by),
        claim_status: 'pending'
      )
      expect(print_late_by(scheduled_arrive_time, timelog)).to eq "#{late_by / 60} minutes"
    end

    it "returns time difference if arrive_sec > scheduled and claim_status = declined" do
      late_by = 35.minutes
      timelog = Timelog.new(
        employee: employees(:john),
        log_date: today,
        arrive_sec: (scheduled_arrive_time + late_by),
        claim_arrive_sec: (scheduled_arrive_time + late_by + 2.hours),
        claim_status: 'declined'
      )
      expect(print_late_by(scheduled_arrive_time, timelog)).to eq "#{late_by / 60} minutes"
    end

    it "returns 'N/A' if arrive_sec.nil? and claim_arrive_datetime.nil?" do
      late_by = 35.minutes
      timelog = Timelog.new(
        employee: employees(:john),
        log_date: today,
      )
      expect(print_late_by(scheduled_arrive_time, timelog)).to eq "N/A"
    end
  end

end
