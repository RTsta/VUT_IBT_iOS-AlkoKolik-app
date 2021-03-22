//
//  myUtil.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 17.03.2021.
//

import Foundation

func myDebugPrint(_ something : Any, _ title : String = ""){
    print("*********** \(title) ***********")
    print("\(something)")
    var final = ""
    for _ in 0..<title.count { final += "*"}
    print("************\(final)************")
}
