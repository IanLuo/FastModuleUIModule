Pod::Spec.new do |s|
  s.name         = "FastModuleUIModule"
  s.version      = "0.0.1"
  s.summary      = "A short description of FastModuleUIModule."
  s.description  = <<-DESC
                   DESC
  s.homepage     = "https://github.com/IanLuo/FastModuleUIModule"
  s.license      = "MIT (example)"
  s.author             = { "luoxu" => "xu.luo@hnair.com" }
  s.source       = { :git => "git@github.com:IanLuo/FastModuleUIModule.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.dependency "JSONKit", "~> 1.4"

end
