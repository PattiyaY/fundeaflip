//
//  FeedViewController.swift
//  MemeGenerator
//
//  Created by Pattiya Yiadram on 29/8/24.
//

import UIKit
import Alamofire
import FirebaseStorage

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
//        return memeResponse?.data.memes.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedcell", for: indexPath) as! FeedCell
                
        cell.memeImage.image = self.imagesArray[indexPath.row].image
        print(self.imagesArray[indexPath.row].createdAt!)
        cell.dateCreatedLabel.text = "created :  \(self.imagesArray[indexPath.row].createdAt!)"
        
        return cell
    }

    
    @IBAction func saveButtonClicked(_ sender: Any) {
        // Get the first visible indexPath (image currently at the top of the table)
        if let firstVisibleIndexPath = tableView.indexPathsForVisibleRows?.first{
            // Get the image from the imagesArray at that index
            let memeImage = imagesArray[firstVisibleIndexPath.row].image
            
            // Save the visible image to Photos
            UIImageWriteToSavedPhotosAlbum(memeImage, nil, nil, nil)
            print("Image saved successfully!")
        } else {
            print("No visible image found.")
        }
    }

}
