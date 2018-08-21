//
//  ViewController.swift
//  ARKitDemo
//
//  Created by cby on 2018/7/10.
//  Copyright © 2018年 cby. All rights reserved.
//

import UIKit

let W_SCREEN = UIScreen.main.bounds.size.width
let H_SCREEN = UIScreen.main.bounds.size.height

class ViewController: UIViewController {

    @IBOutlet weak var startARBtn: UIButton!
    var tableView: UITableView?
    var dataArray: [String] = ["狮子场景"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: W_SCREEN, height: H_SCREEN - 64), style: .plain)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.estimatedRowHeight = 0
//        view.addSubview(tableView!)
    }

    @IBAction func startARBtnClick(_ sender: Any) {
        self.present(WDARSCNViewController(), animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
}
