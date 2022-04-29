//
//  ContentView.swift
//  CountGroud
//
//  Created by sofent on 2022/4/29.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    let img1url = "Images/grape"
    let img2url = "Images/banana"
    let img3url = "Images/peach"
    let img4url = "Images/kiwi"
    
    var body: some View {
        HStack {
            
            VStack {
                DragableImage(name: img1url)
                
                DragableImage(name: img3url)
            }
            
            VStack {
                DragableImage(name: img2url)
                
                DragableImage(name: img4url)
            }
            
            DroppableArea()
        }.padding(40)
    }
    
    struct DragableImage: View {
        let name: String
        
        var body: some View {
            Image(uiImage: name != "" ? UIImage(named: name)! : UIImage())
                .resizable()
                .frame(width: 50, height: 50)
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
        @State private var images: [ImageModel] = []
        @State private var active = 0
        
        var body: some View {
            let dropDelegate = MyDropDelegate(images: $images, active: $active)
            
            return HStack{ GeometryReader { geometry in
                ZStack {
                ForEach(images) { model in
                    let img = Image( uiImage: model.name != "" ? UIImage(named: model.name)! : UIImage())
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                     Rectangle()
                        .fill(Color.clear)
                        .frame(width: 50, height: 50)
                        .overlay(img).position(model.pos)
                }
                
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color.gray)
                .onDrop(of: [UTType.text], delegate: dropDelegate)
            }
                Text("\(images.count)").font(.title)
            
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
        @Binding var active: Int
        
        func validateDrop(info: DropInfo) -> Bool {
            return info.hasItemsConforming(to: [UTType.text])
        }
        
        func dropEntered(info: DropInfo) {
           // Sound(named: "Morse")?.play()
        }
        
        func performDrop(info: DropInfo) -> Bool {
           // Sound(named: "Submarine")?.play()
            
            if let item = info.itemProviders(for: [UTType.text]).first {
    
                item.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (strData, error) in
                    DispatchQueue.main.async {
                        
                        if let strData = strData as? Data {
                            let model = ImageModel(id: images.count+1, pos:info.location,name:String(data: strData, encoding: .utf8 )!)
                            self.images.append(model)

                        }
                    }
                }
                
                return true
                
            } else {
                return false
            }

        }
        
        func dropUpdated(info: DropInfo) -> DropProposal? {
            self.active = getGridPosition(location: info.location)
                        
            return nil
        }
        
        func dropExited(info: DropInfo) {
            self.active = 0
        }
        
        func getGridPosition(location: CGPoint) -> Int {
            if location.x > 150 && location.y > 150 {
                return 4
            } else if location.x > 150 && location.y < 150 {
                return 3
            } else if location.x < 150 && location.y > 150 {
                return 2
            } else if location.x < 150 && location.y < 150 {
                return 1
            } else {
                return 0
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
