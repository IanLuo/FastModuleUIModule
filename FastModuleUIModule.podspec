Pod::Spec.new do |s|
  s.name         = "FastModuleUIModule"
  s.version      = "0.0.1"
  s.summary      = "A FastModuleUIModule."
  s.description  = "UI Components that compatable with FastModule"
  s.homepage     = "https://github.com/IanLuo/FastModuleUIModule"
  s.license      = "MIT"
  s.author             = { "luoxu" => "ianluo63@gmail.com" }
  s.source       = { :git => "git@github.com:IanLuo/FastModuleUIModule.git", :tag => "#{s.version}" }
  s.source_files  = "Sources/**/*.swift"
end
