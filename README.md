README

info.plist文件需添加的key

required
1、存储照片到相册
<key>NSPhotoLibraryAddUsageDescription</key>
<string>使用相册</string>

2、定位
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要使用定位功能获取位置信息，是否允许使用定位权限</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>需要使用定位功能获取位置信息，是否允许使用定位权限</string>
<key>NSLocationUsageDescription</key>
<string>需要使用定位功能获取位置信息，是否允许使用定位权限</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要使用定位功能获取位置信息，是否允许使用定位权限</string>

3、相机权限
<key>NSCameraUsageDescription</key>
<string>App需要使用相机权限进行拍照才能编辑头像，是否允许使用相机权限</string>

3、通讯录权限
<key>NSContactsUsageDescription</key>
<string>App需要获取获取通讯录以添加紧急联系人</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>

4、麦克风权限
<key>NSMicrophoneUsageDescription</key>
<string>App需要录制视频才能使用上传视频，是否允许使用麦克风权限</string>

5、照片权限
<key>NSPhotoLibraryAddUsageDescription</key>
<string>App需要上传照片才能使用编辑头像，是否允许使用照片权限</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>App需要上传照片才能使用编辑头像，是否允许使用照片权限</string>


optional
这里仅提供键值以参考
1、蓝牙打印机
<key>NSBluetoothAlwaysUsageDescription</key>
<string>超盟餐饮需要使用蓝牙功能才能连接蓝牙打印机</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>超盟餐饮需要使用蓝牙打印功能，是否允许使用蓝牙权限</string>

2、修改复制粘贴提示语言
<key>CFBundleDevelopmentRegion</key>
<string>zh_CN</string>


