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

def formatTrajanje(ukMinute)
  ukMinute = ukMinute.ceil if (ukMinute % 1) >= 0.6

  sati = (ukMinute / 60).floor
  minute = (ukMinute % 60).round

  if sati >= 1
    "#{sati} #{odrediOblikSati(sati)} i #{minute} #{odrediOblikMinute(minute)}"
  else
    "#{minute} #{odrediOblikMinute(minute)}"
  end
end




def validDurationFormat(input)
  raise ArgumentError, "Trajanje ne može biti negativno!" if input < 0
  
  minute = input.to_i
  sekunde= ((input - minute) * 100).round

  if sekunde >= 60
    minute += 1
  end

  minute % 1 == 0 ? minute : minute.to_f
end

