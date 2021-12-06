//
//  ViewController.swift
//  438-Final
//
//  Created by Jooho Kim on 12/4/21.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var name: String = "User"
    var theme: String = "Food"
    var selectedLocations: [CustomLocation] = []
    
    var pickerView = UIPickerView()
    @IBOutlet weak var themeField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    var themes = [
        "Sam Fox",
        "McKelvey",
        "Arts and Sciences",
        "Food"
    ]
    
    @IBAction func startGame(_ sender: Any) {
        print("Starting Game")
        let arController =
            storyboard!.instantiateViewController(withIdentifier: "ArView") as! ARController
        randomPickLocations()
        arController.name = name
        arController.theme = theme
        arController.customLocations = selectedLocations
        navigationController?.pushViewController(arController, animated: true)
    }
    
    @IBAction func updateName(_ sender: UITextField) {
        self.name = sender.text!
    }
    
    func randomPickLocations() {
        // Add locations to 'selectedLocations' array
        // Fixed size is going to be 3
        selectedLocations = [
            CustomLocation( -90.30732394846754, 38.64720173136602,   160, "Psychology"),
            CustomLocation( -90.30800231730747, 38.64839381265477,    165, "Olin"),
            CustomLocation( -90.30704617271222, 38.64822136372284,    166, "Eads"),
            CustomLocation( -90.30637277049225, 38.64908141836929,    165, "Lopata"),
            CustomLocation( -90.27570006435369, 38.647642530303706,    165, "Home")
            
        ]
        
        if theme == "Sam Fox" {
            
        }
        else if theme == "McKelvey" {
            
        }
        else if theme == "Arts and Sciences" {
            
        }
        else {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        pickerView.delegate = self
        pickerView.dataSource = self
        themeField.inputView = pickerView
        themeField.textAlignment = .center
        themeField.placeholder = "-- Select Theme --"
        nameField.placeholder = "User"
        name = "User"
        theme = "Food"
        
        self.nameField.delegate = self
        
        //reference: https://stackoverflow.com/questions/5306240/ios-dismiss-keyboard-when-touching-outside-of-uitextfield
        let tapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return themes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return themes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        themeField.text = themes[row]
        theme = themes[row]
        themeField.resignFirstResponder()
    }

}

