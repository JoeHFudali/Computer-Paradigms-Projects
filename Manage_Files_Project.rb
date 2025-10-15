require 'zip'
require 'rubygems'
require 'fileutils'

class FileSystemCollector 

  attr_accessor(:pathToDir, :file_num, :dir_num)

  def initialize(file_path)
    if Dir.exist?(file_path)
      self.pathToDir = file_path
    else
      raise "Error: File path not found."
    end

    get_file_count()
    get_dir_count()

  end

  def recurssive_dir_search(dirPath, boolFile, boolDir, boolPrint)
    if(not Dir.empty?(dirPath))
      Dir.each_child(dirPath) do |fs_element|
        child_path = File.join(dirPath, fs_element)

        if File.file?(child_path)
          #is a file
          if boolFile
            if boolPrint
              puts "- " + fs_element.to_s
            else
              self.file_num += 1
            end
          end
        elsif File.directory?(child_path)
          #is a directory
          recurssive_dir_search(child_path, boolFile, boolDir, boolPrint)
          if boolDir
            if boolPrint
              puts "+ " + fs_element.to_s
            else
              self.dir_num += 1
            end
          end
        else
          #bad path
          break
        end
      end
    end
    
  end

  def get_file_count
    self.file_num = 0
    recurssive_dir_search(pathToDir, true, false, false)
    self.file_num
  end

  def get_dir_count
    self.dir_num = 0
    recurssive_dir_search(pathToDir, false, true, false)
    self.dir_num
  end

  def print_dirs
    puts "Printing the directories:"
    recurssive_dir_search(pathToDir, false, true, true)
    puts
  end

  def print_files
    puts "Printing the files:"
    recurssive_dir_search(pathToDir, true, false, true)
    puts
  end

  def directory_recurse_p3(dirPath, isFiles, block)
    Dir.each_child(dirPath) do |f|
      child_path = File.join(dirPath, f)
      if(isFiles)
        if(File.file?(child_path))
          extention = File.extname(f)
          name = File.basename(f, extention)
          extention = extention[1..-1]
          block.call(child_path, name, extention)
        elsif(File.directory?(child_path))
          directory_recurse_p3(child_path, isFiles, block)
        else
          break
        end
      else
        if File.directory?(child_path)
          block.call(child_path, f)
          directory_recurse_p3(child_path, isFiles, block)
        end
      end
      
    end
  end

  def get_files_of_a_type(*parts)
    #Get empty Filegrouping, and goes to files method, and collects all the file paths with the right extention
    #use instance_eval() in here and extention to 
    fg = FileGrouping.new
    files do |path, name, ext|
      if parts.include?(ext)
        fg.add_file_path(path)
      end
    end

    return fg

  end

  def get_files_with_an_extention(type_name) 
    fg = FileGrouping.new
    files do |path, name, ext|
      if(ext == type_name)
        fg.add_file_path(path)
      end
    end

    return fg

  end

  def collect(*parts)
    if parts.size == 1
      type = parts[0].to_s + "s"
      instance_eval("def #{type}\n get_files_with_an_extention(\"#{parts[0]}\")\n end")
      
    else
      group_name = parts[0]
      parts = parts[1..-1]
      parts = parts.map {|string| string = "\"" + string + "\""}
      parts = parts.join(",")
      instance_eval("def #{group_name}\n get_files_of_a_type(#{parts}) \n end")
    end
  end

  def files(&block)
    directory_recurse_p3(self.pathToDir, true, block) do |path, name, ext|
      yield path, name, ext
    end
  end

  def dirs(&block)
    directory_recurse_p3(self.pathToDir, false, block) do |path, name|
      yield path, name
    end
  end

  def to_s
    "Path: #{pathToDir}\nFile Count: #{file_num}\nDirectory Count: #{dir_num}\n\n"
  end

end

class FileGrouping
  def initialize
    @file_paths = []
  end

  def add_file_path(file_path)
    @file_paths << file_path
  end

  def all
    for x in @file_paths
      yield x
    end
  end

  def remove
    #goes through every file path, and deletes them
    for x in @file_paths
      FileUtils.remove_file(x)
    end
    @file_paths.clear
  end

  def zip(zip_path)
    #zips to a file, located in the zip path
    name = "zipFile.zip"
    zip_name = zip_path + "/" + name


    Zip::File.open(zip_name, create: true) do |zipfile|
      @file_paths.each do |filename|
        name = File.basename(filename)
        zipfile.add(name, filename)
      end
      zipfile.get_output_stream("myFile") {|f| f.write "myFile just contains this"}
    end

  end

end

#Test code here
#def main
  #creating a pointer to a new class object
  #mc = MyClass.new

  #This technique below lets us pass in the block code to a_method.

  #mc.a_method do |x, y|
    #puts "Hello World!" + x + y
  #end

  #def MyClass
    #def a_method(&block)
      #do_something(block)
    #end

    #def do_something(block)
      #block.call(p1, p2)
    #end
  #end

#end

#For the collect function, if the paramter amount is one, make the file extention plural, and set it as the new group
#if parameter length is greater than one, the first parameter is the name of the group, and the rest of the extentions are put into said group