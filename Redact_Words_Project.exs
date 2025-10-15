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


#--------------------------------------------------------------------------

#Work on this later (Add in cleansing for punctuation, and start on inverse)

defmodule Redactor do
  def redact(redacted_words_file_path, file_path) do
    redact_words = Dictionary.get_words_from_file(redacted_words_file_path)

    sentences_list = reading_helper(File.read(file_path))

    |> Enum.map(fn (val) -> String.split(val, " ") end)

    |> Enum.map( fn (val) -> replace_words(val, redact_words, [], false) end)

    |> Enum.map( fn (val) -> reconstruct_list(val) end)

    |> Enum.join("\r\n")

    IO.puts(sentences_list)
  end



  defp reading_helper({:ok, contents}) do
    retList = String.split(contents, "\r\n")
    retList
  end

  defp reading_helper({:error, _contents}) do
    raise "Error opening a file"
  end



  defp replace_words([word | []], redact_list, ret_lists, reverse) do
    ret_lists = [check_word(word, redact_list, reverse) | ret_lists]
    ret_lists
  end

  defp replace_words([word | tail], redact_list, ret_lists, reverse) do
    ret_lists = [check_word(word, redact_list, reverse) | ret_lists]
    replace_words(tail, redact_list, ret_lists, reverse)

  end

  defp check_word(word, redact_list, reverse) do
    edited_word = String.downcase(word)
    edited_word = fix_word(edited_word)
    ret_word = replace_word?(word, Dictionary.binary_search(redact_list, edited_word), reverse)
    ret_word
  end

  defp replace_word?(word, true, false) do
    ret_string = String.duplicate("x", String.length(word))
    ret_string
  end

  defp replace_word?(word, false, false) do
    word
  end

  defp replace_word?(word, true, true) do
    word
  end

  defp replace_word?(word, false, true) do
    ret_string = String.duplicate("x", String.length(word))
    ret_string
  end

  defp reconstruct_list(string_list) do
    ret_list = Enum.reverse(string_list)
    ret_list = Enum.join(ret_list, " ")

    ret_list
  end

  defp fix_word(word) do
    letters = String.to_charlist(word)
    letters = Enum.map(letters, fn (val) -> if_is_letter(val) end)
    letters = List.to_string(letters)
    letters
  end



  defp if_is_letter(val) when (val >= 97 and val <= 122) or (val <= 57 and val >= 48) do
    val
  end

  defp if_is_letter(_val) do
    ""
  end



  def redact_inverse(redacted_words_file_path, file_path) do
    redact_words = Dictionary.get_words_from_file(redacted_words_file_path)

    sentences_list = reading_helper(File.read(file_path))

    word_lists = Enum.map(sentences_list, fn (val) -> String.split(val, " ") end)

    redacted_lists = Enum.map(word_lists, fn (val) -> replace_words(val, redact_words, [], true) end)

    recreated_lists = Enum.map(redacted_lists, fn (val) -> reconstruct_list(val) end)

    final_string = Enum.join(recreated_lists, "\r\n")

    IO.puts(final_string)
  end


end

Redactor.redact("C:/Users/joedi/Desktop/C++ external files/1000words.txt", "C:/Users/joedi/Desktop/C++ external files/sqrt110.txt")
IO.puts("")
Redactor.redact_inverse("C:/Users/joedi/Desktop/C++ external files/1000words.txt", "C:/Users/joedi/Desktop/C++ external files/sqrt110.txt")



#----------------------------------------------------------------------------




#Take in two file paths (one of the words we want to redact, and one that we are redacting)
#Split up the second file by line in a list, then go over a line, and split up the lines by spaces to get individual words
# check if letters are between a and z, and if not, delete them if it is not a redacted word
