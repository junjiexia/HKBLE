//
//  CardBLEListViewController.swift
//  HKBluetoothSDK
//
//  Created by Levy on 2019/12/10.
//  Copyright © 2019 Shenzhen Blacktek. All rights reserved.
//

import UIKit

class CardBLEListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initUI()
        
        self.navigationItem.title = "正在搜索蓝牙..."
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "重新搜索", style: .done, target: self, action: #selector(rightItemAction))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.blue, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], for: .normal)
        // Do any additional setup after loading the view.
    }
    
    @objc func rightItemAction(_ item: UIBarButtonItem) {
        if BLEWorker.share.sys_ble_enable {
            BLEWorker.share.reStartScan()
        }else {
            print("搜索蓝牙失败，请检查手机蓝牙是否打开")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: NSNotification.Name(rawValue: "bluetoothListUpdate"), object: nil)
    }
    
    @objc func updateList(_ noti: Notification) {
        self.tableData = noti.userInfo?["bluetoothList"] as? [BleParipheralInfo] ?? []
        self.table.reloadData()
    }
    
    private var table: UITableView!
    
    private var tableData: [BleParipheralInfo] = []
    
    private func initData() {
        self.tableData = BLEWorker.share.bleList
    }
    
    private func initUI() {
        self.table = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), style: .plain)
        self.view.addSubview(table)
        
        self.setupUI()
    }
    
    private func setupUI() {
        self.table.backgroundColor = #colorLiteral(red: 0.7757574556, green: 0.7757574556, blue: 0.7757574556, alpha: 1)
        self.table.showsVerticalScrollIndicator = false
        self.table.showsHorizontalScrollIndicator = false
        self.table.separatorInset = .zero
        self.table.separatorStyle = .singleLine
        self.table.separatorColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        self.table.delegate = self
        self.table.dataSource = self
    }
}

extension CardBLEListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CardBLEListCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CardBLEListCell")
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.textColor = UIColor.darkGray
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.detailTextLabel?.textColor = UIColor.darkGray
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.backgroundColor = UIColor.white
        }
        
        let item = self.tableData[indexPath.row]
        cell?.textLabel?.text = "设备名称: " + (item.name.count > 0 ? item.name : "未知设备")
        cell?.detailTextLabel?.text = "Mac地址: " + (item.macAddress.count > 0 ? item.macAddress : "未扫描到地址")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.tableData[indexPath.row]
        BLEWorker.share.connect(item)
        self.navigationController?.popViewController(animated: true)
    }
}
