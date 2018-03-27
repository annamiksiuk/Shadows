//
//  ViewController.swift
//  Shadows
//
//  Created by Anna Miksiuk on 20.03.2018.
//  Copyright © 2018 Anna Miksiuk. All rights reserved.
//

import UIKit
import Foundation
import AVKit

class ViewController: UIViewController, UICollectionViewDataSource, UIGestureRecognizerDelegate {
  
  //MARK: Properties
  
  var currentPage = 0
  var shadows = [ElementImageView]()
  
  var selectedElement: ElementImageView?
  var draggingElement: ElementImageView?
  var originalPosition: CGPoint?
  var touchOffset = CGPoint()
  
  var player: AVAudioPlayer?
  
  //MARK: IBOutlets
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var elementsCollectionView: UICollectionView!
  @IBOutlet weak var rightButton: UIButton!
  @IBOutlet weak var leftButton: UIButton!
  
  //MARK: Gestures
  
  @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
    let point = sender.location(in: view)
    guard let pressView = view.hitTest(point, with: nil) else { return }
    switch sender.state {
    case .began:
      if let draggingView = pressView as? ElementImageView {
        let center = draggingView.convert(draggingView.center, to: view)
        touchOffset = CGPoint(x: center.x - point.x, y: center.y - point.y)
        draggingElement = ElementImageView(element: draggingView)
        draggingElement?.center = CGPoint(x: point.x + touchOffset.x, y: point.y + touchOffset.y)
        view.addSubview(draggingElement!)
        selectedElement = draggingView
        selectedElement?.alpha = 0
      }
    default:
      break
    }
  }
  
  @objc func handlePan(_ sender: UIPanGestureRecognizer) {
    let point = sender.location(in: view)
    guard let element = draggingElement else {
      return
    }
    switch sender.state {
    case .changed:
      element.center = CGPoint(x: point.x + touchOffset.x, y: point.y + touchOffset.y)
    case .ended, .cancelled:
      guard let shadow = shadowContains(point: point) else {
        draggingElement?.removeFromSuperview()
        draggingElement = nil
        selectedElement?.alpha = 1
        playFail()
        return
      }
      if shadow.name == draggingElement?.name {
        shadow.restoreOriginalImage()
        playSuccess()
      } else {
        playFail()
      }
      draggingElement?.removeFromSuperview()
      draggingElement = nil
      selectedElement?.alpha = 1
    default:
      break
    }
  }
  
  @objc func handleTap(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: view)
    if shadowContains(point: point) != nil {
      playEmpty()
    }
  }
  
  //MARK: Actions
  
  @IBAction func actionPreviosPage(_ sender: UIButton) {
    currentPage -= 1
    if currentPage == 0 {
      leftButton.isEnabled = false
    }
    rightButton.isEnabled = true
    playBrowse()
    guard let page = UIImage(named: pages[currentPage]) else { return }
    changeBackground(to: page, with: .transitionCurlDown)
    generateShadows()
  }
  
  @IBAction func actionNextPage(_ sender: UIButton) {
    currentPage += 1
    if currentPage == pages.count-1 {
      rightButton.isEnabled = false
    }
    leftButton.isEnabled = true
    playBrowse()
    guard let page = UIImage(named: pages[currentPage]) else { return }
    changeBackground(to: page, with: .transitionCurlUp)
    generateShadows()
  }
  
  //MARK: View lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let backView = UIImageView(image: UIImage(named: "LightBlue"))
    backView.contentMode = .scaleAspectFill
    elementsCollectionView.backgroundView = backView
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    panGesture.delegate = self
    view.addGestureRecognizer(panGesture)
    
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
    longPressGesture.numberOfTouchesRequired = 1
    longPressGesture.minimumPressDuration = 0.1
    elementsCollectionView.addGestureRecognizer(longPressGesture)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    tapGesture.numberOfTouchesRequired = 1
    backgroundImageView.addGestureRecognizer(tapGesture)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    generateShadows()
  }
  
  //MARK: UICollectionViewDataSource
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return elements.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ElementCollectionViewCell",
                                                  for: indexPath) as! ElementCollectionViewCell
    cell.configure(nameElement: elements[indexPath.row])
    return cell
  }
  
  //MARK: UIGestureRecognizerDelegate
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  //MARK: Sound
  
  func playBrowse() {
    playSound(path: browseSound)
  }
  
  func playEmpty() {
    playSound(path: emptySound)
  }
  
  func playSuccess() {
    playSound(path: successSound)
  }
  
  func playFail() {
    playSound(path: failSounds[randomInt(to: failSounds.count)])
  }
  
  func playSound(path: String) {
    guard let pathSound = Bundle.main.path(forResource: path, ofType: "mp3") else { return }
    let urlSound = URL(fileURLWithPath: pathSound)
    do {
      player = try AVAudioPlayer(contentsOf: urlSound)
      player?.play()
    } catch {
    }
  }
  
  //MARK: Animations
  
  func changeBackground(to image: UIImage, with option: UIViewAnimationOptions) {
    weak var weakSelf = self
    weak var weakImage = image
    UIView.transition(with: backgroundImageView,
                      duration: 0.6,
                      options: option,
                      animations: { weakSelf?.backgroundImageView.image = weakImage },
                      completion: nil)
  }
  
  //MARK: Own methods
  
  func removeShadowsFromBackground() {
    for shadow in shadows {
      shadow.removeFromSuperview()
    }
    shadows.removeAll()
  }
  
  func addShadowsToBackground() {
    for shadow in shadows {
      backgroundImageView.addSubview(shadow)
    }
  }
  
  func generateShadows() {
    removeShadowsFromBackground()
    var randomCount = randomInt(from: 2, to: 5)
    var usingShadows = [String]()
    for _ in 0..<randomCount {
      let nameShadow = elements[randomInt(to: elements.count)]
      if !usingShadows.contains(nameShadow) {
        guard let element = ElementImageView(nameElement: nameShadow) else { return }
        element.frame = CGRect(x: 0, y: 0, width: 80, height: 90)
        element.transformToShadow()
        shadows.append(element)
        usingShadows.append(nameShadow)
      } else {
        randomCount += 1
      }
    }
    generatePlaceShadows()
    addShadowsToBackground()
  }
  
  func generatePlaceShadows() {
    let free : CGFloat = 70
    let width = backgroundImageView.frame.size.width
    let height = backgroundImageView.frame.size.height - free
    let countForX = Int(width / widthElement)
    let countForY = Int(height / heightElement)
    let offsetX = widthElement / 2
    let offsetY = heightElement / 2
    var places = [CGPoint]()
    for i in 0..<countForX {
      for j in 0..<countForY {
        let centerPlace = CGPoint(x: offsetX + widthElement * CGFloat(i), y: offsetY + heightElement * CGFloat(j))
        places.append(centerPlace)
      }
    }
    for shadow in shadows {
      let randomIndex = randomInt(to: places.count)
      let center = places[randomIndex]
      shadow.center = center
      places.remove(at: randomIndex)
    }
  }
 
  func shadowContains(point: CGPoint) -> ElementImageView? {
    for shadow in shadows {
      if shadow.point(inside: view.convert(point, to: shadow), with: nil) {
        return shadow
      }
    }
    return nil
  }
}
