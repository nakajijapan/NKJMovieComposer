require 'xcodeproj'
project_path = './NKJMovieComposer.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|

  puts "#{target.name}"
  target.build_configurations.each do |config|

    key = 'SWIFT_VERSION'
    config.build_settings[key] ||= '3.0.1'
    puts "changed #{key}(#{config.build_settings[key]})"

  end
end
