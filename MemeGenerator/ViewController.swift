import UIKit
import Alamofire
import Firebase

class ViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    var selectedImage: UIImage?

    var memeTemplates = [Meme]()
    var imagePickerController: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getTemplate {
            self.collectionView.reloadData()
        }
    }

    @IBAction func selectImageButton(_ sender: Any) {
        imagePickerController = UIImagePickerController() // Initialize the Image Picker Controller
        imagePickerController?.delegate = self
        
        let alert = UIAlertController(title: "Select Source Type", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.presentImagePicker(source: .camera)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.presentImagePicker(source: .photoLibrary)
            }))
        }
        
//        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
//            alert.addAction(UIAlertAction(title: "Saved Albums", style: .default, handler: { _ in
//                self.presentImagePicker(source: .savedPhotosAlbum)
//            }))
//        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }

    func getTemplate(completed: @escaping () -> ()) {
        let url = "https://api.imgflip.com/get_memes"
        AF.request(url).responseDecodable(of: MemeTemplates.self) { response in
            switch response.result {
            case .success(let memeTemplate):
                self.memeTemplates = memeTemplate.data.memes
                DispatchQueue.main.async {
                    completed()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func presentImagePicker(source: UIImagePickerController.SourceType) {
        guard let controller = self.imagePickerController else { return }
        controller.sourceType = source
        self.present(controller, animated: true)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let memePage = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "memePage") as! MemeViewController
        let meme = memeTemplates[indexPath.row]

        memePage.title = "\(meme.name)"
        memePage.memeData = meme
        
        self.navigationController?.pushViewController(memePage, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memeTemplates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeTemplatesCollectionViewCell.identifier, for: indexPath) as! MemeTemplatesCollectionViewCell
        let meme = memeTemplates[indexPath.row]
        cell.configure(urlString: meme.url)
        return cell
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return imagePickerControllerDidCancel(picker)
        }
        
        self.selectedImage = image // Store the selected image
        
        picker.dismiss(animated: true) {
            picker.delegate = nil
            self.imagePickerController = nil
            
            // Navigate to the next page or perform the required action
            self.showNextPageWithImage(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            picker.delegate = nil
            self.imagePickerController = nil
        }
    }
    
    private func showNextPageWithImage(_ image: UIImage) {
        let memePage = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "memePage") as! MemeViewController
        memePage.title = "Your Selected Image"
        memePage.selectedImage = image // Pass the selected image to the next view controller
        
        self.navigationController?.pushViewController(memePage, animated: true)
    }
}

