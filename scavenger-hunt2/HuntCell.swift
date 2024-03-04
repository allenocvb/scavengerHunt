//
//  HuntCell.swift
//  scavenger-hunt2
//
//  Created by Allen Odoom on 3/4/24.
//

import UIKit

class HuntCell: UITableViewCell {
    
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with hunt: Hunt) {
        // Update the titleLabel with the hunt's title
        titleLabel.text = hunt.title
        
        // Update the completedImageView based on whether the hunt is complete
        let completedImageName = hunt.isComplete ? "checkmark.circle.fill" : "circle"
        completedImageView.image = UIImage(systemName: completedImageName)
        
        // Optional: Use color to further indicate completion status
        completedImageView.tintColor = hunt.isComplete ? .systemGreen : .systemGray
    }
}


