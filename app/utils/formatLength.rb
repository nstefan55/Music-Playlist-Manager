private

def odrediOblikSati(sati)
  if (11..19).include?(sati % 100)
    "sati"
  else
    zadnja = sati % 10
    case zadnja
    when 1
      "sat"
    when 2, 3, 4
      "sata"
    else
      "sati"
    end
  end
end

def odrediOblikMinute(minute)
  if (11..19).include?(minute % 100)
    "minuta"
  else
    zadnja = minute % 10
    case zadnja
    when 1
      "minuta"
    when 2, 3, 4
      "minute"
    else
      "minuta"
    end
  end
end

def odrediOblikSekunde(sekunde)
  if (11..19).include?(sekunde % 100)
    "sekundi"
  else
    zadnja = sekunde % 10
    case zadnja
    when 1
      "sekunda"
    when 2, 3, 4
      "sekunde"
    else
      "sekundi"
    end
  end
end

def formatTrajanje(ukMinute)
  ukMinute = ukMinute.ceil if (ukMinute % 1) >= 0.6

  sati = (ukMinute / 60).floor
  minute = (ukMinute % 60).floor
  sekunde = ((ukMinute % 1) * 60).round

  if sati >= 1
    result = "#{sati} #{odrediOblikSati(sati)}, #{minute} #{odrediOblikMinute(minute)}"
    result += " i #{sekunde} #{odrediOblikSekunde(sekunde)}" unless sekunde == 0
    result
  elsif minute >= 1
    result = "#{minute} #{odrediOblikMinute(minute)}"
    result += " i #{sekunde} #{odrediOblikSekunde(sekunde)}" unless sekunde == 0
    result
  else
    "#{sekunde} #{odrediOblikSekunde(sekunde)}"
  end
end


def validDurationFormat(input)
  raise ArgumentError, "Trajanje ne može biti negativno!" if input < 0
  
  minute = input.to_i
  sekunde = ((input - minute) * 100).round

  if sekunde >= 60
    minute += 1
    sekunde -= 60
  end
end
