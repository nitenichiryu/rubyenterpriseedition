desc "Create a patch for the GC changes"
task :make_patch do
	vendor_branch = ENV['vendor_branch'] || 'vendor/version_1_8_6_114'
	files = `git diff #{vendor_branch} --stat | grep '|' | awk '{ print $1 }'`.split("\n")
	files -= ['Rakefile', '.gitignore', 'gctools/cowtest.rb', 'gctools/speedtest.rb']
	sh "git", "diff", "#{vendor_branch}", *files
end

desc "Change shebang lines for Ruby scripts to '#!/usr/bin/env ruby'"
task :fix_shebang do
	if ENV['dir'].nil?
		STDERR.write("Usage: rake fix_shebang dir=<SOME DIRECTORY>\n")
		exit 1
	end
	Dir.chdir(ENV['dir']) do
		sh "sed -i 's|^#!.*$|#!/usr/bin/env ruby|' *"
	end
end
