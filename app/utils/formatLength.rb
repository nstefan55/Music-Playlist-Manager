private

def formatTrajanje(ukMinute)
    sati = ukMinute / 60
    minute = ukMinute % 60

    if sati >= 1
        "#{sati} sati i #{minute} minuta"
    else
        "#{minute} minuta"
    end
end
