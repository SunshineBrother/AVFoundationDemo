//
//  String+Extentsion.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2022/11/1.
//

import UIKit

extension String {
    /// 将字符串通过特定的字符串拆分为字符串数组
    ///
    /// - Parameter string: 拆分数组使用的字符串
    /// - Returns: 字符串数组
    func split(string: String) -> [String] {
        return NSString(string: self).components(separatedBy: string)
    }
}
