#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

module Model
  class YAMLDatabase
    def initialize file = 'db.yaml'
      @file = file
      load
    end

    def load file = @file
      @db = YAML.load_file(file)
      p [:loaded, @db]
    end

    def save file = @file
      File.open(file, 'w+') do |f|
        f.print(YAML.dump(@db))
      end
      p [:saved, @db]
    end

    def method_missing(meth, *params, &block)
      p [:method_missing, meth, params]
      @db.send(meth, *params, &block)
    end
  end
end

