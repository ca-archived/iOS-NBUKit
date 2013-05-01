Pod::Spec.new do |s|
    s.name          = "NBUKit"
    s.version       = "1.8.0"
    s.summary       = "Customizable image editing, filters, picker and other UIKit subclasses."
    s.homepage      = "http://cyberagent.github.io/iOS-NBUKit/"
    s.license       = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author        = { "CyberAgent Inc." => "", "Ernesto Rivera" => "rivera_ernesto@cyberagent.co.jp" }
    s.source        = { :git => "https://github.com/CyberAgent/iOS-NBUKit.git", :tag => "#{s.version}" }
    s.platform      = :ios
    s.source_files  = 'Source/**/*.{h,m}'
    s.resources     = ["Resources/**/*.{png,strings,acv}", "Source/**/*.{xib}"]
    s.frameworks  = 'AssetsLibrary', 'CoreLocation', 'MessageUI', 'CoreData'
    s.weak_frameworks = 'CoreImage'
    s.requires_arc  = true
    s.preserve_paths = "README.*", "NOTICE"
    
    s.dependency 'NBUCore', "~> #{s.version}"
    s.dependency 'GPUImage'
    
    s.subspec 'NBUCompatibility' do |sc|
        sc.source_files = 'Library/NBUCompatibility'
    end
    
    s.subspec 'Lorem Ipsum' do |sli|
        sli.source_files = 'Library/Lorem Ipsum'
    end
    
    s.subspec 'RestKit Support' do |srk|
        srk.source_files = 'Library/RestKit Support'
        srk.requires_arc = false
        srk.frameworks   = 'MobileCoreServices'
    end
    
    s.subspec 'RBVolumeButtons' do |srb|
        srb.source_files = 'Library/RBVolumeButtons'
        srb.requires_arc = false
        srb.frameworks   = 'MediaPlayer', 'AudioToolbox'
    end
end

