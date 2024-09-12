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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchImagesFromFirebase()
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

                // Loop through each item in the directory
                for item in result.items {
                    // Fetch metadata for each image
                    item.getMetadata { metadata, error in
                        if let error = error {
                            print("Error fetching metadata: \(error.localizedDescription)")
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
                                
                                // Reload table view or collection view after adding new images
                                DispatchQueue.main.async {
                                    self?.tableView.reloadData() // or collectionView.reloadData()
                                }
                            }
                        }
                    }
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

        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        } else if let year = components.year, year >= 1 {
            return numericDates ? "1 year ago" : "Last year"
        } else if let month = components.month, month >= 2 {
            return "\(month) months ago"
        } else if let month = components.month, month >= 1 {
            return numericDates ? "1 month ago" : "Last month"
        } else if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        } else if let week = components.weekOfYear, week >= 1 {
            return numericDates ? "1 week ago" : "Last week"
        } else if let day = components.day, day >= 2 {
            return "\(day) days ago"
        } else if let day = components.day, day >= 1 {
            return numericDates ? "1 day ago" : "Yesterday"
        } else if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        } else if let hour = components.hour, hour >= 1 {
            return numericDates ? "1 hour ago" : "An hour ago"
        } else if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        } else if let minute = components.minute, minute >= 1 {
            return numericDates ? "1 minute ago" : "A minute ago"
        } else if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        } else {
            return "Just now"
        }
    }


    
    @IBAction func saveButtonClicked(_ sender: Any) {
        // Get the first visible indexPath (image currently at the top of the table)
        if let firstVisibleIndexPath = tableView.indexPathsForVisibleRows?.first{
            // Get the image from the imagesArray at that index
            let memeImage = imagesArray[firstVisibleIndexPath.row].image
            
            // Save the visible image to Photos
            UIImageWriteToSavedPhotosAlbum(memeImage, nil, nil, nil)
            print("Image saved successfully!")
            let alert = UIAlertController(title: "Image", message: "Image saved successfully!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)

        } else {
            print("No visible image found.")
        }
    }

}
