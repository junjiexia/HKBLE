//
//  BLEWorker.swift
//  HKBluetoothSDK
//
//  Created by Levy on 2019/12/10.
//  Copyright © 2019 Shenzhen Blacktek. All rights reserved.
//

import Foundation

final class BLEWorker: NSObject {
    static let share = BLEWorker()
    
    @objc dynamic var name: String = ""
    @objc dynamic var eq_text: String = ""
    @objc dynamic var version: String = ""
    @objc dynamic var mac_address: String = ""
    @objc dynamic var cs_text: String = ""
    @objc dynamic var isBind: Bool = false
    var lastPowerTime: String = ""
    
    var bleList: [BleParipheralInfo] = []
    var dataList: [UserRecordItem] = []
    
    var electric_quantity: Int? {
        didSet {
            guard let eq = electric_quantity else {return}
            self.eq_text = (eq == -99 ? "充电中" : "\(eq)%") + "上次充电时间：\(lastPowerTime)"
        }
    }
    
    var linkCard: BleParipheralInfo? {
        didSet {
            guard let cur = linkCard else {return}
            self.mac_address = cur.macAddress
        }
    }
    
    var connectState: BLEConnectState = BLE_NONE  /// 连接状态
    var isOtaUpdate: Bool = false   /// 正在更新硬件
    var sys_ble_enable: Bool = true /// 系统蓝牙是否正常
    
    override init() {
        super.init()
        self.setupValue()
    }
    
    func setupValue() {
        
    }
    
    func startWork() {
        HKBluetooth.sharedInstance().startWork(with: self)
    }
    
    func stopWork() {
        HKBluetooth.sharedInstance().stopWork()
    }
    
    func startScan() {
        HKBluetooth.sharedInstance().startScan()
    }
    
    func stopScan() {
        HKBluetooth.sharedInstance().stopScan()
    }
    
    func stopScanIfConnected() {
        guard self.connectState == BLE_CONNECTED else {return}
        HKBluetooth.sharedInstance().stopScan()
    }
    
    func reStartScan() {
        HKBluetooth.sharedInstance().stopScan()
        HKBluetooth.sharedInstance().startScan()
    }
    
    func reStartScanForBind() {
        guard isBind else {return}
        HKBluetooth.sharedInstance().stopScan()
        HKBluetooth.sharedInstance().startScan()
    }
    
    func reStartScanAfterCheck() {
        guard self.connectState != BLE_CONNECTED, self.isBind else {return}
        HKBluetooth.sharedInstance().stopScan()
        HKBluetooth.sharedInstance().startScan()
    }
    
    /// 连接 ///
    func connect(_ item: BleParipheralInfo) {
        if item.macAddress.count > 0 {
            self.isBind = true
            self.linkCard = item
            self.name = item.name
            HKBluetooth.sharedInstance().connect(with: item.peripheral, andCardMac: item.macAddress)
        }
    }
    
    /// 解绑 ///
    func unbinding() {
        self.unbindingSetup()
    }
    
    /// 其他界面绑定、解绑设置 ///
    func bindingSetup(_ mac: String) {
        guard mac.count > 0 else { return }
        
        var item: BleParipheralInfo?
        let macAddress = mac.macType()
        
        for im in bleList {
            if im.macAddress == macAddress {
                item = im
                break
            }
        }
        
        self.isBind = true
        if let it = item {
            self.linkCard = it
            self.name = it.name
            HKBluetooth.sharedInstance().connect(with: it.peripheral, andCardMac: macAddress)
        }else {
            self.mac_address = macAddress
            self.name = "HK"
            self.cs_text = "蓝牙未连接"
            HKBluetooth.sharedInstance().bind(withMacAddress: macAddress)
        }
    }
    
    func unbindingSetup() {
        self.isBind = false
        self.cs_text = ""
        self.name = ""
        self.eq_text = ""
        self.version = ""
        self.mac_address = ""
        if let item = self.linkCard {
            HKBluetooth.sharedInstance().unbinding(with: item.peripheral)
            self.linkCard = nil
        }else {
            HKBluetooth.sharedInstance().unbinding()
        }
        
        self.dataList.removeAll()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bluetoothDataListUpdate"), object: nil, userInfo: nil)
    }
}

