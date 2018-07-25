//
//  DiscView.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class DiscView: UIView {
    
    private let animationKey = "rotation"
    private var imageView: UIImageView!
    private var centerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style()
    }
    
    private func style(){
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.shadowRadius = 20
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.7
        self.backgroundColor = .clear
        
        // Add image view
        imageView = UIImageView(frame: CGRect(origin: .zero, size: self.frame.size))
        imageView.layer.cornerRadius = self.frame.height / 2
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        // Add white circle in middle
        let width = self.frame.width * 0.15
        let height = self.frame.height * 0.15
        centerView = UIView(frame: CGRect(x: self.frame.width/2 - width/2 , y: self.frame.height/2 - height/2, width: width, height: height))
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = height / 2
        self.addSubview(centerView)
    }
    
    func resize(to frame: CGRect){
        self.frame = frame
        imageView.frame.size = frame.size
        imageView.layer.cornerRadius = self.frame.height / 2

        let width = self.frame.width * 0.15
        let height = self.frame.height * 0.15
        centerView.frame = CGRect(x: self.frame.width/2 - width/2 , y: self.frame.height/2 - height/2, width: width, height: height)
        centerView.layer.cornerRadius = height / 2
    }
    
    func startRotating() {
        if self.layer.animation(forKey: animationKey) == nil {
            let animate = CABasicAnimation(keyPath: "transform.rotation")
            animate.duration = 3
            animate.repeatCount = Float.infinity
            animate.fromValue = 0.0
            animate.toValue = Float.pi * 2
            self.layer.add(animate, forKey: animationKey)
        }
    }
    
    func stopRotating() {
        if self.layer.animation(forKey: animationKey) != nil {
            self.layer.removeAnimation(forKey: animationKey)
        }
    }
    
    func updateArtwork(image: UIImage?){
        UIView.animate(withDuration: 0.5, animations: {
            self.imageView.alpha = 0
        }) { _ in
            self.imageView.image = image
            UIView.animate(withDuration: 0.5, animations: {
                self.imageView.alpha = 1
            })
        }
    }
}
