Pod::Spec.new do |s|
  s.name                  = "NKJMovieComposer"
  s.version               = "2.0.0"
  s.summary               = "A simple, modern movie composer for iOS and macOS using async/await."
  s.homepage              = "https://github.com/nakajijapan/NKJMovieComposer"
  s.license               = 'MIT'
  s.author                = { "nakajijapan" => "pp.kupepo.gattyanmo@gmail.com" }
  s.source                = { :git => "https://github.com/nakajijapan/NKJMovieComposer.git", :tag => s.version.to_s }

  s.swift_version = '5.9'
  s.ios.deployment_target = '16.0'
  s.osx.deployment_target = '13.0'
  s.requires_arc          = true
  s.source_files          = 'Sources/Classes/**/*'
  s.frameworks            = 'AVFoundation'
end
