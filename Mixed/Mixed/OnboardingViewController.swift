//
//  OnboardingViewController.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit

class OnboardingViewController: UIPageViewController {
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newOnboardingViewController("Home"),
                self.newOnboardingViewController("Tap"),
                self.newOnboardingViewController("Speaker"),
                self.newOnboardingViewController("Beer"),
                self.newOnboardingViewController("Login")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(toTour), name: NSNotification.Name.init("TakeTheTour"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toSpeaker), name: NSNotification.Name.init("ToSpeaker"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toBeer), name: NSNotification.Name.init("ToBeer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toLogin), name: NSNotification.Name.init("ToLogin"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(toAutoLogin), name: NSNotification.Name.init("AutoLogin"), object: nil)
    }
    
    
    private func newOnboardingViewController(_ name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)OnboardingViewController")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @objc func toTour(){
        setViewControllers([orderedViewControllers[1]], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func toSpeaker(){
        setViewControllers([orderedViewControllers[2]], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func toBeer(){
        setViewControllers([orderedViewControllers[3]], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func toLogin(){
        setViewControllers([orderedViewControllers[4]], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func toAutoLogin(){
        performSegue(withIdentifier: "toMenuAuto", sender: nil)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
}
