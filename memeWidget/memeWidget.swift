import WidgetKit
import SwiftUI
import FirebaseStorage

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image: Image(uiImage: UIImage(named: "sleepIn")!))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), image: Image(uiImage: UIImage(named: "sleepIn")!))
        completion(entry)
    }
    
    // Function to fetch images from Firebase Storage and store them in UserDefaults
    func fetchAndStoreImages() {
        let storageRef = Storage.storage().reference(withPath: "memes")
        
        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing files in directory: \(error.localizedDescription)")
                return
            }
            
            guard let result = result else { return }
            
            var imagesData: [Data] = []
            let dispatchGroup = DispatchGroup()
            
            for item in result.items {
                dispatchGroup.enter()
                
                item.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                    } else if let data = data {
                        imagesData.append(data)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // Store only the latest 10 images
                let recentImagesData = Array(imagesData.prefix(10))
                UserDefaults.standard.set(recentImagesData, forKey: "widgetImages")
                print("Yo")
                print(recentImagesData)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        fetchAndStoreImages()
        
        let images = fetchImagesFromUserDefaults()
        print(images)
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        // Create entries for every 10 seconds
        for index in 0..<images.count {
            let entryDate = Calendar.current.date(byAdding: .second, value: index * 10, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, image: images[index])
            entries.append(entry)
        }
        
        // Refresh the widget at the end of the timeline
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func fetchImagesFromUserDefaults() -> [Image] {
        guard let imageDataArray = UserDefaults.standard.array(forKey: "widgetImages") as? [Data] else {
            return []
        }
        return imageDataArray.compactMap { Image(uiImage: UIImage(data: $0) ?? UIImage()) }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: Image
}

struct memeWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        GeometryReader { geometry in
            entry.image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .containerBackground(Color("WidgetBackground"), for: .widget) // Set widget background color
        }
    }
}

struct memeWidget: Widget {
    let kind: String = "memeWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            memeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Meme Widget")
        .description("This widget displays memes fetched from UserDefaults.")
    }
}

struct memeWidget_Previews: PreviewProvider {
    static var previews: some View {
        memeWidgetEntryView(entry: SimpleEntry(date: Date(), image: Image(uiImage: UIImage(named: "sleepIn")!)))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
