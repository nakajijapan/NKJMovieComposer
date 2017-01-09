# frozen_string_literal: true
require 'xcodeproj'

# settings
path =  './NKJMovieComposer.xcworkspace'

def change_build_settings(project)
  puts "Project path(#{project.path})"
  project.build_configurations.each do |config|
    change_swift_version(config)
  end

  project.targets.each do |target|
    puts "Target is #{target.name}"
    target.build_configurations.each do |config|
      change_swift_version(config)
    end
  end
end

def change_swift_version(config)
  key = 'SWIFT_VERSION'
  config.build_settings[key] = '3.0.1'
  puts "changed #{key}(#{config.build_settings[key]})"
end

workspace = Xcodeproj::Workspace.new_from_xcworkspace(path)
workspace.schemes.each do |_, value|
  project = Xcodeproj::Project.open(value)
  change_build_settings(project)
  project.save
end
