//
//  LoginViewController.swift
//  ShowTimeApp
//
//  Created by mac on 4/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import TwitterKit
import Firebase

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, TWTRComposerViewControllerDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var googleButton: GIDSignInButton!

    @IBOutlet weak var twiiterButton: TWTRLogInButton!
    
    
    let imageArray = ["0","1","2"]
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = imageArray.count
        scrollView.delegate = self
        
        setupGoogleButton()
        setupTwitterButton()
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //make UI changes
        
        //set the scroll view width
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * (CGFloat(imageArray.count)), height: scrollView.frame.size.height)
        
        for number in 0..<imageArray.count {
            
            //center the frame on the current Image
            frame.origin.x = scrollView.frame.size.width * CGFloat(number)
            
            //set frame size to equal scroll view size
            frame.size = scrollView.frame.size
            
            //set image view frame
            let imageView = UIImageView(frame: frame)
            
            //set image view
            imageView.image = UIImage(named: imageArray[number])
            
            //set scrollsview subview as image
            self.scrollView.addSubview(imageView)
        }
    }
    

    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        guard pageControl.currentPage <= imageArray.count - 1 else {
            return
        }
        
        //increase current page
        pageControl.currentPage += 1
        
        //find the x by using the current page times the width of the scroll view
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        
        //offset our scroll view by x
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        
        
        //layout subview  if needed
        scrollView.layoutIfNeeded()
        
    }
    
    @IBAction func prevButtonTapped(_ sender: UIButton) {
        
        guard pageControl.currentPage >= 0 else {
            return
        }
        
        //decrease current page
        pageControl.currentPage -= 1
        
        //find the x
        let x = CGFloat(pageControl.currentPage) * scrollView.frame.size.width
        
        //offset our scroll view by x
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        
        
        //layout subview  if needed
        scrollView.layoutIfNeeded()
        
    }
    
    @IBAction func googleButtonTapped(_ sender: UIButton) {
       GIDSignIn.sharedInstance()?.signIn()
    }
    
    
    //MARK: Sign In Function
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let err = error {
            print("Error Signing in Google: \(err.localizedDescription)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let err = error {
                print("Couldn't Authenticate User to Firebase: \(err.localizedDescription)")
                return
            }
            
            if let auth = authResult {
                
                print("Successfully Authenticated User to Firebase: \(auth.user.uid)")
                
                self.goToHome()
            }
            
        }
        
    }
    //MARK: Button Setups
    
    func setupGoogleButton() {
        
        googleButton.layer.cornerRadius = googleButton.layer.frame.size.height / 2
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
    }
    
    func setupTwitterButton() {
        twiiterButton.logInCompletion = { (session, err) in
            if let error = err {
                print("Twitter Login Error: \(String(describing: error.localizedDescription))")
                return
            }
            guard let token = session?.authToken else {return}
            guard let secret = session?.authTokenSecret else {return}
            
            let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if error != nil {
                    print("Failed to Login using Firebase: \(String(describing:error?.localizedDescription))")
                    return
               
                }
                if let auth = authResult {
                    
                    print("Successfully Authenticated User to Firebase: \(auth.user.uid)")
                    
                    self.goToHome()
            }
        }
    }

}

}


//MARK: ScrollView Delegate
extension LoginViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //calculate the offset of the scroll view to get the current page
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        //set content page number to the page conrols current page
        pageControl.currentPage = Int(pageNumber)
    }
}


