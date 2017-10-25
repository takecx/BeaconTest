//
//  ViewController.swift
//  BComm
//
//  Created by 野口 威 on 2017/10/24.
//  Copyright © 2017年 takecx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var beacon:Beacon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        beacon = Beacon()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

