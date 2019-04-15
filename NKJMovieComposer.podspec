Pod::Spec.new do |s|
  s.name                  = "NKJMovieComposer"
  s.version               = "1.3.0"
  s.summary               = "NKJMovieComposer is very simple movie composer for iOS and OS X."
  s.homepage              = "http://github.com/nakajijapan"
  s.license               = 'MIT'
  s.author                = { "nakajijapan" => "pp.kupepo.gattyanmo@gmail.com" }
  s.source                = { :git => "https://github.com/nakajijapan/NKJMovieComposer.git", :tag => s.version.to_s }
  s.social_media_url      = 'https://twitter.com/nakajijapan'

  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.12'
  s.requires_arc          = true
  s.source_files          = 'Sources/Classes/**/*'
  s.frameworks            = 'AVFoundation'
end
