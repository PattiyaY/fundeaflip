//
//  DataProvider.swift
//  MemeGenerator
//
//  Created by Pattiya Yiadram on 9/9/24.
//

import Alamofire
import Firebase
import FirebaseStorage
import Foundation
// Array of image names (adjust to match your images)
var IMAGES_NAMES: [MemeImage] = []
//"sleepIn", "2025meme"

struct MemeImage {
    let image: UIImage
}

class DataProvider {
    static func fetchImagesFromFirebase(completion: @escaping () -> Void) {
        IMAGES_NAMES.removeAll()
        let storageRef = Storage.storage().reference(withPath: "memes")

        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing files in directory: \(error.localizedDescription)")
                return
            }

            guard let result = result else { return }

            for item in result.items {
                item.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                    } else if let data = data, let image = UIImage(data: data) {
                        let memeImage = MemeImage(image: image)
                        IMAGES_NAMES.append(memeImage)

                        if let imageData = image.pngData() {
                            var storedImagesData = UserDefaults.standard.array(forKey: "storedImages") as? [Data] ?? []
                            storedImagesData.append(imageData)
                            UserDefaults.standard.set(storedImagesData, forKey: "storedImages")
                        }
                    }
                }
            }

            // Call completion handler after fetching images
            completion()
        }
    }
}

