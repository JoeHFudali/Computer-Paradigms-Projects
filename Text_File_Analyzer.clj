(import '(java.util.concurrent Executors))

(def word-frequencies (atom {}))
(def sentence-stats (atom {:total-number-of-words 0 :sentence-count 0}))

(defn cleanse-words [words]
  (let [lowercased (clojure.string/lower-case words)]
    (clojure.string/replace lowercased #"[^a-zA-Z0-9 ]" "")))

(defn reassemble [string]
  (let [sentence (clojure.string/split string #"\s")]
    (remove #(= % "") sentence)))

(defn update-sentence-count [orig-map]
  (let [c (get orig-map :sentence-count)
        newc (inc c)]
    (assoc orig-map :sentence-count newc)))

(defn update-word-count [orig-map]
  (let [c (get orig-map :total-number-of-words)
        newc (inc c)]
    (assoc orig-map :total-number-of-words newc)))

(defn update-frequency [orig-map word]
  (let [c (get orig-map word)
        newc (inc c)]
    (assoc orig-map word newc)))

(defn update-frequency-new [orig-map word]
    (conj orig-map {word 1}))

(defn get-analyze-sentence-task-fn [sentence]
  (fn []
    (swap! sentence-stats update-sentence-count)
    (let [words (clojure.string/split sentence #"\s")
               cleansed-words (cleanse-words words)
               finalized (reassemble cleansed-words)]

           (doseq [word finalized] (swap! sentence-stats update-word-count)
                                   (if (contains? @word-frequencies word)
                                     (swap! word-frequencies update-frequency word)
                                     (swap! word-frequencies update-frequency-new word))))))

(defn print-results [words]
  (println "=== Results ===")
  (doseq [word words] (if (contains? @word-frequencies word)
                        (println word ":" (get @word-frequencies word))
                        (println word ":" 0)))
  (println)
  (println "Average Sentence Length: " (/ (double (get @sentence-stats :total-number-of-words)) (get @sentence-stats :sentence-count)))
  (println "Total Sentences: " (get @sentence-stats :sentence-count))
  (println "Total Words Processed: " (get @sentence-stats :total-number-of-words))
  )

(defn analyze-file [file-path num-threads search-words]
  (let [sentences (clojure.string/split-lines (slurp file-path))
        pool (Executors/newFixedThreadPool num-threads)
        tasks (map get-analyze-sentence-task-fn sentences)]
    (.invokeAll pool tasks)
    (print-results search-words)
    (.shutdown pool)))


(analyze-file "connYankeeSentences.txt" 4 '("the" "and" "a" "sir" "mark" "sdfsdf"))