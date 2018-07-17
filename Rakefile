#
#  Rakefile - Gather useful commands here
#

task :default => :help

desc "Build something"
task :build, [:first] do |t, args|
  #args.with_defaults(:first => 'Uno')
  #puts "args.to_a:\t" + args.to_a.join(', ')
  #puts "first:\t#{args.first}"
  #puts "args.extras:\t" + args.extras.join(', ')
  sh "xcodebuild build"
end

desc "Clean something"
task :clean do
  sh "xcodebuild clean"
end

desc "Clean everything"
task :cleanall => :clean do
  sh "rm -fr .ipynb_checkpoints DerivedData"
end

desc "Generate documentation"
task :docs do
  xcute "rm -fr docs"
  xcute "jazzy --module AImaKit" 
  xcute "rm -fr docs/{docsets,undocumented.json}"
end

desc "Display list of tasks"
task :help do
  puts %x(rake -f #{__FILE__} -T)
end

desc "Run a test"
task :test, [:file, :count] do |t, args|
  puts %(\n*** Running test with "#{args.file}" for #{args.count} iterations ***\n)
  duLog = 'du.log'
  xcute "rm #{duLog} 2>/dev/null"
  args.count.times { runTest(args.file, duLog) }
end

def runTest(file, duLog)
  puts "\n*** Running test on #{file} ***\n"
  xcute "rm -fr docs docs.zip 2>/dev/null"
  xcute "jazzy --module AImaKit"
  xcute "rm -fr docs/{docsets,undocumented.json}"
  xcute "zip -r docs docs" if file == 'docs.zip'
  xcute "git ls-files --error-unmatch #{file}"
  xcute "git add #{file}" unless $? == 0
  xcute "git commit -a -m test"
  xcute "du -hs . >> #{duLog}"
end

def xcute(command, &block)
  #puts "block_given? is #{block_given?}."
  command += ' 2>&1' unless command.include? "2>"
  puts "\n$ #{command}"
  #sh(command, &block) # This redirects stdout to stderr, screws up logs??
  puts %x-#{command}-
  $?
end
