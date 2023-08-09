//
//  ViewController.swift
//  BazelDemo
//
//  Created by Sanju Naik on 02/05/23.
//

import UIKit
import ObjCLib

enum MyError: Error {
    case firstError
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        testMethod()
        let a = 4
        print("a - \(a)")
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        button.setTitle("Test Crash", for: [])
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
        
//        let error = MyError.firstError
//        Crashlytics.crashlytics().record(error: error)
    }
    
    func testMethod() {
        print("Testing")
    }

    @IBAction func crashButtonTapped(_ sender: AnyObject) {
         let numbers = [0]
         let _ = numbers[1]
     }

}

//  --copt=-O0 \
//   --copt=-g \
//   --copt=-DDEBUG=1 \
//   --copt=-fno-omit-frame-pointer  \
//   --copt=-fobjc-arc \
//   --copt=-no-canonical-prefixes \

// --copt=-g0 \
//   --copt=-O2 \
//   --copt=-DNDEBUG \
//   --copt=-DNS_BLOCK_ASSERTIONS=1 \
//   --copt=-Os \
//   --copt=-DNDEBUG=1 \
//   --copt=-Wno-unused-variable \
//   --copt=-Winit-self \
//   --copt=-Wno-extra \
//   --swiftcopt -g \