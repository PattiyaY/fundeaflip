import UIKit

class MemeTemplatesCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    static let identifier: String = "MemeTemplatesCollectionViewCell"
    
    func configure(urlString: String) {
            guard let url = URL(string: urlString) else {
                imageView.image = UIImage(named: "placeholder")
                return
            }
            
            // Clear current image
            imageView.image = nil
            
            // Fetch image data
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(named: "placeholder")
                    }
                }
            }.resume()
        }
}
