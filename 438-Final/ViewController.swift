//
//  ViewController.swift
//  438-Final
//
//  Created by Jooho Kim on 12/4/21.
//

import UIKit

class ViewController: UIViewController {

    var name: String = "Peter"
    var theme: String?
    
    @IBAction func startGame(_ sender: Any) {
        
        print("Starting Game")
        
        let arController = storyboard!.instantiateViewController(withIdentifier: "ArView") as! ARController

        arController.name = name
        navigationController?.pushViewController(arController, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }


}

