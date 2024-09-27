//
//  FeedViewController.swift
//  MemeGenerator
//
//  Created by Pattiya Yiadram on 29/8/24.
//
import Foundation
import UIKit
import Alamofire
import FirebaseStorage
import SwiftUI

struct MemeImage {
    let image: UIImage
    let createdAt: Date?
}

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var memeResponse: MemeTemplates? = nil
    var imagesArray: [MemeImage] = []
    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .black // Set the background color to black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Set the title color to white
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Set the large title color to white
        
        // Apply the appearance to the navigation bar for both standard and scroll edge
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // Enable large titles if desired
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.separatorStyle = .none
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        UILabel.appearance().font = UIFont(name: "Inter", size: 18)
        UIButton.appearance().titleLabel?.font = UIFont(name: "Inter", size: 16)
        UITextField.appearance().font = UIFont(name: "Inter", size: 18)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchImagesFromFirebase()
        print(imagesArray)
        tableView.reloadData()
    }
    
    func fetchImagesFromFirebase() {
        imagesArray.removeAll()
        tableView.reloadData()
        
        // Reference to the directory in Firebase Storage containing images
        let storageRef = Storage.storage().reference(withPath: "memes") // Specify the correct path
        
        // List all images in the directory
        storageRef.listAll { [weak self] (result, error) in
            if let error = error {
                print("Error listing files in directory: \(error.localizedDescription)")
                return
            }
            guard let result = result else { return }
            
            // Dispatch group to track when all metadata and images are fetched
            let dispatchGroup = DispatchGroup()
            
            // Loop through each item in the directory
            for item in result.items {
                dispatchGroup.enter() // Enter the group for each image
                
                // Fetch metadata for each image
                item.getMetadata { metadata, error in
                    if let error = error {
                        print("Error fetching metadata: \(error.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    // Extract the creation date from metadata
                    let createdAt = metadata?.timeCreated
                    
                    // Download the image data
                    item.getData(maxSize: 4 * 1024 * 1024) { [weak self] (data, error) in
                        if let error = error {
                            print("Error downloading image: \(error.localizedDescription)")
                        } else if let data = data, let image = UIImage(data: data) {
                            // Create a MemeImage object with the image and its creation date
                            let memeImage = MemeImage(image: image, createdAt: createdAt)
                            
                            self?.imagesArray.append(memeImage)
                        }
                        dispatchGroup.leave() // Leave the group after image and metadata are processed
                    }
                }
            }
            
            // Wait for all images and metadata to be fetched
            dispatchGroup.notify(queue: .main) {
                // Sort imagesArray by createdAt date
                self?.imagesArray.sort(by: { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) })
                
                // Reload table view or collection view after sorting images
                self?.tableView.reloadData() // or collectionView.reloadData()
            }
        }
    }


    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedcell", for: indexPath) as! FeedCell
                
        cell.memeImage.image = self.imagesArray[indexPath.row].image
        print(self.imagesArray[indexPath.row].createdAt!)
        // Assuming createdAt is of type Date
        if let createdAtDate = self.imagesArray[indexPath.row].createdAt {
            let timeAgo = timeAgoSinceDate(createdAtDate, numericDates: true)
            cell.dateCreatedLabel.text = "\(timeAgo)"
        }

        
        return cell
    }

    // Function to convert date to "time ago" format
    func timeAgoSinceDate(_ date: Date, numericDates: Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: now)
        
        let locale = Locale.current
        let languageCode = locale.language.languageCode?.identifier ?? "en"
print(languageCode)
        let timeAgoStrings: [String: String] = [
            "year": languageCode == "th" ? "ปีที่ผ่านมา" : "year ago",
            "month": languageCode == "th" ? "เดือนที่ผ่านมา" : "month ago",
            "week": languageCode == "th" ? "สัปดาห์ที่ผ่านมา" : "week ago",
            "day": languageCode == "th" ? "วันที่ผ่านมา" : "day ago",
            "hour": languageCode == "th" ? "ชั่วโมงที่ผ่านมา" : "hour ago",
            "minute": languageCode == "th" ? "นาทีที่ผ่านมา" : "minute ago",
            "second": languageCode == "th" ? "วินาทีที่ผ่านมา" : "second ago",
            "justNow": languageCode == "th" ? "เพิ่งตอนนี้" : "Just now",
            "yesterday": languageCode == "th" ? "เมื่อวานนี้" : "Yesterday",
            "anHourAgo": languageCode == "th" ? "หนึ่งชั่วโมงที่ผ่านมา" : "An hour ago",
            "aMinuteAgo": languageCode == "th" ? "หนึ่งนาทีที่ผ่านมา" : "A minute ago"
        ]
        
        if let year = components.year, year >= 2 {
            return "\(year) \(timeAgoStrings["year"]!)"
        } else if let year = components.year, year >= 1 {
            return numericDates ? "1 \(timeAgoStrings["year"]!)" : "เมื่อปีที่แล้ว"
        } else if let month = components.month, month >= 2 {
            return "\(month) \(timeAgoStrings["month"]!)"
        } else if let month = components.month, month >= 1 {
            return numericDates ? "1 \(timeAgoStrings["month"]!)" : "เมื่อเดือนที่แล้ว"
        } else if let week = components.weekOfYear, week >= 2 {
            return "\(week) \(timeAgoStrings["week"]!)"
        } else if let week = components.weekOfYear, week >= 1 {
            return numericDates ? "1 \(timeAgoStrings["week"]!)" : "สัปดาห์ที่แล้ว"
        } else if let day = components.day, day >= 2 {
            return "\(day) \(timeAgoStrings["day"]!)"
        } else if let day = components.day, day >= 1 {
            return numericDates ? "1 \(timeAgoStrings["day"]!)" : timeAgoStrings["yesterday"]!
        } else if let hour = components.hour, hour >= 2 {
            return "\(hour) \(timeAgoStrings["hour"]!)"
        } else if let hour = components.hour, hour >= 1 {
            return numericDates ? "1 \(timeAgoStrings["hour"]!)" : timeAgoStrings["anHourAgo"]!
        } else if let minute = components.minute, minute >= 2 {
            return "\(minute) \(timeAgoStrings["minute"]!)"
        } else if let minute = components.minute, minute >= 1 {
            return numericDates ? "1 \(timeAgoStrings["minute"]!)" : timeAgoStrings["aMinuteAgo"]!
        } else if let second = components.second, second >= 3 {
            return "\(second) \(timeAgoStrings["second"]!)"
        } else {
            return timeAgoStrings["justNow"]!
        }
    }




    
    @IBAction func saveButtonClicked(_ sender: Any) {
        // Check if the sender is a button and find its superview (the cell)
        if let button = sender as? UIButton,
           let cell = button.superview?.superview as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            
            // Get the image for the corresponding indexPath from your images array
            let memeImage = imagesArray[indexPath.row].image
            
            // Save the image to Photos
            UIImageWriteToSavedPhotosAlbum(memeImage, nil, nil, nil)
            print("Image saved successfully!")
            
            // Show a confirmation alert
            let alert = UIAlertController(title: "Image", message: "Image saved successfully!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            print("Failed to identify the cell.")
        }
    }


}
