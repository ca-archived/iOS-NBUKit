

Pod::Spec.new do |s|
    
    s.name          = "NBUKit"
    s.version       = "1.9.0"
    s.platform      = :ios
    s.summary       = "Customizable image editing, filters, picker and other UIKit subclasses."
    s.homepage      = "http://cyberagent.github.io/iOS-NBUKit/"
    s.license       = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author        = { "CyberAgent Inc." => "", "Ernesto Rivera" => "rivera_ernesto@cyberagent.co.jp" }
    
    s.source        = { :git => "https://github.com/CyberAgent/iOS-NBUKit.git", :tag => "#{s.version}" }
    s.source_files  = 'Source/*.{h,m}'
    s.resources     = ["Resources/*.{png,lproj}", "Resources/filters", "Source/**/*.{xib}"]
    s.preserve_paths = "README.*", "NOTICE"
    
    s.requires_arc  = true
    s.frameworks    = 'AssetsLibrary', 'CoreLocation', 'MessageUI'
    s.weak_frameworks = 'CoreImage'
    
    s.dependency 'NBUCore',     '~> 1.8.1'
    s.dependency 'GPUImage',    '~> 0.1.0'
    
    s.subspec 'UI' do |su|
        su.source_files = 'Source/UI/*.{h,m}'
    end
    
    s.subspec 'Image' do |si|
        si.source_files = 'Source/Image/*.{h,m}'
    end
    
    s.subspec 'Assets' do |sa|
        sa.source_files = 'Source/Assets/*.{h,m}'
    end
    
    s.subspec 'Picker' do |sp|
        sp.source_files = 'Source/Picker/*.{h,m}'
    end
    
    s.subspec 'Library' do |sl|
        
        sl.subspec 'NBUCompatibility' do |sc|
            sc.source_files     = 'Library/NBUCompatibility'
        end
        
        sl.subspec 'RestKit Support' do |srk|
            srk.source_files    = 'Library/RestKit Support'
            srk.requires_arc    = false
            srk.frameworks      = 'MobileCoreServices'
        end
        
        sl.subspec 'RBVolumeButtons' do |srb|
            srb.source_files    = 'Library/RBVolumeButtons'
            srb.requires_arc    = false
            srb.frameworks      = 'MediaPlayer', 'AudioToolbox'
        end
        
    end
    
end

