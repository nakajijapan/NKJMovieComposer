# frozen_string_literal: true
require 'xcodeproj'

project_paths = ['./NKJMovieComposer.xcodeproj', './NKJMovieComposerDemo.xcodeproj']


def change_build_settings(project)
  project.targets.each do |target|
    puts "Target is #{target.name}"
    target.build_configurations.each do |config|
      key = 'SWIFT_VERSION'
      config.build_settings[key] = '3.0.1'
      puts "changed #{key}(#{config.build_settings[key]})"
    end
  end
end

project_paths.each do |path|
  project = Xcodeproj::Project.open(path)
  change_build_settings(project)
  project.save
end
