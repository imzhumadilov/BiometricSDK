//
//  ScreenRecordingService.swift
//  BioSDK
//
//  Created by Ilyas Zhumadilov on 27.02.2023.
//

import UIKit

protocol ScreenRecordingServiceDelegate: AnyObject {
    func screenRecordingStart()
    func screenRecordingFinish()
}

class ScreenRecordingService {
    
    static let shared = ScreenRecordingService()
    var delegate: ScreenRecordingServiceDelegate?
    private var lastStatus = false
    
    func configureDetecting(delegate: ScreenRecordingServiceDelegate? = nil) {
        self.delegate = delegate
        NotificationCenter.default.addObserver(self, selector: #selector(didScreenRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    @objc
    private func didScreenRecording() {
        if UIScreen.main.isCaptured {
            self.delegate?.screenRecordingStart()
        } else if self.lastStatus {
            self.delegate?.screenRecordingFinish()
        }
        self.lastStatus = UIScreen.main.isCaptured
    }
    
    public func applicationWillResignActive() {
        self.didScreenRecording()
    }

    public func applicationDidBecomeActive() {
        self.didScreenRecording()
    }
}
