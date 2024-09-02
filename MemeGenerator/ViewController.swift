import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var memeTemplates = [Meme]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        getTemplate {
            self.collectionView.reloadData()
        }
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
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let memePage = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "memePage") as! MemeViewController
        let meme = memeTemplates[indexPath.row]

        memePage.title = "\(meme.name)";
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
