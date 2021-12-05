//
//  ScoreController.swift
//  438-Final
//
//  Created by Jooho Kim on 12/4/21.
//

import UIKit

class ScoreController: UIViewController {

    var score: Int = 0
    var name: String?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nameLabel.text = "Hi " + name!
        scoreLabel.text = "Score: " + String(score)
    }
    
    
}
