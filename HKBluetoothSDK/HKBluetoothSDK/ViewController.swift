//
//  ViewController.swift
//  HKBluetoothSDK
//
//  Created by Levy on 2019/12/10.
//  Copyright © 2019 Shenzhen Blacktek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    struct TableInfo {
        var title: String = ""
        var detail: String = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
        self.initUI()
        
        self.navigationItem.title = "设备管理"
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BLEWorker.share.startWork()
        self.addObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothDataListUpdate), name: NSNotification.Name(rawValue: "bluetoothDataListUpdate"), object: nil)
    }
    
    @objc func bluetoothDataListUpdate(_ noti: Notification) {
        self.dataTableData = BLEWorker.share.dataList
        self.dataTable.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeObservers()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "bluetoothDataListUpdate"), object: nil)
        super.viewWillDisappear(animated)
    }
    
    private var table: UITableView!
    private var tableFooter: UIView!
    private var bindBtn: UIButton!
    private var dataTable: UITableView!
    
    private var tableData: [TableInfo] = []
    private var dataTableData: [UserRecordItem] = []
    private var isBind: Bool = false
    
    private func initData() {
        self.tableData.append(TableInfo(title: "设备名称", detail: BLEWorker.share.name))
        self.tableData.append(TableInfo(title: "电量", detail: BLEWorker.share.eq_text))
        self.tableData.append(TableInfo(title: "固件版本", detail: BLEWorker.share.version))
        self.tableData.append(TableInfo(title: "Mac地址", detail: BLEWorker.share.mac_address))
        self.tableData.append(TableInfo(title: "连接状态", detail: BLEWorker.share.cs_text))
        
        if BLEWorker.share.mac_address.count > 0 {
            self.isBind = true
        }
    }
    
    private func initUI() {
        self.table = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 350), style: .plain)
        self.view.addSubview(table)
    
        self.tableFooter = UIView(frame: CGRect(x: 0, y: 0, width: self.table.bounds.width, height: 60))
        self.table.tableFooterView = tableFooter
        
        self.bindBtn = UIButton(frame: CGRect(x: 16, y: 10, width: self.tableFooter.bounds.width - 32, height: 40))
        self.tableFooter.addSubview(bindBtn)
        
        self.dataTable = UITableView(frame: CGRect(x: 0, y: self.table.frame.maxY, width: self.view.bounds.width, height: self.view.bounds.height - self.table.bounds.height), style: .plain)
        self.view.addSubview(dataTable)
        
        self.setupUI()
    }
    
    private func setupUI() {
        self.table.backgroundColor = UIColor.white
        self.table.showsVerticalScrollIndicator = false
        self.table.showsHorizontalScrollIndicator = false
        self.table.separatorStyle = .none
        self.table.delegate = self
        self.table.dataSource = self
        self.table.isScrollEnabled = false
        
        self.setupBindUI()
        self.bindBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.bindBtn.backgroundColor = UIColor.white
        self.bindBtn.addTarget(self, action: #selector(bindAction), for: .touchUpInside)
        
        self.dataTable.backgroundColor = #colorLiteral(red: 0.7757574556, green: 0.7757574556, blue: 0.7757574556, alpha: 1)
        self.dataTable.showsVerticalScrollIndicator = false
        self.dataTable.showsHorizontalScrollIndicator = false
        self.dataTable.separatorInset = .zero
        self.dataTable.separatorStyle = .singleLine
        self.dataTable.separatorColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        self.dataTable.delegate = self
        self.dataTable.dataSource = self
    }
    
    @objc func bindAction(_ btn: UIButton) {
        if self.isBind {
            BLEWorker.share.unbinding()
        }else {
            self.gotoCardBLEList()
        }
    }
    
    private func gotoCardBLEList() {
        guard BLEWorker.share.sys_ble_enable else {
            print("搜索蓝牙失败，请检查手机蓝牙是否打开!")
            return
        }
        let vc = CardBLEListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupBindUI() {
        self.bindBtn.setTitle(isBind ? "解绑设备" : "绑定设备", for: .normal)
        self.bindBtn.setTitleColor(isBind ? UIColor.red : UIColor.blue, for: .normal)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table {
            return self.tableData.count
        }else {
            return self.dataTableData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == table {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CELL01")
            if cell == nil {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CELL01")
                cell?.selectionStyle = .none
                cell?.textLabel?.textColor = UIColor.darkGray
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.detailTextLabel?.textColor = UIColor.darkGray
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.backgroundColor = UIColor.white
            }
            
            let item = self.tableData[indexPath.row]
            cell?.textLabel?.text = item.title
            cell?.detailTextLabel?.text = item.detail
            
            return cell!
        }else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "CELL02")
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CELL02")
                cell?.selectionStyle = .none
                cell?.textLabel?.textColor = UIColor.darkGray
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.detailTextLabel?.textColor = UIColor.darkGray
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.backgroundColor = UIColor.white
            }
            
            let item = self.dataTableData[indexPath.row]
            cell?.textLabel?.text = item.mac + ((item.tab_id != nil) ? "(\(item.tab_id.macType()))" : "")
            cell?.detailTextLabel?.text = Date.timeIntervalToDateString(msec: item.check_in, "yyyy-MM-dd HH:mm:ss")
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == dataTable {
            return 60
        }
        return 44
    }
    
}

//MARK: - KVO
extension ViewController {
    
    private func addObservers() {
        BLEWorker.share.addObserver(self, forKeyPath: "name", options: [.new, .old], context: nil)
        BLEWorker.share.addObserver(self, forKeyPath: "eq_text", options: [.new, .old], context: nil)
        BLEWorker.share.addObserver(self, forKeyPath: "version", options: [.new, .old], context: nil)
        BLEWorker.share.addObserver(self, forKeyPath: "mac_address", options: [.new, .old], context: nil)
        BLEWorker.share.addObserver(self, forKeyPath: "cs_text", options: [.new, .old], context: nil)
        BLEWorker.share.addObserver(self, forKeyPath: "isBind", options: [.new, .old], context: nil)
    }
    
    private func removeObservers() {
        BLEWorker.share.removeObserver(self, forKeyPath: "name")
        BLEWorker.share.removeObserver(self, forKeyPath: "eq_text")
        BLEWorker.share.removeObserver(self, forKeyPath: "version")
        BLEWorker.share.removeObserver(self, forKeyPath: "mac_address")
        BLEWorker.share.removeObserver(self, forKeyPath: "cs_text")
        BLEWorker.share.removeObserver(self, forKeyPath: "isBind")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let new = change?[.newKey] as? String ?? ""
        //let old = change?[.oldKey] as? String ?? ""
        
        switch keyPath {
        case "name":
            self.tableData[0].detail = new
            self.table.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        case "eq_text":
            self.tableData[1].detail = new
            self.table.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        case "version":
            self.tableData[2].detail = new
            self.table.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        case "mac_address":
            self.tableData[3].detail = new
            self.table.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
        case "cs_text":
            self.tableData[4].detail = new
            self.table.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
        case "isBind":
            self.isBind = change?[.newKey] as? Bool ?? false
            self.setupBindUI()
        default:
            break
        }
    }
}
