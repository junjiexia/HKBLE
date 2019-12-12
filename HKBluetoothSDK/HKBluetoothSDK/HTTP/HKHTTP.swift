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
        
        let urlString = urlStr + "?" + paramsString
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
                DispatchQueue.main.async {
                    print("下载完成，路径：\(url?.path ?? "")-to-\(filePath) 名称：\(fileName)")
                    success?(url?.path)
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
}
