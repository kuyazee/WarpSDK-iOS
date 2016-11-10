Pod::Spec.new do |s|

  s.name         = "WarpSDK"
  s.version      = "0.0.4"
  s.summary      = "The Warp iOS SDK is a library designed to work with projects built on-top of the Warp Server."
  s.homepage     = "https://github.com/dividedbyzeroco/warp-server"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Zonily Jame Pesquera" => "zonilyjame@gmail.com" }
  s.social_media_url   = "http://twitter.com/kuyazee"

  s.platform     = :ios, "8.0"
  s.requires_arc = true
  s.source       = { :git => "https://github.com/kuyazee/WarpSDK-iOS.git", :tag => "#{s.version}" }
  s.source_files  = "WarpSDK", "WarpSDK/**/*.{h,swift}"

  s.dependency "Alamofire", "~> 3.5.0"
  s.dependency "EVReflection", "~> 2.6"

end
