//
//  FileManager.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2022/11/1.
//

import UIKit
import CommonCrypto

public class MyFileManager: NSObject {
    /// 单例
    public static let share = MyFileManager()
    /// 文件夹路径
    private lazy var directoryPath: String = {
        let path = createDirectory("FileManager")
        return path ?? getDocumentsPath()
    }()
    
    private override init() {
        super.init()
    }
   
    /// 写入文件
    /// - Returns: 是否写入成功
    public func writeFile(_ data: Any, forKey key: String) -> Bool {
        let fileName = getFile(key)
        return  (data as AnyObject).write(toFile: fileName, atomically: true)
    }

    /// 读取文件内容
    public func getObjectString(forKey key: String) -> String {
        let fileName = getFile(key)
        guard let text: String = try? NSString(contentsOfFile: fileName, encoding: String.Encoding.utf8.rawValue) as String else {
            return ""
        }
        return text
    }
    
    /// 读取文件内容
    public func getObjectList(forKey key: String) -> NSArray {
        let fileName = getFile(key)
     
        return NSArray(contentsOfFile: fileName) ?? []
    }
    
    /// 读取文件内容
    public func getObject(forKey key: String) -> NSDictionary {
        let fileName = getFile(key)
        return NSDictionary(contentsOfFile: fileName) ?? NSDictionary()
    }
    
    /// 读取文件内容
    public func getData(forKey key: String) -> NSData {
        let fileName = getFile(key)
        guard let data: NSData = NSData(contentsOfFile: fileName) else {
            return NSData()
        }
        return data
    }
    
    
    /// 删除文件
    public func removeFile(forKey key: String) {
        let fileName = getFile(key)
        do {
            try FileManager.default.removeItem(atPath: fileName)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    /// 删除所有文件
    public func removeAllFile() {
        do {
            try FileManager.default.removeItem(atPath: directoryPath)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
}

extension MyFileManager {
    /// 获取Documents路径
    func getDocumentsPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let path = paths.first {
            return path
        } else {
            debugPrint("获取沙盒路径失败")
            return ""
        }
    }

    /// 根据传入的文件夹名创建文件夹📂
    private func createDirectory(_ directoryName: String) -> String? {
        /// 获取路径
        let path = MyFileManager.share.getDocumentsPath()
        /// 创建文件管理者
        let fileManger = FileManager.default
        /// 创建文件夹
        let directoryPath = path + ("/\(directoryName)")
       
        if !fileManger.fileExists(atPath: directoryPath) { /// 先判断是否存在  不存在再创建
            do {
                try fileManger.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                return directoryPath
            } catch let error {
                debugPrint("文件夹创建失败:\(error.localizedDescription)")
                return nil
            }
        }

        return directoryPath

    }
    
    /// 根据传入的文件名创建文件
    private func getFile(_ fileName: String) -> String {
        /// 创建文件管理者
        let fileManger = FileManager.default
        /// 创建文件
        let filePath = MyFileManager.share.directoryPath + ("/\(fileName)")
        if !fileManger.fileExists(atPath: filePath) { /// 先判断是否存在  不存在再创建
            let isSuccess = fileManger.createFile(atPath: filePath, contents: nil, attributes: nil)
            assert(isSuccess, "文件创建失败")
        }
        debugPrint("文件路径:\(filePath)")
        return filePath
    }
    
}

 
