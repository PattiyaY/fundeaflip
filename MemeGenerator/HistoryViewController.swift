//
//  HistoryViewController.swift
//  MemeGenerator
//
//  Created by Pattiya Yiadram on 29/8/24.
//

import UIKit

class HistoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = .black // Set the background color to black
                appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Set the title color to white
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Set the large title color to white
                
                // Apply the appearance to the navigation bar for both standard and scroll edge
                navigationController?.navigationBar.standardAppearance = appearance
                navigationController?.navigationBar.scrollEdgeAppearance = appearance
                
                // Enable large titles if desired
                navigationController?.navigationBar.prefersLargeTitles = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
