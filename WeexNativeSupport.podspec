Pod::Spec.new do |s|
s.name         = 'WeexNativeSupport'
s.version      = '1.1.1'
s.summary      = 'weex原生支持'
s.homepage     = 'https://github.com/shuxiongWu/WeexNativeSupport.git'
s.license      = { :type => "MIT", :file => "LICENSE" }
s.authors      = {'wushuxiong' => '18779884209@163.com'}
s.platform     = :ios, '8.0'
s.source       = {:git => 'https://github.com/shuxiongWu/WeexNativeSupport.git', :tag => s.version}
s.source_files = 'WeexNativeSupport/**/*.{h,m}'

s.dependency 'SVProgressHUD'
s.dependency 'MJExtension'
s.dependency 'AFNetworking'
s.dependency 'CocoaLumberjack'
s.dependency 'WeexSDK'
s.dependency 'SocketRocket'
s.dependency 'WeexPluginLoader'
s.dependency 'SDWebImage'
s.requires_arc = true

end
