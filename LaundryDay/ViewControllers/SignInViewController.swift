//
//  SignInViewController.swift
//  LaundryDay
//
//  Created by MBP03 on 2018. 4. 14..
//  Copyright © 2018년 MBP03. All rights reserved.
//

import UIKit
import ProgressHUD

class SignInViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.backgroundColor = UIColor.lightGray
        signInButton.isEnabled = false
        handleTextField()
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //자동로그인
        if Api.User.CURRENT_USER != nil {
            self.performSegue(withIdentifier: "signInToMain", sender: nil)
        }
    }
    
    func handleTextField() {
        userEmailTextField.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        userPasswordTextField.addTarget(self, action: #selector(self.textFieldChanged), for: UIControlEvents.editingChanged)
        
    }
    
    @objc func textFieldChanged() {
        guard  let email = userEmailTextField.text, !email.isEmpty, let password = userPasswordTextField.text, !password.isEmpty else {
            signInButton.isEnabled = false
            signInButton.backgroundColor = UIColor.lightGray
            return
        }
        signInButton.isEnabled = true
        signInButton.backgroundColor = UIColor(red: 72/255, green: 199/255, blue: 149/255, alpha: 1)

        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButton_TUI(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Waiting")
        AuthService.signIn(email: userEmailTextField.text!, password: userPasswordTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Success")
            self.performSegue(withIdentifier: "signInToMain", sender: nil)
        }, onError: { error in
            ProgressHUD.showError(error!)
        })
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
