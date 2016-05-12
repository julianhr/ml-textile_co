json.array!(@timesheets) do |timesheet|
  json.extract! timesheet, :id, :employee_id, :period_start_date, :period_end_date, :logged_hrs, :logged_min, :pay_date, :approved
  json.url timesheet_url(timesheet, format: :json)
end