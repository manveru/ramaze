#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)
require "ramaze/tool/bin"

require "pathname"

module Ramaze
  BINPATH = Pathname(Ramaze::ROOT).join("../bin/ramaze").expand_path
end

USAGE = <<TXT

  Usage:
	ramaze <start [PIDFILE]|stop [PIDFILE]|restart [PIDFILE]|status [PIDFILE]|create PROJECT|console> [ruby/rack options]

	Commands:

	  * All commands which take an optional PIDFILE (defaults to PROJECT.pid otherwise).
	  * All commands which start a ramaze instance will default to webrick on port 7000
	    unless you supply the rack options -p/--port PORT and/or * -s/--server SERVER.

	 start   - Starts an instance of this application.

	 stop    - Stops a running instance of this application.

	 restart - Stops running instance of this application, then starts it back up.  Pidfile
	           (if supplied) is used for both stop and start.

	 status  - Gives status of a running ramaze instance

	 create  - Creates a new prototype Ramaze application in a directory named PROJECT in
	           the current directory.  ramaze create foo would make ./foo containing an
	           application prototype. Rack options are ignored here.

	 console - Starts an irb console with app.rb (and irb completion) loaded. This command
	           ignores rack options, ARGV is passed on to IRB.


	Ruby options:
	  -e, --eval LINE          evaluate a LINE of code
	  -d, --debug              set debugging flags (set $DEBUG to true)
	  -w, --warn               turn warnings on for your script
	  -I, --include PATH       specify $LOAD_PATH (may be used more than once)
	  -r, --require LIBRARY    require the library, before executing your script

	Rack options:
	  -s, --server SERVER      serve using SERVER (webrick/mongrel)
	  -o, --host HOST          listen on HOST (default: 0.0.0.0)
	  -p, --port PORT          use PORT (default: 9292)
	  -E, --env ENVIRONMENT    use ENVIRONMENT for defaults (default: development)
	  -D, --daemonize          run daemonized in the background
	  -P, --pid FILE           file to store PID (default: rack.pid)

	Common options:
	  -h, --help               Show this message
	      --version            Show version
TXT

describe "bin/ramaze command" do
  it "Can find the ramaze binary" do
    Ramaze::BINPATH.file?.should == true
  end

  it "Shows command line help" do
    output = `#{Ramaze::BINPATH} -h`
    output.should == USAGE
  end

  it "Shows the correct version" do
    output = %x{#{Ramaze::BINPATH} --version}
    output.strip.should == Ramaze::VERSION
  end

  it "Can create a new tree from prototype" do
    require "fileutils"
    root = Pathname.new("/tmp/test_tree")
    raise "#{root} already exists, please move it out of the way before running this test" if root.directory?
    begin
      output = %x{#{Ramaze::BINPATH} create #{root}}
      root.directory?.should.be.true
      root.join("config.ru").file?.should.be.true
      root.join("start.rb").file?.should.be.true
      root.join("controller").directory?.should.be.true
      root.join("controller", "init.rb").file?.should.be.true
      root.join("view").directory?.should.be.true
      root.join("model").directory?.should.be.true
      root.join("model", "init.rb").file?.should.be.true
    ensure
      FileUtils.rm_rf(root)
    end
  end

end

