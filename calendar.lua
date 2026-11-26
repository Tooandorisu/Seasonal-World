local Calendar = {}

function Calendar.season(mode, date)
  if mode == "late_winter" or mode == "thaw" then return "late_winter" end
  if mode == "off" then return "none" end
  if mode == "christmas" or mode == "new_year" then return "christmas" end
  if mode == "spring" then return "spring" end
  if mode == "summer" then return "summer" end
  if mode == "autumn" then return "autumn" end
  if type(date) ~= "table" then return "none" end
  local month = date.month
  if month == 3 or month == 4 or month == 5 then return "spring" end
  if month == 6 or month == 7 or month == 8 then return "summer" end
  if month == 9 or month == 10 or month == 11 then return "autumn" end
  if month == 12 or (month == 1 and type(date.day) == "number" and date.day >= 1 and date.day <= 6) then
    return "christmas"
  end
  if month == 2 or (month == 1 and type(date.day) == "number" and date.day >= 7 and date.day <= 31) then
    return "late_winter"
  end
  return "none"
end

function Calendar.snowStage(mode,date)
  if mode == "thaw" then return 2 end
  if mode == "late_winter" or not date or date.month ~= 2 then return 0 end
  return (date.day or 1) >= 20 and 2 or 1
end

return Calendar
