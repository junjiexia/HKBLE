# HKBLE
HK Bluetooth package, used to connect specific Bluetooth devices of HK and obtain Bluetooth data

黑卡科技蓝牙设备连接，数据读取文档

导入
1. 直接导入，下载后把sdk文件夹复制到工程里即可使用
2. 通过cocoapods导入
        pod 'HKBLESDK'
        
项目配置
1. info.plist 里添加 NSBluetoothPeripheralUsageDescription，NSBluetoothAlwaysUsageDescription两项；
2. Build Settings 里 Other Linker Flags 添加 -ObjC；
3. Build Settings 里 Enable Bitcode 改为 NO；

项目使用
UserRecordItem.h 是蓝牙打卡数据model，所有打卡数据可尝试解析为UserRecordItem类型；
HKBluetooth.h 里的 BleParipheralInfo
