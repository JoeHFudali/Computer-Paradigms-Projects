(defn leap-year [year]
  (cond (and (= (rem year 4) 0) (not= (rem year 100) 0)) "Leap"
        (and (= (rem year 4) 0) (= (rem year 400) 0)) "Leap"
        :else "Normal"))

(defn get-dates [date]
  (let [months-map {1 31 2 28 3 31 4 30 5 31 6 30 7 31 8 31 9 30 10 31 11 30 12 31}
        leap-year-months-map (assoc months-map 2 29)
        dates (clojure.string/split date #"/")
        corrected-dates (map #(Integer/parseInt %) dates)
        curr-year (if (= (leap-year (nth corrected-dates 2)) "Leap")  leap-year-months-map months-map)
        new-day (if (= (nth corrected-dates 1) (curr-year (nth corrected-dates 0))) 1
                      (inc (nth corrected-dates 1)))
        new-day-fixed (if (< new-day 10) (str "0" new-day) new-day)
        new-month (cond (and (= (nth corrected-dates 0) 12) (= (nth corrected-dates 1) (curr-year (nth corrected-dates 0)))) 1
                        (= (nth corrected-dates 1) (curr-year (nth corrected-dates 0))) (inc (nth corrected-dates 0))
                        :else (nth corrected-dates 0))
        new-month-fixed (if (< new-month 10) (str "0" new-month) new-month)
        new-year (if (and (= (nth corrected-dates 0) 12) (= (nth corrected-dates 1) (curr-year (nth corrected-dates 0)))) (inc (nth corrected-dates 2)) (nth corrected-dates 2))
        new-date (str new-month-fixed "/" new-day-fixed "/" new-year)]
    (lazy-seq
      (cons date (get-dates new-date)))))

(defn get-long-dates [date]
  (let [months-map {1 31 2 28 3 31 4 30 5 31 6 30 7 31 8 31 9 30 10 31 11 30 12 31}
        month-words {1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"}
        leap-year-months-map (assoc months-map 2 29)
        dates (clojure.string/split date #"/")
        corrected-dates (map #(Integer/parseInt %) dates)
        curr-year (if (= (leap-year (nth corrected-dates 2)) "Leap")  leap-year-months-map months-map)
        ordinal (cond (or (= (nth corrected-dates 1) 1) (= (nth corrected-dates 1) 21) (= (nth corrected-dates 1) 31)) "st"
                      (or (= (nth corrected-dates 1) 2) (= (nth corrected-dates 1) 22)) "nd"
                      (or (= (nth corrected-dates 1) 3) (= (nth corrected-dates 1) 23)) "rd"
                      :else "th")
        new-day (if (= (nth corrected-dates 1) (curr-year (nth corrected-dates 0))) 1 (inc (nth corrected-dates 1)))
        new-day-fixed (if (< new-day 10) (str "0" new-day) new-day)
        new-month (cond (and (= (nth corrected-dates 0) 12) (= (nth corrected-dates 1) (curr-year (nth corrected-dates 0))))1
                        (= (nth corrected-dates 1) (curr-year (nth corrected-dates 0))) (inc (nth corrected-dates 0))
                        :else (nth corrected-dates 0))
        new-month-fixed (if (< new-month 10) (str "0" new-month) new-month)
        new-year (if (and (= (nth corrected-dates 0) 12) (= (nth corrected-dates 1) (curr-year (nth corrected-dates 0)))) (inc (nth corrected-dates 2)) (nth corrected-dates 2))
        new-date (str new-month-fixed "/" new-day-fixed "/" new-year)
        current-new-date (str (month-words (nth corrected-dates 0)) " " (nth corrected-dates 1) ordinal ", " (nth corrected-dates 2))]
    (lazy-seq
      (cons current-new-date (get-long-dates new-date)))))


(println (nth (get-dates "11/20/2024") 0))
(println (nth (get-dates "11/20/2024") 1))
(println (nth (get-dates "11/20/2024") 2))
(println (nth (get-dates "11/20/2024") 11))

(println)
(println (take 5 (get-dates "11/20/2024")))

(println)

(println (nth (get-dates "01/01/2024") 78))

(println)

(println (nth (get-long-dates "01/01/2024") 78))
(println (nth (get-long-dates "01/01/1970") 20047))
(println (nth (get-long-dates "01/01/2024") 23))

(println)

;(println (take 8 (take-nth 1000 (get-long-dates "06/03/2004"))))
(doseq [ x (take 8 (take-nth 1000 (get-long-dates "06/03/2004"))) ] (println x))
(println (nth (take-nth 1000 (get-long-dates "06/03/2004")) 8))

(println)

(println "Mark Mahoney's base-10 birthdays (from 03/19/1973)")
(doseq [ x (take 19 (take-nth 1000 (get-long-dates "03/19/1973")))] (println x))
;(println (take 19 (take-nth 1000 (get-long-dates "03/19/1973"))))

(println "Mark's next Base-10 Birthday is on" (nth (take-nth 1000 (get-long-dates "03/19/1973")) 19))