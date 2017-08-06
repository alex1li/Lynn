//
//  AddQueueViewController.swift
//  Lynn
//
//  Created by Alexander Li on 7/28/17.
//  Copyright © 2017 Alexander Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddQueueViewController: UIViewController, UITextFieldDelegate {

    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    
    @IBOutlet weak var queueNameTextField: UITextField!
    
    @IBAction func createQueueButton(_ sender: Any) {
        if (queueNameTextField.text != nil){
            createNewQueue(queueName: queueNameTextField.text!)
            queueNameTextField.text = ""
        }
    }
    
    func createNewQueue(queueName: String){
        ref?.child("Queues").child(queueNameTextField.text!).setValue("tempVal")
        let creationTime = Date()
        ref?.child("Queues").child(queueNameTextField.text!).child(String(describing: creationTime)).setValue("Created")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.queueNameTextField.delegate = self

        ref = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if (queueNameTextField.text != "") {
            queueNameTextField.text = ""
        }
        return false
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
