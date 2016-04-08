Pod::Spec.new do |s|
  s.name     = 'IFXRefresher'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'Injection for Xcode auto Refresher, accelerates iOS development.'
  s.homepage = 'https://github.com/18plan/IFXRefresher'
  s.author   = { 'ShandaGames' => 'http://www.sdo.com' }
  s.source   = { :git => 'https://github.com/18plan/IFXRefresher.git', :tag =>s.version.to_s }

  s.description = %{
    IFXRefresher help us develop iOS UI so much. This is a tiny library need to work together 
  with Xcode plugin injectionforxcode at https://github.com/johnno1962/injectionforxcode.
  }

  s.source_files = 'IFXRefresher/*.{h,m}'
  s.ios.frameworks = 'Foundation', 'UIKit'
  
  s.platform = :ios
  s.ios.deployment_target = '6.0'

  s.requires_arc = true
end