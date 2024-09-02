//
//  FeedViewController.swift
//  MemeGenerator
//
//  Created by Pattiya Yiadram on 29/8/24.
//

import UIKit
import Alamofire

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var memeResponse: MemeResponse? = nil
    
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
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Fetch memes from the API
        AF.request("https://api.imgflip.com/get_memes").responseDecodable(of: MemeResponse.self) { response in
            switch response.result {
            case .success(let responseData):
                self.memeResponse = responseData
                /*print("Successfully fetched data: \(self.memeResponse!)")*/ // Prints the fetched data
                self.tableView.reloadData()
            case .failure(let error):
                print("Error fetching memes: \(error)")
                
                if let data = response.data,
                   let errorString = String(data: data, encoding: .utf8) {
                    print("Response data: \(errorString)")
                }
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memeResponse?.data.memes.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedcell", for: indexPath) as! FeedCell
        
        if let meme = memeResponse?.data.memes[indexPath.row] {
            // Debugging point: Check if meme properties are correctly set
            print("Configuring cell for meme: \(meme.name)")

            // Set the ID or any other text-based data
            cell.dateCreatedLabel.text = "created :  \(meme.id)"
            
            // Load the image from the URL asynchronously
            if let url = URL(string: meme.url) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.memeImage.image = image
                        }
                    } else if let error = error {
                        print("Error loading image: \(error)")
                    }
                }.resume()
            } else {
                print("Invalid URL: \(meme.url)")
            }
        } else {
            print("Meme data is nil for row \(indexPath.row)")
        }
        
        return cell
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
    }
    
    
    
    

}
