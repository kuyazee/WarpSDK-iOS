//
//  WarpUser.swift
//  SwipeRX
//
//  Created by Zonily Jame Pesquera on 06/10/2016.
//
//

import Foundation

public class WarpUser: WarpObject {
    internal override var param: [String: Any] {
        didSet {
            for (key, value) in param {
                switch key {
                case "id":
                    _objectId = value as! Int
                case "created_at":
                    _createdAt = value as! String
                case "updated_at":
                    _updatedAt = value as! String
                case "session_token":
                    _sessionToken = value as! String
                default:
                    break
                }
            }
        }
    }
    
    internal var _username: String = ""
    internal var _password: String = ""
    internal var _email: String = ""
    internal var _sessionToken: String = ""
    
    public var username: String { return _username }
    public var password: String { return _password }
    public var email: String { return _email }
    public var sessionToken: String { return _sessionToken }
    
    public override func set(object value: Any, forKey: String) -> Self {
        switch forKey {
        case "created_at", "updated_at", "id", "session_token":
            fatalError("This action is not permitted")
        default:
            if value is WarpObject {
                self.param[forKey] = WarpPointer.map(warpObject: value as! WarpObject) as Any?
                return self
            }
            
            if value is WarpUser {
                self.param[forKey] = WarpPointer.map(warpUser: value as! WarpUser) as Any?
                return self
            }
            
            self.param[forKey] = value
            return self
        }
    }

    required public init() {
        super.init(className: "user")
    }
    
    public required init(className: String) {
        fatalError("init(className:) cannot be userd for WarpUser class, use `WarpUser()` instead")
    }
    
    public override class func createWithoutData(id: Int) -> WarpUser {
        let user = WarpUser()
        user.param["id"] = id as AnyObject?
        return WarpUser()
    }
    
    public static func query() -> WarpUserQuery {
        return WarpUserQuery()
    }
    
    public func setUsername(_ username: String) -> WarpUser {
        _username = username
        param["username"] = username as AnyObject?
        return self
    }
    
    public func setPassword(_ password: String) -> WarpUser {
        _password = password
        param["password"] = password as AnyObject?
        return self
    }
    
    public override func save(_ completion: @escaping WarpResultBlock) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        if objectId > 0 {
            let _ = Warp.API.put(warp.generateEndpoint(.users(id: objectId)), parameters: self.objects, headers: warp.HEADER()).warpResponse { (warpResult) in
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
                case .failure(let error):
                    completion(false, error)
                }
            }
        } else {
            let _ = Warp.API.post(warp.generateEndpoint(.users(id: nil)), parameters: self.objects, headers: warp.HEADER()).warpResponse { (warpResult) in
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
                case .failure(let error):
                    completion(false, error)
                }
            }
        }
    }
    
    public func login(_ username: String, password: String, completion: @escaping WarpResultBlock) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        let _ = Warp.API.post(warp.generateEndpoint(.login), parameters: ["username":username,"password":password], headers: warp.HEADER()).warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                switch warpResponse.statusType {
                case .success:
                    warpResponse.result!["username"] = username as AnyObject?
                    self.setValues(warpResponse.result!)
                    self.setCurrentUser()
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
    
    public func signUp(_ completion: @escaping WarpResultBlock) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        let _ = Warp.API.post(warp.generateEndpoint(.users(id: nil)), parameters: self.objects, headers: warp.HEADER()).warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                switch warpResponse.statusType {
                case .success:
                    self.login(self.username, password: self.password, completion: { (success, error) in
                        completion(success, error)
                    })
                default:
                    completion(true, WarpError(message: warpResponse.message, status: warpResponse.status))
                }
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
    public func logout(_ completion: @escaping WarpResultBlock) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        let _ = Warp.API.get(warp.generateEndpoint(.logout), parameters: nil, headers: warp.HEADER()).warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                switch warpResponse.statusType {
                case .success:
                    WarpUser.deleteCurrent()
                    completion(true, nil)
                default:
                    completion(true, WarpError(message: warpResponse.message, status: warpResponse.status))
                }
            case .failure(let error):
                completion(false, error)
            }
        }
    }
}

// MARK: - Persistence
extension WarpUser {
    internal func setCurrentUser() {
        var strings: [String] = []
        for key in self.objects.keys {
            strings.append(key)
        }
        
        UserDefaults.standard.set(strings, forKey: "swrxCurrentUserKeys_rbBEAFVAWFBVWW")
        for (key, value) in self.objects {
            UserDefaults.standard.set(value, forKey: "swrxCurrentUser\(key)_9gehrpnvr2pv3r")
        }
    }
    
    public static func current() -> WarpUser? {
        let user: WarpUser = WarpUser()
        let keys: [String] = UserDefaults.standard.array(forKey: "swrxCurrentUserKeys_rbBEAFVAWFBVWW") as? [String] ?? []
        
        if keys.count == 0 {
            return nil
        }
        
        for key in keys {
            _ = user.set(object: UserDefaults.standard.object(forKey: "swrxCurrentUser\(key)_9gehrpnvr2pv3r")! as Any, forKey: key)
        }
        return user
    }
    
    public static func deleteCurrent() {
        UserDefaults.standard.set([], forKey: "swrxCurrentUserKeys_rbBEAFVAWFBVWW")
        let keys: [String] = UserDefaults.standard.array(forKey: "swrxCurrentUserKeys_rbBEAFVAWFBVWW") as? [String] ?? []
        for key in keys {
            UserDefaults.standard.set("", forKey: "swrxCurrentUser\(key)_9gehrpnvr2pv3r")
        }
    }
}
