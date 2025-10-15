defmodule Dictionary do
  def get_words_from_file(path) do
    reader_helper(File.read(path))
  end

  defp reader_helper({:ok, contents}) do
    #IO.puts(contents)
    dictList = String.split(contents, "\r\n")

    List.to_tuple(dictList)
  end

  defp reader_helper({:error, _contents}) do
    raise "Error opening the file"
  end

  def binary_search(wordTuple, search) do
    binary_search_helper(wordTuple, search, 0, tuple_size(wordTuple) - 1)

  end

  defp binary_search_helper(wordTuple, search, min, max) when elem(wordTuple, round((max - min) / 2) + min) == search do
    true
  end

  defp binary_search_helper(_wordTuple, _search, min, max) when min > max do
    false
  end

  defp binary_search_helper(wordTuple, search, min, max) when elem(wordTuple, round((max - min) / 2) + min) < search do
    newmin = round((max - min) / 2) + min
    binary_search_helper(wordTuple, search, newmin + 1, max)
  end

  defp binary_search_helper(wordTuple, search, min, max) when elem(wordTuple, round((max - min) / 2) + min) > search do
    newmax = round((max - min) / 2) + min
    binary_search_helper(wordTuple, search, min, newmax - 1)
  end
end

defmodule WordSplitFinder do
  def split_and_find(word_tuple, word) do
    segments = ""

    retList = chopper_helper(word_tuple, word, 1, segments, [], String.length(word))
    retList
  end

  defp chopper_helper(_word_tuple, _word, num, _segments, retList, word_length) when num == (word_length + 1) do
    retList
  end

  defp chopper_helper(word_tuple, word, num, segments, retList, word_length) do
    new_segment = chop(word, num)
    #is_seg_a_word?(word_tuple, Dictionary.binary_search(word_tuple, new_segment[:left_segment]), new_segment[:left_segment], new_segment[:right_segment], segments, retList)
    chopper_helper(word_tuple, word, num + 1, segments, is_seg_a_word?(word_tuple, Dictionary.binary_search(word_tuple, new_segment[:left_segment]), new_segment[:left_segment], new_segment[:right_segment], segments, retList), word_length)
  end

  defp is_seg_a_word?(_word_tuple, true, str1, str2, segments, retList) when str2 == "" do
    segments = segments <> str1
    retList = [segments | retList]
    retList
  end

  defp is_seg_a_word?(_word_tuple, false, _str1, _str2, _segments, retList) do
    retList
  end

  defp is_seg_a_word?(word_tuple, true, str1, str2, segments, retList) do
    chopper_helper(word_tuple, str2, 1, segments <> str1 <> "-", retList, String.length(str2))

  end


  defp chop(word, pos) do
              %{:left_segment => String.slice(word, 0..(pos - 1)),
                :right_segment => String.slice(word, pos..-1//1)}
  end


  def go_through_dictionary(word_tuple) do
    word_list = Tuple.to_list(word_tuple)
    go_through_helper(word_tuple, word_list)
  end

  defp go_through_helper(word_tuple, [head | tail]) do
    combo_list = split_and_find(word_tuple, head)
    check_print_list(combo_list, length(combo_list))
    go_through_helper(word_tuple, tail)
  end

  defp go_through_helper(_word_tuple, []) do
    " "
  end

  defp check_print_list(a_list, num) when num >= 7 do
    IO.inspect(a_list)
  end

  defp check_print_list(_a_list, _num) do
    " "
  end

end

words = Dictionary.get_words_from_file("C:/Users/joedi/Desktop/C++ external files/bigDictionary.txt")

IO.inspect(WordSplitFinder.split_and_find(words, "carton"))
IO.inspect(WordSplitFinder.split_and_find(words, "catalog"))
IO.inspect(WordSplitFinder.split_and_find(words, "ihaveafriendwhosenameisjane"))

IO.puts("")

WordSplitFinder.go_through_dictionary(words)

#Comments on my thought process during this project

#Create a function called Chop that takes a string and a position of where to do the chopping
#Create a map with a left and right segment in said function
#Ex. Chop("Mark", 1) returns %{"M", "ark"}, Chop("Mark", 2) returns %{"Ma", "rk"}, Chop("Mark", 3) returns %{"Mar", "k"}, and Chop("Mark", 4) returns %{"Mark", ""}
#General case is word initially passed in has a length greater than 0
#Longest Function is the one where we push the completed word into a list (5 lines)
