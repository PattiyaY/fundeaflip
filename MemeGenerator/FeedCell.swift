//
//  FeedCell.swift
//  MemeGenerator
//
//  Created by Pattiya Yiadram on 29/8/24.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var memeImage: UIImageView!
    @IBOutlet weak var dateCreatedLabel: UILabel!
    @IBOutlet weak var bgView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        bgView.layer.cornerRadius = 20
    }

}
