//
//  ElementCollectionViewCell.swift
//  Shadows
//
//  Created by Anna Miksiuk on 20.03.2018.
//  Copyright © 2018 Anna Miksiuk. All rights reserved.
//

import UIKit

class ElementCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var elementImageView: ElementImageView!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func configure(nameElement: String) {
    guard let elementImage = UIImage(named: nameElement) else {
      return
    }
    elementImageView.name = nameElement
    elementImageView.image = elementImage
    layer.cornerRadius = 10
    layer.masksToBounds = true
    layer.borderWidth = 0
  }
}
