//
//  ItemCell.swift
//  Game of Thrones
//
//  Created by Maarten Koe on 26/10/2021.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var houseImage: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageLeadHidden: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        houseImage.isHidden = true
    }
    
    func setHouseImage(regionName: String) {
        var urlString = ""
        imageLeadHidden?.isActive = false
        
        switch regionName {
            case "The North":
                urlString = "https://bit.ly/2Gcq0r4"
            case "The Vale":
                urlString = "https://bit.ly/34FAvws"
            case "The Riverlands":
                urlString = "https://bit.ly/3kJrIiP"
            case "Iron Islands":
                urlString = "https://bit.ly/3kJrIiP"
            case "The Westerlands":
                urlString = "https://bit.ly/2TAzjnO"
            case "The Reach":
                urlString = "https://bit.ly/2HSCW5N"
            case "Dorne":
                urlString = "https://bit.ly/2HOcavT"
            case "The Stormlands":
                urlString = "https://bit.ly/34F2sEC" 
            default:
                self.houseImage.isHidden = true
                return
        }
        
        let url = URL(string: urlString)
        
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.houseImage.image = UIImage(data: data!)
            }
        }
        
        houseImage.isHidden = false
    }
}
