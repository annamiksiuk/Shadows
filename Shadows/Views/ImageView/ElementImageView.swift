//
//  ElementImageView.swift
//  Shadows
//
//  Created by Anna Miksiuk on 21.03.2018.
//  Copyright © 2018 Anna Miksiuk. All rights reserved.
//

import UIKit

class ElementImageView: UIImageView {
  
  var name: String!
  var originalImage: UIImage?
  
  init?(nameElement: String) {
    guard let elementImage = UIImage(named: nameElement) else {
      return nil
    }
    name = nameElement
    super.init(image: elementImage)
    contentMode = .scaleAspectFit
    isUserInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  init(element: ElementImageView) {
    super.init(frame: element.bounds)
    image = element.image
    name = element.name
    contentMode = element.contentMode
    isUserInteractionEnabled = element.isUserInteractionEnabled
  }
  
  func isEqual(element: ElementImageView) -> Bool {
    if name == element.name {
      return true
    }
    return false
  }
  
  func transformToShadow() {
    guard let original = image,
          let inputImage = CIImage(image: original),
          let filter = CIFilter(name: "CIExposureAdjust") else { return }
    filter.setValue(inputImage, forKey: "inputImage")
    filter.setValue(-10.0, forKey: "inputEV")
    guard let filteredImage = filter.outputImage else { return }
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) else { return }
    let outputImage = UIImage(cgImage: cgImage)
    originalImage = original
    image = outputImage
  }
  
  func restoreOriginalImage() {
    image = originalImage
  }
}
