//
//  CommentTableViewCell.swift
//  Dem
//
//  Created by Vishnu Prem on 01/07/22.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var commentTimeLbl: UILabel!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
