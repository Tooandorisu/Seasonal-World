return {
  { key = "mode", label = "SEASON", type = "choice", default = "auto",
    choices = {{"AUTO (DATE)", "auto"}, {"CHRISTMAS TEST", "christmas"}, {"SPRING TEST", "spring"}, {"SUMMER TEST", "summer"}, {"OFF", "off"}, {"AUTUMN TEST", "autumn"}, {"LATE WINTER TEST", "late_winter"}, {"THAW TEST", "thaw"}, {"NEW YEAR TEST", "new_year"}} },
  { key = "snow", label = "SNOWFALL", type = "toggle", default = true },
  { key = "cover", label = "SNOW COVER", type = "toggle", default = true },
  { key = "petals", label = "FALLING PETALS", type = "toggle", default = true },
  { key = "summer_motion", label = "SUMMER MOTION", type = "toggle", default = true },
  { key = "autumn_motion", label = "AUTUMN MOTION", type = "toggle", default = true },
}
