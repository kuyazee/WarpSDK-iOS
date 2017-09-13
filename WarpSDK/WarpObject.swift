//
//  WarpObject.swift
//  Practice
//
//  Created by Zonily Jame Pesquera on 28/10/2016.
//
//

import Foundation

public class WarpObject: WarpObjectProtocol {
    internal var param: [String: Any] = [:] {
        didSet {
            for (key, value) in param {
                switch key {
                case "id":
                    _objectId = value as! Int
                case "created_at":
                    _createdAt = value as! String
                case "updated_at":
                    _updatedAt = value as! String
                default: break
                }
            }
        }
    }
    
    internal var className: String = ""
    
    public var objects: [String: Any] {
        return param
    }
    
    internal var _objectId: Int = 0
    public var objectId: Int {
        return _objectId
    }
    
    internal var _createdAt: String = ""
    public var createdAt: String {
        return _createdAt
    }
    
    internal var _updatedAt: String = ""
    public var updatedAt: String {
        return _updatedAt
    }
    
    public required init(className: String) {
        self.className = className
    }
    
    init(className: String, JSON: [String: Any]) {
        self.className = className
        setValues(JSON)
    }
    
    public class func createWithoutData(id: Int, className: String) -> WarpObject {
        let warpObject = WarpObject(className: className)
        warpObject.param["id"] = id
        return warpObject
    }
    
    internal class func createWithoutData(id: Int) -> WarpObject {
        let warpObject = WarpObject(className: "")
        warpObject.param["id"] = id
        return warpObject
    }
    
    func setValues(_ JSON: [String: Any]) {
        self.param = JSON
        guard let createdAt: String = JSON["created_at"] as? String else {
            return
        }
        self._createdAt = createdAt
        guard let updatedAt: String = JSON["created_at"] as? String else {
            return
        }
        self._updatedAt = updatedAt
    }
    
    public func set(object value: Any, forKey: String) -> Self {
        switch forKey {
        case "created_at", "updated_at", "id":
            fatalError("This action is not permitted")
        default:
            if value is WarpObject {
                self.param[forKey] = WarpPointer.map(warpObject: value as! WarpObject)
                return self
            }
            
            if value is WarpUser {
                self.param[forKey] = WarpPointer.map(warpUser: value as! WarpUser)
                return self
            }
            
            self.param[forKey] = value
            return self
        }
        
    }
    
    public func get(object forKey: String) -> Any? {
        return self.param[forKey]
    }
    
    public func destroy() {
        destroy { (success, error) in
         
        }
    }
    
    public func destroy(_ completion: @escaping WarpResultBlock) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        if objectId > 0 {
            let _ = Warp.API.delete(warp.generateEndpoint(.classes(className: className, id: objectId)), parameters: param, headers: warp.HEADER()).warpResponse { (warpResult) in
                switch warpResult {
                case .success(let JSON):
                    let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                    switch warpResponse.statusType {
                    case .success:
                        self.setValues(warpResponse.result!)
                        completion(true, nil)
                    default:
                        completion(true, WarpError(message: warpResponse.message, status: warpResponse.status))
                    }
                    break
                case .failure(let error):
                    completion(false, error)
                }
            }
        } else {
            completion(false, WarpError(code: .objectDoesNotExist))
        }
    }
    
    public func save() {
        save { (success, error) in
            
        }
    }
    
    public func save(_ completion: @escaping WarpResultBlock) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        if objectId > 0 {
            let _ = Warp.API.put(warp.generateEndpoint(.classes(className: className, id: objectId)), parameters: param, headers: warp.HEADER()).warpResponse { (warpResult) in
                switch warpResult {
                case .success(let JSON):
                    let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                    switch warpResponse.statusType {
                    case .success:
                        self.setValues(warpResponse.result!)
                        completion(true, nil)
                    default:
                        completion(true, WarpError(message: warpResponse.message, status: warpResponse.status))
                    }
                    break
                case .failure(let error):
                    completion(false, error)
                }
            }
        } else {
            let _ = Warp.API.post(warp.generateEndpoint(.classes(className: className, id: nil)), parameters: param, headers: warp.HEADER()).warpResponse { (warpResult) in
                switch warpResult {
                case .success(let JSON):
                    let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                    switch warpResponse.statusType {
                    case .success:
                        self.setValues(warpResponse.result!)
                        completion(true, nil)
                    default:
                        completion(true, WarpError(message: warpResponse.message, status: warpResponse.status))
                    }
                    break
                case .failure(let error):
                    completion(false, error)
                }
            }
        }
    }
}
