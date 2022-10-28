//
//  ViewController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2022/10/27.
//

import UIKit
class Model: NSObject {
    var title = ""
    var className = ""
}
 
class ViewController: UITableViewController {
    /// 数据源
    var dataList: [Model] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "音视频"
        self.getData()
    }
    
    func getData() {
        guard let filePath: String = Bundle.main.path(forResource: "data", ofType: "json") else {
            return
        }
        let url: URL = URL(fileURLWithPath: filePath)
        do {
            let data = try Data(contentsOf: url)
            let jsonData: Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            guard let jsonArr: NSArray = jsonData as? NSArray else {
                return
            }
            for item in jsonArr {
                if let dic: Dictionary = item as? Dictionary<String, String> {
                    let model = Model()
                    model.title = dic["title"] ?? ""
                    model.className = dic["class"] ?? ""
                    dataList.append(model)
                }
                
            }
        } catch let error {
            print("error:\(error)")
        }
    }
 
    // MARK: - Table view data source
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        let model = self.dataList[indexPath.row]
        cell?.textLabel?.text = model.title
        
        return cell!
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataList[indexPath.row]
        let nameSpace = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        guard let cls = NSClassFromString(nameSpace + "." + model.className) as? UIViewController.Type else {
            return
        }
        // 通过得到的class类型创建对象
        let vcClass = cls.init()
        vcClass.title = model.title
        self.navigationController?.pushViewController(vcClass, animated: true)
    }
}
