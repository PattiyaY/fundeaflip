import UIKit

class MemeViewController: UIViewController {

    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var memeImage: UIImageView!
    
    var memeData: Meme? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let urlString = memeData?.url {
            loadImageUrl(urlString: urlString)
        } else {
            memeImage.image = UIImage(named: "placeholder")
        }
        
        memeImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func addTextField(_ sender: Any) {
        textFieldAppearOnCenter(posX: 100, posY: 100)
    }
    
    func textFieldAppearOnCenter(posX: Double, posY: Double) {
        let textView = UITextView(frame: CGRect(x: posX, y: posY, width: 150, height: 30))
        textView.delegate = self
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.isScrollEnabled = false

        // Add pan gesture recognizer for dragging
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        textView.addGestureRecognizer(panGesture)

        let size: CGFloat = 20

        // Create a remove icon
        let removeButton = UIButton(frame: CGRect(x: -7, y: -7, width: size, height: size))
        removeButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        removeButton.addTarget(self, action: #selector(handleRemoveTap(_:)), for: .touchUpInside)
        textView.addSubview(removeButton)

        // Create a resize icon
        let resizeButton = UIButton(frame: CGRect(x: textView.frame.width - size, y: textView.frame.height - size, width: size, height: size))
        resizeButton.setImage(UIImage(systemName: "arrow.up.left.and.down.right.magnifyingglass"), for: .normal)
        
        // Attach a UIPanGestureRecognizer to resize the textView
        let resizePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleResize(_:)))
        resizeButton.addGestureRecognizer(resizePanGesture)

        textView.addSubview(resizeButton)

        // Set autoresizing masks to reposition on resizing
        resizeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        removeButton.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]

        // Add the textView to the main view
        memeImage.addSubview(textView)
        
        textView.becomeFirstResponder()
    }


    @objc func handleRemoveTap(_ sender: UIButton) {
        guard let closeView = sender.superview as? UITextView else { return }
        closeView.removeFromSuperview()
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let textView = sender.view as? UITextView else { return }

        let translation = sender.translation(in: memeImage)
        textView.center = CGPoint(x: textView.center.x + translation.x, y: textView.center.y + translation.y)
        sender.setTranslation(.zero, in: memeImage)
    }
    
    @objc func handleResize(_ sender: UIPanGestureRecognizer) {
        guard let resizeButton = sender.view, let textView = resizeButton.superview as? UITextView else { return }
        
        let translation = sender.translation(in: textView)
        var newWidth = textView.frame.width + translation.x
        newWidth = max(newWidth, 50)
        
        textView.frame.size = CGSize(width: newWidth, height: textView.frame.height)
        sender.setTranslation(.zero, in: textView)
    }
    
    @IBAction func saveMeme(_ sender: UIButton) {
        guard let combinedImage = renderImageWithText() else {
            print("Failed to create image.")
            return
        }
        
        // Save the combined image to Photos or handle as needed
        UIImageWriteToSavedPhotosAlbum(combinedImage, nil, nil, nil)
        print("Image saved successfully!")
    }

    func renderImageWithText() -> UIImage? {
        guard let image = memeImage.image else { return nil }
        
        // Calculate the aspect ratio of the image
        let imageSize = image.size
        let imageViewSize = memeImage.bounds.size
        let imageAspectRatio = imageSize.width / imageSize.height
        let viewAspectRatio = imageViewSize.width / imageViewSize.height
        
        var drawRect: CGRect
        
        if imageAspectRatio > viewAspectRatio {
            // Image is wider than the view
            let height = imageViewSize.width / imageAspectRatio
            drawRect = CGRect(x: 0, y: (imageViewSize.height - height) / 2, width: imageViewSize.width, height: height)
        } else {
            // Image is taller than the view
            let width = imageViewSize.height * imageAspectRatio
            drawRect = CGRect(x: (imageViewSize.width - width) / 2, y: 0, width: width, height: imageViewSize.height)
        }
        
        // Begin graphics context with the size of the UIImageView
        UIGraphicsBeginImageContextWithOptions(memeImage.bounds.size, false, 0.0)
        
        // Draw the base image with the correct aspect ratio
        image.draw(in: drawRect)
        
        // Draw each subview (UITextView) as text on the image
        for subview in memeImage.subviews {
            if let textView = subview as? UITextView {
                let text = textView.text ?? ""
                
                // Convert textView's frame to match the aspect-ratio-adjusted image
                let textRect = textView.convert(textView.bounds, to: memeImage)
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: textView.font ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: textView.textColor ?? UIColor.black
                ]
                
                // Draw text in the calculated rect
                text.draw(in: textRect, withAttributes: textAttributes)
            }
        }
        
        // Create the combined image
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
    }


    
    func loadImageUrl(urlString: String) {
        guard let url = URL(string: urlString) else {
            memeImage.image = UIImage(named: "placeholder")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width, height: image.size.height))
                                        let textInImage = renderer.image {(context) in
                                            image.draw(at: .zero)
                                        }
                                        self.memeImage.image = textInImage
                }
            } else {
                DispatchQueue.main.async {
                    self.memeImage.image = UIImage(named: "placeholder")
                }
            }
        }.resume()
    }
}

extension MemeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeight(textView)
    }
    
    func adjustTextViewHeight(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        var newFrame = textView.frame
        newFrame.size.height = estimatedSize.height
        textView.frame = newFrame
    }
}
