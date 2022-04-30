//
//  AppDelegate.swift
//  CountGround
//
//  Created by 衡阵 on 2022/4/30.
//

import UIKit
class AppDelegate: NSObject, UIApplicationDelegate {
    var interfaceOrientations:UIInterfaceOrientationMask = .landscape{
        didSet{
            //强制设置成竖屏
            if interfaceOrientations == .portrait{
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,
                                          forKey: "orientation")
            }
            //强制设置成横屏
            else if !interfaceOrientations.contains(.portrait){
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue,
                                          forKey: "orientation")
            }
        }
    }
    //返回当前界面支持的旋转方向
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor
                     window: UIWindow?)-> UIInterfaceOrientationMask {
        return interfaceOrientations
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
