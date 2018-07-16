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

desc "Display list of tasks"
task :help do
  puts %x(rake -f #{__FILE__} -T)
end

desc "Run a test"
task :test do
  #sh "rake -f #{__FILE__} -T"
  puts %x(rake -f #{__FILE__} -T)
end
