//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Ahmed Essmat on 15/06/2021.
//

import UIKit

class SearchResultCell: UITableViewCell {

   
    @IBOutlet var name: UILabel!
    
    @IBOutlet var artistName: UILabel!
    @IBOutlet var artworkImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
