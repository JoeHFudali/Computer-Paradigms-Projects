def difference_between_dates(d1, d2)
  numDays = 0
  monthNum = {
  1 => 31,
  2 => 28,
  3 => 31,
  4 => 30,
  5 => 31,
  6 => 30,
  7 => 31,
  8 => 31,
  9 => 30,
  10 => 31,
  11 => 30,
  12 => 31
}

  dateArr = d1.split("/")
  dateArr2 = d2.split("/")
  continuing = true;

  monthStart = dateArr[0].to_i
  dayStart = dateArr[1].to_i
  yearStart = dateArr[2].to_i

  monthEnd = dateArr2[0].to_i
  dayEnd = dateArr2[1].to_i
  yearEnd = dateArr2[2].to_i

  while (continuing)
    while monthStart <= 12 && continuing
      dayStop = monthNum[monthStart]
      if (isLeapYear(yearStart) && monthStart == 2)
        dayStop += 1
      end
      while dayStart <= dayStop && continuing
        numDays += 1
        
        if(monthStart == monthEnd)
          if(dayStart == dayEnd) 
            if(yearStart == yearEnd) 
              continuing = false;
            end
          end
        end

        dayStart += 1 
      end
      dayStart = 1
      monthStart += 1
    end
    monthStart = 1
    yearStart += 1
  end
  
  numDays 
end

def add_days(d1, i1)
  dateArr = d1.split("/")
  count = i1
  continuing = true;
  monthNum = {
  1 => 31,
  2 => 28,
  3 => 31,
  4 => 30,
  5 => 31,
  6 => 30,
  7 => 31,
  8 => 31,
  9 => 30,
  10 => 31,
  11 => 30,
  12 => 31
}

  monthStart = dateArr[0].to_i
  dayStart = dateArr[1].to_i
  yearStart = dateArr[2].to_i

  while (continuing)
    while monthStart <= 12 && continuing
      dayStop = monthNum[monthStart]
      if (isLeapYear(yearStart) && monthStart == 2)
        dayStop += 1
      end
      while dayStart <= dayStop && continuing
        count -= 1
        dayStart += 1
        if(count == 0)
          continuing = false;
        end
        
      end
      if continuing
        dayStart = 1
        monthStart += 1
      elsif (dayStart - 1) == dayStop
        dayStart = 1
        monthStart += 1
      end
      
    end
    if continuing
      monthStart = 1
      yearStart += 1
    end
  end

  monthStart.to_s + "/" + dayStart.to_s + "/" + yearStart.to_s
end

def print_dates_in_between(d1, d2, i1)
  num = difference_between_dates(d1, d2)

  num -= 1
  if i1 == 1
    interval = num / i1
  else
    interval = num / (i1 - 1)
  end
  display_date = d1
  count = 1

  puts "The dates of the " + i1.to_s + " meetings between " + d1 + " and " + d2 + " are: "

  i1.times do
    puts count.to_s + ") " + display_date
    display_date = add_days(display_date, interval)
    count += 1
  end
  puts
end

def isLeapYear(x)
  leapTrue = false;
  if x % 4 == 0
    if x % 100 != 0
      leapTrue = true;
    elsif x % 400 == 0 
      leapTrue = true;
    end
  end
  leapTrue
end

#num_of_days = difference_between_dates("4/6/2024", "9/1/2024")
#new_date = add_days("2/12/2024", 1000)

#You can input a start and end date, as well as the number of meetings you want between
#them to get the resulting dates of all the meetings

print_dates_in_between("2/8/2024", "2/9/2024", 2)