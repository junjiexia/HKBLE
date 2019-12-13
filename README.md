# HKBLE
HK Bluetooth package, used to connect specific Bluetooth devices of HK and obtain Bluetooth data

黑卡科技蓝牙设备连接，数据读取文档

工作环境
支持 iOS8.0 以上

导入
1. 直接导入，下载后把sdk文件夹复制到工程里即可使用
2. 通过cocoapods导入
        pod 'HKBLESDK'
        
项目配置
1. info.plist 里添加 NSBluetoothPeripheralUsageDescription，NSBluetoothAlwaysUsageDescription两项；
2. Build Settings 里 Other Linker Flags 添加 -ObjC；
3. Build Settings 里 Enable Bitcode 改为 NO；

项目使用

HKBluetooth 作为一个单利，承担着所有连接、数据获取、数据清空、硬件升级操作的功能：
1. 需要开启一个工作（工作后已经开始扫描），制定一个类遵循协议，承载协议方法；对应的有一个方法结束工作；

        - (void)startWorkWithDelegate: (id<HKBluetoothDelegate> _Nullable)objc;
        - (void)stopWork;
        
2. 开始扫描、结束扫描来控制蓝牙工作状态；

        - (void)startScan;
        - (void)stopScan;
        
3. 连接蓝牙需要：CBPeripheral（BleParipheralInfo里有储存） 类型的蓝牙数据；或者是标准的Mac地址作为连接对象；

        - (void)connectWithPeripheral: (CBPeripheral *)peripheral andCardMac: (NSString *)cardMac;
        
4. 断开蓝牙需要：CBPeripheral（BleParipheralInfo里有储存） 类型的蓝牙数据作为断开连接的对象；
        
        - (void)disconnectWithPeripheral: (CBPeripheral *)peripheral;
        
5. 绑定、解绑：是否记录Mac地址作为重连的对象；
        
        - (void)bindWithMacAddress: (NSString *)macAddress;
        - (void)unbindingWithPeripheral: (CBPeripheral *)peripheral;
        - (void)unbinding;
        - (void)updateMac: (NSString *)macAddress;
        
6. 获取离线数据，调用方法后，通过协议返回离线数据；

        - (void)getBleDataOfOffline;

7. 获取离线数据后，可清楚打卡缓存；

        - (void)clearCache;

8. 设备升级，需要本地设备升级文件路径，调用方法后，通过协议获取升级进程及结果；

        - (void)updateCardWithPath: (NSString *)path;

协议介绍：HKBluetoothDelegate
1. 系统蓝牙状态，开启工作后会获取蓝牙系统状态，通过以下方法返回，以 iOS10.0 为界限分为两个状态返回
        
        - (void)bluetoothState: (CBManagerState )state API_AVAILABLE(ios(10.0));
        - (void)bluetoothStateOld: (CBCentralManagerState )state;


2. 扫描到蓝牙后返回列表
        
        - (void)bluetoothList: (NSArray *)result;


3. 连接后，蓝牙连接状态返回，BLEConnectState 为蓝牙连接状态（见枚举），BleParipheralInfo为连接的设备信息

        - (void)bluetoothConnectState: (BLEConnectState)state peripheralInfo: (BleParipheralInfo *)info;

4. 连接上后，会定时获取电池电量，voltage为电量，charge 充电标志：0 未充电  1 充电状态，date 上一次充电时间，isNilDate 上一次充电时间是否为空（swift 代码接入，避免发生为空错误）

        - (void)bluetoothVoltage: (NSUInteger)voltage Charge: (Byte)charge Date: (NSDate *)date NilDate: (BOOL)isNilDate;

5. 连接上后，会获取一次设备版本号，version为一串字符串，需要自行获取解析

        - (void)bluetoothVersion: (NSString *)version;

6. 升级过程及结果，OtaUpdateStatus为升级的状态（见枚举），progress为升级的进度

        - (void)bluetoothUpdateStatus: (OtaUpdateStatus)status progress: (float)progress;

7. 打卡数据获取，分为在线（连接以后打卡）和离线（打卡后连接）两种方式，在线会自动清空，离线需要手动清空；
    UserRecordItem是打卡数据model，离线和在线都以这个model解析；
    离线数据是先获取总数，然后通过获取离线数据的方法获取离线数据，在协议返回离线数据获取进度及结果

        - (void)bluetoothOnlineData: (UserRecordItem *)cardItem; ------ 在线
        - (void)bluetoothOfflineDataTotal: (NSInteger)totalNum; ------ 离线总数获取
        - (void)bluetoothOfflineDataProcessWithComplate: (NSInteger)complateNum Total: (NSInteger)totalNum Begin: (BOOL)begin; ------ complateNum 完成数量  totalNum 总数  begin 是否是起始（方便于做进度提示）
        - (void)bluetoothOfflineData: (NSArray *)cardArr; ------ 离线数据接收

8. 基站类型蓝牙数据获取，扫描时获取；
    dic为字典：dic["macAddress"]获取蓝牙Mac地址；dic["power"]获取电池电量

        - (void)bluetoothBaseStationData: (NSDictionary *)dic;
