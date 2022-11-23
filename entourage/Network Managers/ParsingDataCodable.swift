//
//  ParsingDatas.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import Foundation


protocol ParsingDataCodable {
    static func parseData<T: Codable>(data:Data,key:String) -> T?
    static func parseDatas<T: Codable>(data:Data,key:String) -> [T]
}

extension ParsingDataCodable {
    //MARK: - Parsing single object -
    static func parseData<T: Codable>(data:Data,key:String) -> T? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] , let jsonGroup = json[key] as? [String:AnyObject] {
                let decoder = JSONDecoder()
                if let dataGroup = try? JSONSerialization.data(withJSONObject: jsonGroup) {
                  return try decoder.decode(T.self, from:dataGroup)
                }
            }
        }
        catch {
            Logger.print("Error parsing Data \(error)")
        }
        return nil
    }
    
    static func parseSingleValueData<T: Codable>(data:Data,key:String) -> T? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] , let jsonValue = json[key] {
                return jsonValue as? T
            }
        }
        catch {
            Logger.print("Error parsing Data \(error)")
        }
        return nil
    }
    
    //MARK: - Parsing Array objects -
    static func parseDatas<T: Codable>(data:Data,key:String) -> [T] {
        var array = [T]()
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] , let _json = json[key] as? [[String:AnyObject]] {
                let decoder = JSONDecoder()
                for jsonImages in _json {
                    if let dataImages = try? JSONSerialization.data(withJSONObject: jsonImages) {
                        let images = try decoder.decode(T.self, from:dataImages)
                        array.append(images)
                    }
                }
            }
        }
        catch {
            Logger.print("Error parsing datas \(error)")
        }
        
        return array
    }
}
