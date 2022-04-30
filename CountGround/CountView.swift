//
//  ContentView.swift
//  CountGroud
//
//  Created by sofent on 2022/4/29.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct CountView: View {
    let img1url = "Images/banana"
    let img2url = "Images/grape"
    let img3url = "Images/peach"
    let img4url = "Images/kiwi"
    @State var showResult = false
    @State var images1 :[ImageModel] = []
    @State var images2 :[ImageModel] = []
   
    
    var body: some View {
        HStack {
            
            VStack {
                DragableImage(name: img1url)
                DragableImage(name: img2url)
                DragableImage(name: img3url)
                DragableImage(name: img4url)
            }
            .padding()
            .border(Color.orange)
            VStack{
                DroppableArea(images: $images1)
                Text("\(images1.count)").font(.title)
            }
            Text("+").font(.largeTitle)
            VStack{
                DroppableArea(images: $images2)
                Text("\(images2.count)").font(.title)
            }
            VStack{
                
                Text( showResult ? "\(images1.count+images2.count)":"?").font(.largeTitle)
                Button("ShowResult"){
                    showResult.toggle()
                }.padding()
                Button("Reset"){
                    images1.removeAll()
                    images2.removeAll()
                }.padding()
                
            }
        }.padding(40)
          
        
    }
    
    struct DragableImage: View {
        let name: String
        
        var body: some View {
            Image(uiImage: name != "" ? UIImage(named: name)! : UIImage())
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .padding(2)
                .overlay(Circle().strokeBorder(Color.black.opacity(0.1)))
                .shadow(radius: 3)
                .padding(4)
                .onDrag { return NSItemProvider(object: self.name as NSString) }
                
        }
    }
    struct ImageModel:Identifiable{
        var id: Int
        
        var pos: CGPoint
        var name: String
    }
    struct DroppableArea: View {
        @Binding var images: [ImageModel]
        @State private var showResult = false
        
        var body: some View {
            let dropDelegate = MyDropDelegate(images: $images)
            
            return HStack{ GeometryReader { geometry in
                ZStack {
                    ForEach(images.indices,id:\.self) { index in
                        let model = images[index]
                        let img = Image( uiImage: model.name != "" ? UIImage(named: model.name)! : UIImage())
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .padding(2)
                            .overlay(Circle().strokeBorder(Color.black.opacity(0.1)))
                            .shadow(radius: 3)
                            .padding(4)
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 50, height: 50)
                            .overlay(img).position(model.pos).onTapGesture(count:2){
                                images.remove(at: index)
                            }
                    }
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color(UIColor.systemBackground))
                .border(Color.gray)
                .onDrop(of: [UTType.text], delegate: dropDelegate)
            }
                
                
            }}
    }
    
    struct GridCell: View {
        let active: Bool
        let name: String?
        
        var body: some View {
            let img = Image( uiImage: name != nil ? UIImage(named: name!)! : UIImage())
                .resizable()
                .frame(width: 150, height: 150)
            
            return Rectangle()
                .fill(self.active ? Color.green : Color.clear)
                .frame(width: 150, height: 150)
                .overlay(img)
        }
    }
    
    struct MyDropDelegate: DropDelegate {
        @Binding var images: [ImageModel]
        
        func validateDrop(info: DropInfo) -> Bool {
            return info.hasItemsConforming(to: [UTType.text])
        }
        
        func dropEntered(info: DropInfo) {
            // Sound(named: "Morse")?.play()
        }
        
        func performDrop(info: DropInfo) -> Bool {
            // Sound(named: "Submarine")?.play()
            
            if let item = info.itemProviders(for: [UTType.text]).first {
                item.loadObject(ofClass: NSString.self){
                    (strData, error) in
                    if let strData = strData as? String {
                        let model = ImageModel(id: images.count+1, pos:info.location,name:strData)
                        self.images.append(model)
                        
                    }
                }
                
                return true
                
            } else {
                return false
            }
            
        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            
            return nil
        }
        
        func dropExited(info: DropInfo) {
            
        }
        
    }
}


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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CountView()
    }
}
