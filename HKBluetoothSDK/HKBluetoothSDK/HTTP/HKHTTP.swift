//
//  HKHTTP.swift
//  HKBluetoothSDK
//
//  Created by Levy on 2019/12/11.
//  Copyright © 2019 Shenzhen Blacktek. All rights reserved.
//

import Foundation

class HKHTTP {
    class func request(_ urlStr: String,
                       _ method: String,
                       _ params: [String: Any],
                       success: ((_ data: Data) -> Void)?,
                       failure: ((_ error: Error?) -> Void)?) {
        let paramsString = params.compactMap({ (key, value) -> String in
            let valueStr = "\(value)"
            return "\(key)=\(valueStr)"
            //return "\(key.utf8Str())=\(valueStr.utf8Str())"
        }).joined(separator: "&")
        
        let urlString = urlStr + (paramsString.count > 0 ? ("?" + paramsString) : "")
        let url_str = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let url = URL(string: url_str!) else {
            failure?(nil)
            print("request base:", "-url-", "invalid url:", urlString)
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        request.httpMethod = method
        request.httpBody = paramsString.data(using: .utf8)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let d = data, error == nil {
                DispatchQueue.main.async {
                    success?(d)
                }
            }else {
                DispatchQueue.main.async {
                    failure?(error)
                }
            }
        }
        
        dataTask.resume()
    }
    
    class func download(_ urlStr: String,
                        _ filePath: String,
                        _ fileName: String,
                        success: ((_ path: String?) -> Void)?,
                        failure: ((_ error: Error?) -> Void)?) {
        guard let url = URL(string: urlStr) else {
            print("download base:", "-url-", "invalid url:", urlStr)
            return
        }
        
        let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
            if error == nil {
                let toPath = saveFile(url?.path, fileName)
                
                DispatchQueue.main.async {
                    print("下载完成，路径：\(urlStr)-to-\(url?.path ?? "") 名称：\(fileName)")
                    success?(toPath)
                }
            }else {
                DispatchQueue.main.async {
                    print("下载失败")
                    failure?(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func saveFile(_ path: String?, _ fileName: String) -> String? {
        guard let _path = path else {return nil}
        let toPath = NSHomeDirectory() + "/Documents/TempFiles/" + fileName
        let folderPath = NSHomeDirectory() + "/Documents/TempFiles/"
        
        if FileManager.default.fileExists(atPath: toPath) {
            _ = removeFile(toPath)
        }
        
        guard createFolder(folderPath) else {return nil}
        
        do {
            try FileManager.default.copyItem(atPath: _path, toPath: toPath)
            return toPath
        }catch {
            print("save file error:", error)
            return nil
        }
    }
    
    class func removeFile(_ path: String) -> Bool {
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            }catch {
                return false
            }
        }
        
        return true
    }
    
    class func createFolder(_ path: String) -> Bool {
        guard !directoryIsExists(path) else {return true}
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            return true
        }catch {
            print(" 💫 ", "创建文件夹失败！ error: ", error)
            return false
        }
    }
    
    // 判断文件夹是否存在
    class func directoryIsExists(_ path: String) -> Bool {
        var directoryExists = ObjCBool.init(false)
        let fileExists = FileManager.default.fileExists(atPath: path, isDirectory: &directoryExists)
        
        return fileExists && directoryExists.boolValue
    }
}
