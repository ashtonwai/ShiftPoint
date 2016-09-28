//
//  HighScoreViewController.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 9/28/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import UIKit

class HighScoreViewController: UIViewController {
    @IBAction func returnToPreviousView(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
