//
//  SpeechController.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2022/10/27.
//

import UIKit
import AVFoundation

enum VoiceLanguage: String {
    case cn = "zh-Hans"
    case en = "en-US"
}

private let cnText = "春种一粒粟，秋收万颗子。四海无闲田，农夫犹饿死。锄禾日当午，汗滴禾下土。谁知盘中餐，粒粒皆辛苦。"
private let enText = "How are you? I'm fine.Thank you."
class SpeechController: UIViewController {
    /// 语音实例
    lazy var synthesizer = AVSpeechSynthesizer()
    // 语种
    var language: VoiceLanguage = .cn
    var text = cnText
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.center = self.view.center
        button.setTitle("播放", for: .normal)
        button.addTarget(self, action: #selector(speechEvent), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        self.view.addSubview(button)
    }
    
    

    @objc func speechEvent() {
        let arc = arc4random() % 2
        if arc == 0 {
            language = .cn
            text = cnText
        } else {
            language = .en
            text = enText
        }
        
        speech()
    }
    
    // 阅读
    func speech() {
        // 语音内容实例
        let utterance = AVSpeechUtterance(string: text)
        // 语种
        utterance.voice = AVSpeechSynthesisVoice(language: language.rawValue)
        // 播放
        synthesizer.speak(utterance)
    }
    
}
