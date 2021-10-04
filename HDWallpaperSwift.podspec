Pod::Spec.new do |spec|

  spec.platform = :ios
  spec.name         = "HDWallpaperSwift"
  spec.version      = "1.0.2"
  spec.requires_arc = true
  spec.summary      = "A short description of HDWallpaperSwift."
  spec.description  = <<-DESC
  A much much longer description of HDWallpaperSwift.
                      DESC
  spec.homepage     = 'https://github.com/mmhmobilearts/HDWallpaperSwift'
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Mohamad" => "h.mohammad@smartmobiletech.org" }
  spec.source = { 
    :git => 'https://github.com/mmhmobilearts/HDWallpaperSwift.git', 
    :tag => spec.version.to_s 
  }
  spec.framework = 'UIKit'
  spec.source_files  = "HDWallpaperSwift/**/*.{swift}"
  spec.resources = "HDWallpaperSwift/**/*.{storyboard,xib,xcassets,lproj,png}"
  spec.swift_version = '5'
  spec.ios.deployment_target = '14.0'

end
