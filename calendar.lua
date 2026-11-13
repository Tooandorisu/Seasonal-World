local Calendar = {}

function Calendar.season(mode, date)
  if mode == "off" then return "none" end
  if mode == "christmas" then return "christmas" end
  if type(date) ~= "table" then return "none" end
  if date.month == 12 or (date.month == 1 and type(date.day) == "number" and date.day >= 1 and date.day <= 6) then
    return "christmas"
  end
  return "none"
end

return Calendar