extension BLEWorker: HKBluetoothDelegate {
    
    @available(iOS 10.0, *)
    func bluetoothState(_ state: CBManagerState) {
        print("系统蓝牙状态: ", state.rawValue)
        switch state {
        case .poweredOn:
            self.reStartScanForBind()
            self.sys_ble_enable = true
        default:
            /// 此时，蓝牙无法发送数据，只能手动修改状态
            self.eq_text = ""
            self.version = ""
            self.cs_text = self.isBind ? "蓝牙未连接" : ""
            self.connectState = BLE_DISCONNECTED
            self.sys_ble_enable = false
        }
    }

    /// 蓝牙列表
    func bluetoothList(_ result: [Any]) {
        guard let list = result as? [BleParipheralInfo] else {return}
        self.bleList = list
        if self.mac_address.count > 0 {
            for item in list {
                if self.mac_address == item.macAddress {
                    self.linkCard = item
                    break
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bluetoothListUpdate"), object: nil, userInfo: ["bluetoothList": list])
    }
    /// 电量
    func bluetoothVoltage(_ voltage: UInt, charge: UInt8, date: Date, nilDate isNilDate: Bool) {
        self.lastPowerTime = isNilDate ? "" : date.dateString("yyyy-MM-dd HH:mm:ss")
        self.electric_quantity = charge == 1 ? -99 : Int(voltage)
    }
    /// 版本
    func bluetoothVersion(_ version: String) {
        self.version = version
        self.checkDeviceVersion()
    }
    /// 连接状态
    func bluetoothConnectState(_ state: BLEConnectState, peripheralInfo info: BleParipheralInfo) {
        print("蓝牙连接状态：", state, "连接设备：", info.name, info.macAddress)
        self.connectState = state
        switch state {
        case BLE_CONNECTED:
            self.isBind = true
            self.cs_text = "蓝牙已连接"
            self.name = info.name
            self.mac_address = info.macAddress
            self.linkCard = info
        default:
            self.cs_text = isBind ? "蓝牙未连接" : ""
            self.eq_text = ""
            self.version = ""
            self.linkCard = nil
            
            if !isBind {
                self.name = ""
                self.mac_address = ""
            }
        }
    }
    
    //MARK: - 设备更新及回调
    private func checkDeviceVersion() { /// 检查硬件版本
        guard !isOtaUpdate else {return}
        
        self.isOtaUpdate = true
        
        HKHTTP.request("http://szydak.eicp.net:82/ezx_syset/apk/checkDeviceVersion", "GET", [:], success: {[weak self] (data) in
            guard let sself = self else { return }
            guard let dict = data.JSONToAny() as? [String: Any] else { sself.isOtaUpdate = false; return }
            guard let dic = dict["data1"] as? [String: Any] else { sself.isOtaUpdate = false; return }
            guard let fileName = dic["filename"] as? String, let path = dic["path"] as? String, let version = dic["version"] as? String else { sself.isOtaUpdate = false; return }
            
            let current = sself.version.sub(6, 8)
            
            let now = Int(current) ?? 0
            let new = Int(version) ?? 0
            
            guard new > 0, new != now else { sself.isOtaUpdate = false; return }
            
            HKAlert.show(alert: nil, "卡片升级", "卡片有新版本，是否升级？") {
                sself.checkDeviceVersionDealwith(version, path, fileName)
            }
        }) {[weak self] (error) in
            guard let sself = self else {return}
            sself.isOtaUpdate = false
        }
    }
    
    private func checkDeviceVersionDealwith(_ version: String, _ path: String, _ fileName: String) { /// 检查硬件版本处理
        guard self.mac_address.count > 0, self.linkCard?.bleType == BLE_TYPE_SENSEACQUISITION_CARD else { self.isOtaUpdate = false; return } /// 确定是卡片Mac地址
        guard self.version.count > 7, !self.version.contains(version) else { self.isOtaUpdate = false; return } /// 检查版本号的有效性，及是否是不同版本
        guard self.connectState == BLE_CONNECTED else { self.isOtaUpdate = false; return } /// 确定蓝牙正常连接
        
        let urlStr = String(format: "http://www.allsps.com/ezx_syset/download?filepath=%@&filename=%@", path, fileName)
        HKHTTP.download(urlStr, path, fileName, success: {[weak self] (filePath) in
            guard let sself = self else {return}
            if let fpath = filePath {
                XJJProgress.start("蓝牙固件升级", "发现新的蓝牙固件版本'V\(version)'，为了确保您的硬件能够正常使用，需要升级到最新版本。\n固件升级中请勿断开蓝牙！", nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    HKBluetooth.sharedInstance().updateCard(withPath: fpath) /// 更新硬件
                })
                return
            }
            
            sself.isOtaUpdate = false
        }) {[weak self] (error) in
            guard let sself = self else {return}
            sself.isOtaUpdate = false
        }
    }
    
    func bluetoothUpdateStatus(_ status: OtaUpdateStatus, progress: Float) {
        print("蓝牙版本更新，状态：", status, "进度：", progress)
        switch status {
        case OTA_UPDATE_SUCCESS:
            XJJProgress.update(progress)
        case OTA_UPDATE_COMPLETE:
            self.isOtaUpdate = false;
            XJJProgress.end()
            HKAlert.show(prompt: nil, "提示", "设备升级成功,请等待重新连接")
        default:
            self.isOtaUpdate = false;
            if XJJProgress.progressView != nil {
                XJJProgress.end()
                HKAlert.show(prompt: nil, "提示", "设备升级失败")
            }
            print("更新蓝牙硬件版本出错:", status)
        }
    }
    
    //MARK: - 在线打卡数据
    func bluetoothOnlineData(_ cardItem: UserRecordItem) {
        print("在线打卡数据 -- ", cardItem)
        self.dataList.append(cardItem)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bluetoothDataListUpdate"), object: nil, userInfo: nil)
    }
    
    //MARK: - 离线打卡数据
    func bluetoothOfflineDataTotal(_ totalNum: Int) {
        print("你的蓝牙采集器有\(totalNum)条离线数据")
        HKAlert.show(alert: nil, "提示", "你的蓝牙采集器有\(totalNum)条离线数据未同步") {
            HKBluetooth.sharedInstance().getBleDataOfOffline() // 同步数据
        }
    }
    
    func bluetoothOfflineDataProcess(withComplate complateNum: Int, total totalNum: Int, begin: Bool) {
        if begin {
            XJJProgress.start("离线打卡数据获取", "开始读取，总共: \(totalNum)", nil)
        }else {
            XJJProgress.update(Float(complateNum/totalNum))
        }
        
        if complateNum == totalNum {
            XJJProgress.end()
        }
    }
    
    func bluetoothOfflineData(_ cardArr: [Any]) {
        HKAlert.show(prompt: nil, "提示", "离线打卡数据获取完成")
        
        if let arr = cardArr as? [UserRecordItem] {
            self.dataList.append(contentsOf: arr)
            HKBluetooth.sharedInstance().clearCache()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bluetoothDataListUpdate"), object: nil, userInfo: nil)
        }
    }
    
    func bluetoothBaseStationData(_ dic: [AnyHashable : Any]) {
        print("基站数据：", dic)
        let macAddress = dic["macAddress"] as? String
        let eq = dic["power"] as? String
        let item = UserRecordItem()
        item.mac = (macAddress ?? "") + "(基站) 电量:" + ((eq != nil) ? "\(eq!)%" : "")
        item.check_in = Date().timeIntervalSince1970 + 1000
        self.dataList.append(item)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "bluetoothDataListUpdate"), object: nil, userInfo: nil)
    }
}
