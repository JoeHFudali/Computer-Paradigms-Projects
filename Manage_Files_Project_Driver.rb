#This is the Test class for Programming Assignment 3.

require_relative '09.rb'
require 'test/unit'
require 'fileutils'

class TestFileSystemCollector < Test::Unit::TestCase
  def setup
    puts " --Creating an new object for each test"
    FileUtils.mkdir_p("testDir/")
    FileUtils.mkdir_p("testDir/subDir")
    FileUtils.mkdir_p("testDir/subDir/subSubDir1")
    FileUtils.mkdir_p("testDir/subDir/subSubDir2")

    File.open("testDir/subDir/subSubDir2/rubytest.rb", "w") do |f|
      f.write("0. This is a test ruby file")
    end


    File.open("testDir/out.txt", "w") do |f|
      f.write("1. This is a text file")
    end

    File.open("testDir/subDir/out1.txt", "w") do |f|
      f.write("2. This is a text file inside of a directory")
    end

    File.open("testDir/subDir/subSubDir1/testc.cpp", "w") do |f|
      f.write("3. This is a C++ file in")
    end

    File.open("testDir/subDir/out2.txt", "w") do |f|
      f.write("4. This is another text file in this directory")
    end

    File.open("testDir/subDir/subSubDir2/testc1.cpp", "w") do |f|
      f.write("5. This is another C++ file")
    end

    File.open("testDir/subDir/subSubDir1/testc2.cpp", "w") do |f|
      f.write("3. This is a third C++ file in a directory")
    end

    @FSC = FileSystemCollector.new("testDir")

    


  end

  def teardown
    puts "Cleaning up after a test-- "
    FileUtils.remove_dir("testDir/", true)
  end

  def test_get_file_count()
    assert_equal(7, @FSC.get_file_count)
  end

  def test_get_dir_count()
    assert_equal(3, @FSC.get_dir_count)
  end

  def test_to_s()
    assert_equal("Path: testDir\nFile Count: 7\nDirectory Count: 3\n\n", @FSC.to_s)
  end

  def test_files()
    count = 0
    @FSC.files do |path, name, ext|
      count += 1
    end
    assert_equal(7, count)
  end

  def test_dirs()
    count = 0
    @FSC.dirs do |path, name|
      count += 1
    end
    assert_equal(3, count)
  end

  def test_collect()
    count = 0
    @FSC.collect("txt")
    @FSC.txts.all do |files|
      count += 1
    end

    assert_equal(3, count)

  end

  def test_collect_multiple()
    count = 0

    @FSC.collect("media", "txt", "cpp")
    @FSC.media.all do |files|
      count += 1
    end

    assert_equal(6, count)
    count = 0

    @FSC.collect("media2", "txt", "cpp", "rb")
    @FSC.media2.all do |files|
      count += 1
    end

    assert_equal(7, count)
    
  end

  

  #for zip, ask if the zip file name is there, and return correct if it is
  #two tests for collect (one for one argument, one for multiple)
  #tests for file groupings (all, remove, zip)

end

class TestFileGrouping < Test::Unit::TestCase

 def setup
   @FG = FileGrouping.new

   FileUtils.mkdir_p("testDir1/")
   FileUtils.mkdir_p("testDir1/subDir1")

   File.open("testDir1/test.txt", "w") do |f|
    f.write("Written Test text thing")
   end

   File.open("testDir1/test2.txt", "w") do |f|
    f.write("Written Test text thing number 2")
   end

   File.open("testDir1/code.cpp", "w") do |f|
    f.write("Code test thing")
   end

   File.open("testDir1/subDir1/code1.cpp", "w") do |f|
    f.write("Another code thing")
   end

   File.open("testDir1/subDir1/rubytest.rb", "w") do |f|
    f.write("Ruby code test thing")
   end

    @FG.add_file_path("testDir1/test.txt")
    @FG.add_file_path("testDir1/test2.txt")
    @FG.add_file_path("testDir1/code.cpp")
    @FG.add_file_path("testDir1/subDir1/code1.cpp")
    @FG.add_file_path("testDir1/subDir1/rubytest.rb")

  end

  def teardown()
    FileUtils.remove_dir("testDir1", true)
  end

  def test_all
    count = 0
    @FG.all do |elem|
      count += 1
    end

    assert_equal(5, count)
  end

  def test_zip
    #replace zip parameter with your own place to store the zip file
    @FG.zip("testDir1/")
    pathArr = []
    count = 0
    #This opens the ziped files and takes the content of their files into an array
    #Also replace this parameter with your own location of zip file
    Zip::File.open('testDir1/zipFile.zip') do |zipfile|
      zipfile.each do |entry|
        #entry.extract

        content = entry.get_input_stream.read
        pathArr << content
        count += 1
      end
    end

    #Array we are hardcoding to check against the zip function
    firstArr = []
    firstArr << "Written Test text thing"
    firstArr << "Written Test text thing number 2"
    firstArr << "Code test thing"
    firstArr << "Another code thing"
    firstArr << "Ruby code test thing"
    firstArr << "myFile just contains this"

    assert_equal(firstArr, pathArr)
    assert_equal(6, count)

    

  end
  
  def test_remove
    @FG.remove

    count = 0
    @FG.all do |file|
      count += 1
    end

    assert_equal(0, count)
  end

end