//
//  HKBluetooth.h
//  HKBluetooth
//
//  Created by Levy on 2018/11/7.
//  Copyright © 2018年 Shenzhen Blacktek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserRecordItem.h"

#if TARGET_OS_IPHONE
#import <CoreBluetooth/CoreBluetooth.h>
#else
#import <IOBluetooth/IOBluetooth.h>
#endif

NS_ASSUME_NONNULL_BEGIN

// firmware
#define FW_FILE_CODE_LENGTH_MIN        0
#define FW_FILE_CODE_LENGTH_MAX        (50*1024)

// 定时获取蓝牙信息（电量）的时间间隔（建议 60秒 以上）（默认60秒）
#define BLE_TIMER_TIMEOUT   60

/// OTA api result during transfering data
typedef enum : NSUInteger {
    /// 成功 /// 蓝牙传输成功返回
    OTA_UPDATE_SUCCESS = 0,
    /// 完成 /// 进度完成返回
    OTA_UPDATE_COMPLETE,
    /// 失败 ///
    // 升级包大小为0
    OTA_UPDATE_SIZE_ZERO,
    // 升级包大小大于最大值 - FW_FILE_CODE_LENGTH_MAX
    OTA_UPDATE_SIZE_OVERFLOW,
    // 升级包校验错误
    OTA_UPDATE_CHECKSUM_ERROR,
    // 设备不支持OTA
    OTA_UPDATE_DEVICE_NOT_SUPPORT_OTA,
    // 固件包溢出或者为0
    OTA_UPDATE_FW_SIZE_ERROR,
    // 固件验证错误
    OTA_UPDATE_FW_VERIFY_ERROR,
    // 蓝牙断开
    OTA_UPDATE_BLE_DISCONNECT,
    // 正在获取打卡数据（占线）
    OTA_UPDATE_BLE_BUSY,
} OtaUpdateStatus;

typedef enum : NSUInteger {
    BLE_NONE = 0, /// -- 0: 无
    BLE_CONNECTED, /// -- 1: 连接成功
    BLE_DISCONNECTED, /// -- 2: 正常断开
    BLE_DISCONNECTED_ERROR, /// -- 3: 异常断开
    BLE_CONNECTED_FAIL, /// -- 4: 连接失败
    BLE_UNBINDING, /// -- 5: 解除绑定
} BLEConnectState;

typedef enum : NSUInteger {
    BLE_TYPE_UNKOWN = 0, /// -- 未知
    BLE_TYPE_SENSEACQUISITION_CARD, /// -- 有感采集卡
    BLE_TYPE_SENSELESSACQUISITION_CARD, /// -- 无感采集卡
    BLE_TYPE_LTBASESTATION, /// -- 定位标签基站
    BLE_TYPE_GIBASESTATION /// -- 网关识别基站
} BLEType;

@class BleParipheralInfo;

@interface BleParipheralInfo : NSObject
/// discovered pariphecal device.
@property (nonatomic, retain) CBPeripheral *peripheral;

/// device's name
@property (nonatomic, copy) NSString *name;

/// device's mac address
@property (nonatomic, copy) NSString *macAddress;

// device's rssi
@property (nonatomic, copy) NSNumber *rssi;

// device's type
@property (nonatomic, readonly) BLEType bleType;

@end

@protocol HKBluetoothDelegate

@optional
/// 系统蓝牙的状态
- (void)bluetoothState: (CBManagerState )state API_AVAILABLE(ios(10.0));
- (void)bluetoothStateOld: (CBCentralManagerState )state;

/// 获取蓝牙列表返回，开启扫描后开始返回
/// -- CBPeripheral 的数组，元素类型：BlePariphecalInfo
- (void)bluetoothList: (NSArray *)result;

/// 获取蓝牙连接状态
- (void)bluetoothConnectState: (BLEConnectState)state peripheralInfo: (BleParipheralInfo *)info;

/// 获取电池电量
/// -- voltage 电池电量
/// -- charge 充电标志：0 未充电  1 充电状态
/// -- date 上一次充电时间
/// -- isNilDate 上一次充电时间是否为空（swift 代码接入，避免发生为空错误）
- (void)bluetoothVoltage: (NSUInteger)voltage Charge: (Byte)charge Date: (NSDate *)date NilDate: (BOOL)isNilDate;

/// 获取卡片版本号
- (void)bluetoothVersion: (NSString *)version;

/// 升级过程
- (void)bluetoothUpdateStatus: (OtaUpdateStatus)status progress: (float)progress;

/// 打卡数据获取（在线）
- (void)bluetoothOnlineData: (UserRecordItem *)cardItem;

/// 打卡数据总数获取（离线）
- (void)bluetoothOfflineDataTotal: (NSInteger)totalNum;

/// 打卡数据获取进程（离线）
/// -- complateNum 完成数量
/// -- totalNum 总数
/// -- begin 是否是起始（方便于做进度提示）
- (void)bluetoothOfflineDataProcessWithComplate: (NSInteger)complateNum Total: (NSInteger)totalNum Begin: (BOOL)begin;

/// 打卡数据获取（离线）
- (void)bluetoothOfflineData: (NSArray *)cardArr;

/// 基站数据获取（扫描时就可获取）
- (void)bluetoothBaseStationData: (NSDictionary *)dic;

@end

/// bluetooth connect state
// 蓝牙连接的状态
#define bleConnectState   @"bleConnectState"

@interface HKBluetooth : NSObject

@property (nonatomic, weak) id <HKBluetoothDelegate> hkbleDelegate;
@property (nonatomic, assign) BOOL isAutoConnect; // 是否自动连接，默认为YES
@property (nonatomic, copy) NSArray *bluetoothList; // 蓝牙列表

+ (HKBluetooth *)sharedInstance;

/// 开启工作：正常工作扫描、连接、遵循协议
- (void)startWorkWithDelegate: (id<HKBluetoothDelegate> _Nullable)objc;

/// 结束工作：取消协议
- (void)stopWork;

/// 开始扫描
- (void)startScan;

/// 结束扫描
- (void)stopScan;

/// 连接蓝牙
// 需要蓝牙设备和蓝牙的Mac地址（重连时会用到）作为参数
- (void)connectWithPeripheral: (CBPeripheral *)peripheral andCardMac: (NSString *)cardMac;

/// 设置默认蓝牙连接状态
- (void)defaultStateSetup;

/// 断开当前蓝牙
- (void)disconnectWithPeripheral: (CBPeripheral *)peripheral;

/// 绑定（建立重连设备）
- (void)bindWithMacAddress: (NSString *)macAddress;

/// 解除绑定（清空重连设备）
- (void)unbindingWithPeripheral: (CBPeripheral *)peripheral;
- (void)unbinding;

/// 更新重连Mac地址，非APP绑定、解绑（macAddress 传空值）使用
/// 如果非APP解绑，且正在连接，断开连接
- (void)updateMac: (NSString *)macAddress;

/// 获取离线数据
- (void)getBleDataOfOffline;

/// 清除打卡缓存
- (void)clearCache;

/// 卡片升级
/// 需要本地文件的路径
- (void)updateCardWithPath: (NSString *)path;

@end

NS_ASSUME_NONNULL_END
