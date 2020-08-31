Pod::Spec.new do |s|
s.name         = 'WeexNativeSupport'
s.version      = '1.8.43'
s.summary      = 'weex原生支持'
s.homepage     = 'https://github.com/shuxiongWu/WeexNativeSupport.git'
s.license      = { :type => "MIT", :file => "LICENSE" }
s.authors      = {'wushuxiong' => '18779884209@163.com'}
s.platform     = :ios, '9.0'
s.source       = {:git => 'https://github.com/shuxiongWu/WeexNativeSupport.git', :tag => s.version}
s.resources    = "WeexNativeSupport/HXPhotoPicker/HXPhotoPicker.bundle"
s.source_files = 'WeexNativeSupport/**/*.{h,m}'
s.static_framework = true

s.dependency 'SVProgressHUD'
s.dependency 'SSZipArchive'
s.dependency 'MJExtension'
s.dependency 'AFNetworking', '4.0.1'
s.dependency 'CocoaLumberjack'
s.dependency 'WeexSDK'
s.dependency 'SocketRocket'
s.dependency 'WeexPluginLoader'
s.dependency 'MJRefresh'
s.dependency 'AMapSearch-NO-IDFA'
s.dependency 'AMapLocation-NO-IDFA'
s.dependency 'AMap3DMap-NO-IDFA'
s.dependency 'WYNetworkManager', '0.1.1'
s.dependency 'QCloudCOSXML/Transfer'
s.requires_arc = true

end