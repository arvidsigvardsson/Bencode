//
//  Bencode.swift
//  Bencode
//
//  Created by Arvid Sigvardsson on 2016-03-29.
//  Copyright © 2016 Arvid Sigvardsson. All rights reserved.
//

import Foundation

func decodeString(str: String) -> (Any, String)? {
    guard let i = str.characters.indexOf(":")
        else { return nil }
    let head = str.substringToIndex(i) //slices[0]
    guard let num = Int(head)
        else { return nil }
    let tail = str.substringFromIndex(i.advancedBy(1)) //slices[1]
    if tail.characters.count < num {
        return nil
    }
    let s1 = tail.substringToIndex(tail.startIndex.advancedBy(num))
    let s2 = tail.substringFromIndex(tail.startIndex.advancedBy(num))
    return (s1, s2)
}

func decodeInt(str: String) -> (Any, String)? {
    guard let i = str.characters.indexOf("e")
        else { return nil }
    if str.substringToIndex(str.startIndex.advancedBy(1)) != "i" {
        return nil
    }
    guard let x = Int(str.substringWithRange(str.startIndex.advancedBy(1)..<i))
        else { return nil }
    let tail = str.substringFromIndex((i.advancedBy(1)))
    return (x, tail)
}

func decodeBItem(str: String) -> (Any, String)? {
    let retValue: Any
    let retString: String
    let firstIndex = str.startIndex.advancedBy(1)
    
    switch  str.substringToIndex(firstIndex) {
    case "d":
        var retDict = Dictionary<String, Any>()  //: Dictionary<String, Any> =
        var tail = str.substringFromIndex(firstIndex)
        while tail.substringToIndex(tail.startIndex.advancedBy(1)) != "e" {
            let key: Any
            let value: Any
            //
            guard let tup1 = decodeString(tail)
                else { return nil }
            (key, tail) = tup1
            guard let tup2 = decodeBItem(tail)
                else { return nil }
            (value, tail) = tup2
            retDict[key as! String] = value
        }
        retValue = retDict
        retString = tail.substringFromIndex(tail.startIndex.advancedBy(1))
    case "l":
        var retList = Array<Any>()
        var tail = str.substringFromIndex(firstIndex)
        while tail.substringToIndex(tail.startIndex.advancedBy(1)) != "e" {
            let item: Any
            guard let tup = decodeBItem(tail)
                else { return nil }
            (item, tail) = tup
            retList.append(item)
        }
        retValue = retList
        retString = tail.substringFromIndex(tail.startIndex.advancedBy(1))
    case  "i":
        guard let tup = decodeInt(str)
            else { return nil }
        (retValue, retString) = tup
    case "0"..."9":
        guard let tup = decodeString(str)
            else { return nil }
        (retValue, retString) = tup
    default:
        return nil
    }
    
    return  (retValue, retString)
}

public func parse(str: String) -> Any? {
    if let (obj, emptyStr) = decodeBItem(str) {
        if emptyStr != "" {
            return nil
        } else {
            return obj
        }
    } else {
        return nil
    }
}

func bencodeString(str: String) -> String {
    let len = str.characters.count
    return "\(len):\(str)"
}

func bencodeInt(x: Int) -> String {
    return "i\(x)e"
}

public func serialize(item: Any) -> String {
    switch item {
    case let x as Int:
        return bencodeInt(x)
    case let str as String:
        return bencodeString(str)
    case let arr as [Any]:
        var str = "l"
        for element in arr {
            str += serialize(element)
        }
        str += "e"
        return str
    case let dict as Dictionary<String, Any>:
        var str = "d"
        for (key, value) in dict {
            str += bencodeString(key)
            str += serialize(value)
        }
        str += "e"
        return str
    default:
        assert(false)
    }
}