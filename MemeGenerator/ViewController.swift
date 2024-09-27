import UIKit
import UniformTypeIdentifiers
import Alamofire
import Firebase
import MobileCoreServices
import UserNotifications
import FirebaseStorage

var MEME_TEMPLATES = [Meme]() // Global variable
class ViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet var collectionView: UICollectionView!
    var selectedImage: UIImage?
    var imagePickerController: UIImagePickerController?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkForPermission()
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
//        fetchAndStoreImages()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        getTemplate {
            self.collectionView.reloadData()
        }
        
        UILabel.appearance().font = UIFont(name: "Inter", size: 18)
        UIButton.appearance().titleLabel?.font = UIFont(name: "Inter", size: 16)
        UITextField.appearance().font = UIFont(name: "Inter", size: 18)

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
    
    func checkForPermission(){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                print("Permissions granted")
                self.dispatchNotification()
            case .denied:
                print("Permissions denied")
                return
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error  in
                    if didAllow {
                        print("User granted permission")
                        self.dispatchNotification()
                    }
                }
            default:
                return
            }
        }
    }

    func dispatchNotification() {
        let identifier = "Create meme notification"
        let title = "Create your funny meme!"
        let body = "Time to share creativity to the world!"
        let isDaily = true
        let hour = 9 // 9:00 AM
        let minute = 0
        
        let notificationCenter = UNUserNotificationCenter.current()

        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // Configure the date components for 9:00 AM every day
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        // Create the trigger for daily notifications at 9:00 AM
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
         
        // Testing : Set trigger time to 1 minute from now
        // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: isDaily) // 60 seconds = 1 minute

        // Create notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Remove old notifications and add the new one
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                return
//                print("Notification scheduled for 1 minute from now.")
            }
        }
    }

    @IBAction func selectImageButton(_ sender: Any) {
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        let locale = Locale.current
        let languageCode = locale.language.languageCode?.identifier ?? "en"

        if languageCode == "th" {
            let alert = UIAlertController(title: NSLocalizedString("select_source_type", tableName: nil, bundle: .main, value: "เลือกแหล่งที่มา", comment: "Title for source selection alert"), message: nil, preferredStyle: .actionSheet)

            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                alert.addAction(UIAlertAction(title: NSLocalizedString("camera_title", tableName: nil, bundle: .main, value: "กล้อง", comment: "Title for the camera action"), style: .default, handler: { _ in
                    self.presentImagePicker(source: .camera)
                }))
            }

            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                alert.addAction(UIAlertAction(title: NSLocalizedString("photo_library_title", tableName: nil, bundle: .main, value: "รูปภาพ", comment: "Title for the photo library action"), style: .default, handler: { _ in
                    self.presentImagePicker(source: .photoLibrary)
                }))
            }

            alert.addAction(UIAlertAction(title: NSLocalizedString("files_title", tableName: nil, bundle: .main, value: "ไฟล์", comment: "Title for the files action"), style: .default, handler: { _ in
                self.presentDocumentPicker()
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_action", tableName: nil, bundle: .main, value: "ยกเลิก", comment: "Title for the cancel action"), style: .cancel, handler: nil))

            self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: NSLocalizedString("select_source_type", tableName: nil, bundle: .main, value: "Select Source Type", comment: "Title for source selection alert"), message: nil, preferredStyle: .actionSheet)

            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                alert.addAction(UIAlertAction(title: NSLocalizedString("camera_title", tableName: nil, bundle: .main, value: "Camera", comment: "Title for the camera action"), style: .default, handler: { _ in
                    self.presentImagePicker(source: .camera)
                }))
            }

            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                alert.addAction(UIAlertAction(title: NSLocalizedString("photo_library_title", tableName: nil, bundle: .main, value: "Photos", comment: "Title for the photo library action"), style: .default, handler: { _ in
                    self.presentImagePicker(source: .photoLibrary)
                }))
            }

            alert.addAction(UIAlertAction(title: NSLocalizedString("files_title", tableName: nil, bundle: .main, value: "Files", comment: "Title for the files action"), style: .default, handler: { _ in
                self.presentDocumentPicker()
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_action", tableName: nil, bundle: .main, value: "Cancel", comment: "Title for the cancel action"), style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
    }

    
    private func presentDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.image]) // Only allow images to be selected
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true, completion: nil)
    }

    func getTemplate(completed: @escaping () -> ()) {
        let url = "https://api.imgflip.com/get_memes"
        AF.request(url).responseDecodable(of: MemeTemplates.self) { response in
            switch response.result {
            case .success(let memeTemplates):
                MEME_TEMPLATES = memeTemplates.data.memes // Access the array from the decoded response
                DispatchQueue.main.async {
                    completed()
                }
            case .failure(let error):
                print("Failed to fetch meme templates: \(error)")
            }
        }
    }

    
    private func presentImagePicker(source: UIImagePickerController.SourceType) {
        guard let controller = self.imagePickerController else { return }
        controller.sourceType = source
        self.present(controller, animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        
        if selectedURL.startAccessingSecurityScopedResource() {
            defer { selectedURL.stopAccessingSecurityScopedResource() }

            do {
                let imageData = try Data(contentsOf: selectedURL)
                if let image = UIImage(data: imageData) {
                    self.selectedImage = image
                    self.showNextPageWithImage(image)
                } else {
                    print("Failed to create image from data.")
                }
            } catch {
                print("Error loading image data: \(error)")
            }
        } else {
            print("Permission denied to access the file.")
        }
    }
    
    private func loadImage(from fileURL: URL) {
        do {
            let imageData = try Data(contentsOf: fileURL)
            if let image = UIImage(data: imageData) {
                self.selectedImage = image
                self.showNextPageWithImage(image)
            } else {
                print("Failed to create image from data.")
            }
        } catch {
            print("Error loading image data: \(error)")
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let memePage = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "memePage") as! MemeViewController
        let meme = MEME_TEMPLATES[indexPath.row] // Use global variable

        memePage.title = "\(meme.name)"
        memePage.memeData = meme
        
        self.navigationController?.pushViewController(memePage, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MEME_TEMPLATES.count // Use global variable
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeTemplatesCollectionViewCell.identifier, for: indexPath) as! MemeTemplatesCollectionViewCell
        let meme = MEME_TEMPLATES[indexPath.row] // Use global variable
        cell.configure(urlString: meme.url)
        return cell
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return imagePickerControllerDidCancel(picker)
        }
        
        self.selectedImage = image
        
        picker.dismiss(animated: true) {
            picker.delegate = nil
            self.imagePickerController = nil
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
        let locale = Locale.current
        let languageCode = locale.language.languageCode?.identifier ?? "en"

//        print(languageCode)
        
        if languageCode == "th" {
            memePage.title = "ภาพที่คุณเลือก"
            memePage.selectedImage = image
        } else {
            memePage.title = "Your Selected Image"
            memePage.selectedImage = image
        }
        
        self.navigationController?.pushViewController(memePage, animated: true)
    }
}
