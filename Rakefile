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
  sh "rmdir tmp" # Make sure it is empty, diamonds visit here.
end

desc "Generate documentation"
task :docs do
  
  # Save GitHub Pages artifacts.
  FileUtils.mkdir_p('tmp/docs')
  FileUtils.mv('docs/_config.yml', 'tmp/docs')
  
  # Generate documentation.
  xcute "rm -fr docs"
  xcute "jazzy --module AImaKit"
  xcute "rm -fr docs/{docsets,undocumented.json}"
  
  # Change "Last updated: 2018-07-17" to "Last updated: 2018-07" to give us
  # one month, rather than one day, before git sees these metadata changes.
  # See https://stackoverflow.com/questions/1274605.
  Dir['docs/**/*.html'].each { |fileName|
    text = File.read(fileName)
    newContents = text.gsub(/(Last updated:) (\d\d\d\d-\d\d)-\d\d/, '\1 \2')
    
    # To merely print the contents of the file, use:
    #puts newContents
    
    # To write changes to the file, use:
    File.open(fileName, "w") { |file| file.puts newContents }
  }
  
  # Restore GitHub Pages artifacts.
  FileUtils.mv('tmp/docs/_config.yml', 'docs')
  FileUtils.rmdir('tmp/docs')
  
end

desc "Display list of tasks"
task :help do
  puts %x(rake -f #{__FILE__} -T)
end

desc "Run a test"
task :test do
  puts "Hello, " + (ENV['LOGNAME'] or ENV['USER']) + "!"
end

#
# Do not run this on production repo.
#
#task :testDocSpace, [:file, :kount] do |t, args|
#  puts %(\n*** Running testDocSpace with "#{args.file}" for #{args.kount} iterations ***\n)
#  duLog = 'du.log'
#  xcute "rm #{duLog} 2>/dev/null"
#  args.kount.to_i.times { testDocSpaceRun(args.file, duLog) }
#end

#
# This test quickly shows that over a dozen runs of no source changes,
# docs adds nothing new to git while a docs.zip adds a megabyte.  So
# put docs rather than docs.zip under source control if you want to
# present a friendly API reference.
#
def testDocSpaceRun(file, duLog)
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

#
# Used by assorted tasks, this makes the "what is it doing?" question
# a little easier to answer.
#
def xcute(command, &block)
  #puts "block_given? is #{block_given?}."
  command += ' 2>&1' unless command.include? "2>"
  puts "\n$ #{command}"
  #sh(command, &block) # This redirects stdout to stderr, screws up logs??
  puts %x-#{command}-
  $?
end
