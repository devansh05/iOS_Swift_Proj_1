//
//  HCCartScreenTVC.swift
//   
//
//    29/05/19.
//  Copyright © 2019  . All rights reserved.
//

import UIKit

class HCCartScreenTVC: UITableViewCell {
    @IBOutlet weak var view_Heading:UIView!
    @IBOutlet weak var img_Product:UIImageView!
    @IBOutlet weak var lbl_ProductTitle:UILabel!
    @IBOutlet weak var lbl_ProductDesc:UILabel!
    @IBOutlet weak var btn_QuantityValue:UIButton!
    @IBOutlet weak var btn_Minus:UIButton!
    @IBOutlet weak var btn_Remove:UIButton!
    @IBOutlet weak var btn_Plus:UIButton!
    @IBOutlet weak var lbl_Price:UILabel!
    @IBOutlet weak var lbl_TotalPrice:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
