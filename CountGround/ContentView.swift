//
//  ContentView.swift
//  CountGround
//
//  Created by 衡阵 on 2022/4/29.
//

import SwiftUI

struct ContentView : View{
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some View{
        NavigationView{
            VStack{
                NavigationLink("Count Ground", destination:  CountView()).padding()
                NavigationLink("Four Digit", destination:  FourDigitMinusView()).padding()
            }
            Text("Welcome")
        }
        .phoneOnlyStackNavigationView()
        .onAppear() {
            
            appDelegate.interfaceOrientations = [.landscapeLeft]
        }.onDisappear() {
            appDelegate.interfaceOrientations = .portrait
        }
    }
}


extension View {
    func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}
