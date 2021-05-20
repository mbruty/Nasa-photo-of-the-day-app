//
//  ContentView.swift
//  nasa-api
//
//  Created by Mike Bruty on 20/05/2021.
//

import SwiftUI
var base_url = "https://api.nasa.gov/planetary/apod?api_key=your_key_here";
struct ContentView: View {
    @State var items = [Item]();
    
    var body: some View {
        NavigationView{
            
            VStack {
                // 2.
                VStack(alignment: .leading) {
                    // 3.
                    List(items, id: \.url) { item in
                        NavigationLink(destination: DetailedView(item: item)){
                            TableItem(title: item.name, url: item.url)
                        }
                    }
                }
            }
            .navigationTitle("NASA Photo of the day")
            .font(.title2)
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        print(base_url + "&count=20")
        guard let url = URL(string: base_url + "&count=20" ) else {
                print("oof")
                return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let data = data {
                if let decoded = try? JSONDecoder().decode([Photo].self ,from: data) {
                    var list = [Item]()
                    for photo in decoded {
                        list.append(
                            Item(name: photo.title, date: photo.date, url: photo.url)
                        )
                    }
                    DispatchQueue.main.async {
                        self.items = list
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unkown error")")
        }.resume()
    }
}

struct TableItem: View {
    var title: String
    var url: String
    @State var image = UIImage()
    
    var body: some View {
        HStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
            Text(title)
        }
        .onAppear(perform: getImage)
    }
    func getImage() {
        print("Here")
        guard let url = URL(string: url) else {
            print("oof")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    image = UIImage(data: data)!
                }
                return
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unkown error")")
        }.resume()
    }
}

struct DetailedView: View {
    var item: Item
    @State var image = UIImage()
    var body: some View {
        VStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width)
            Text(item.name)
            Text(item.date)
        }
        .frame(alignment: .top)
        .onAppear(perform: getImage)
    }
    
    func getImage() {
        guard let url = URL(string: item.url) else {
            print("oof")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request){ data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    image = UIImage(data: data)!
                }
                return
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unkown error")")
        }.resume()
    }

    
    
}



struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
        ContentView()
    }
}

struct Item {
    var name: String
    var image: UIImage?
    var date: String
    var url: String
}

struct Photo: Codable {
    let copyright: String?
    let date, explanation: String
    let hdurl: String
    let mediaType: MediaType
    let serviceVersion: ServiceVersion
    let title: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case copyright, date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url
    }
}

enum MediaType: String, Codable {
    case image = "image"
}

enum ServiceVersion: String, Codable {
    case v1 = "v1"
}

typealias Photos = [Photo]

