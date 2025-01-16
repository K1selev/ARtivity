//
//  RegPresenter.swift
//  ARtivity
//
//  Created by Сергей Киселев on 02.12.2023.
//

import Foundation
import Firebase

protocol RegScreenView: class {
   func processingResult(error: String?)
}

protocol RegScreenPresenter {
   init(view: RegScreenView, email: String?, password: String?, isMaker: Bool?)
   func dataProcessing()
}

class RegPresenter: RegScreenPresenter {
   unowned let view: RegScreenView
   let password: String?
   let email: String?
    let isMaker: Bool?
   var verificationTimer: Timer?

    required init(view: RegScreenView, email: String?, password: String?, isMaker: Bool?) {
        self.password = password
        self.email = email
        self.view = view
        self.isMaker = isMaker
    }
   func dataProcessing() {
       guard let email = self.email, let password = self.password else {
           self.view.processingResult(error: CauseOfError.loginOrPassword.localizedDescription)
           return
       }
       Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
           if let error = error {
               self?.view.processingResult(error: CauseOfError.invalidEmail.localizedDescription)
               print(error.localizedDescription)
               return
           }
           guard let uid = user?.user.uid else {
               self?.view.processingResult(error: CauseOfError.serverError.localizedDescription)
               return
           }

//           self?.confirmationByMail()
           self?.saveProfile(email: email) { success in
               if success {
                   //                    self.dismiss(animated: true, completion: nil)
               } else {
                   //                    self.resetForm()
               }
           }
           self?.view.processingResult(error: nil)
       }
   }
   func saveProfile(email: String, completion: @escaping ((_ success: Bool) -> Void)) {
       guard let uid = Auth.auth().currentUser?.uid else { return }
       let databaseRef = Database.database().reference().child("users/\(uid)")

       let username =  email.components(separatedBy: ("@"))[0]

       let userObject = [
           "name": username,
           "email": email,
           "accountCompleted": true,
           "phone": "no number yet",
           "userEvents": "",
           "completedEvent": "",
           "isMaker": isMaker,
       ] as [String: Any]

       databaseRef.setValue(userObject) { error, _ in
           completion(error == nil)
       }
   }

//   func confirmationByMail() {
//
//       self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkIfTheEmailIsVerified), userInfo: nil, repeats: true)
//
//       guard let user = Auth.auth().currentUser else {
//           return
//       }
//
//       user.reload { (error) in
//           if user.isEmailVerified == true {
//               self.view.processingResult(error: nil)
//           } else {
//               user.sendEmailVerification { (error) in
//                   guard error == nil else {
//                       print(error!.localizedDescription)
//                       return
//                   }
//                   self.view.processingResult(error: CauseOfError.inactiveAccount.localizedDescription)
//               }
//           }
//       }
//   }

//   @objc func checkIfTheEmailIsVerified() {
//       Auth.auth().currentUser?.reload(completion: { (error) in
//           if error == nil {
//               if Auth.auth().currentUser!.isEmailVerified {
//                   self.verificationTimer?.invalidate()     // Kill the timer
//                   self.view.processingResult(error: nil)
//               } else {
//                   self.view.processingResult(error: CauseOfError.inactiveAccount.localizedDescription)
//               }
//           } else {
//               print("\n\nerror\n\n")
//           }
//       })
//   }
}
