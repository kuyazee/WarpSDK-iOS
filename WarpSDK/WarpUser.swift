//
//  WarpUser.swift
//  SwipeRX
//
//  Created by Zonily Jame Pesquera on 06/10/2016.
//
//

import Foundation


public extension Warp {
    public class User: Warp.Object {
    
        public required init() {
            super.init(className: "user")
        }
        
        override public func set(object value: Any, forKey: String) -> Self {
            if forKey == "session_token" {
                fatalError("This action is not permitted")
            } else {
                _ = super.set(object: value, forKey: forKey)
                return self
            }
        }
        
        public func set(username: String) -> Self {
            return self.set(object: username, forKey: "username")
        }
        
        public func set(password: String) -> Self {
            return self.set(object: password, forKey: "password")
        }
        
        public func set(email: String) -> Self {
            return self.set(object: email, forKey: "email")
        }
        
        public required init(className: String) {
            super.init(className: "user")
        }
        
        required public init(className: String, json: [String : Any]) {
            super.init(className: "user", json: json)
        }
        
        public override class func createWithoutData(id: Int, className: String = "") -> Warp.User {
            let user = Warp.User()
            user.dictionary["id"] = id
            return user
        }
        
        /// Creates a Warp.Query instance for this user
        public func query() -> Warp.Query<Warp.User> {
            return Warp.Query<Warp.User>()
        }
        
        override public func save(_ completion: @escaping WarpResultBlock = ({ _, _ in })) -> WarpDataRequest {
            guard let warp = Warp.shared else {
                fatalError("[Warp] WarpServer is not yet initialized")
            }
            
            let endPoint: String = {
                if self.id > 0 {
                    return warp.generateEndpoint(.users(id: self.id))
                } else {
                    return warp.generateEndpoint(.users(id: nil))
                }
            }()
            
            let request: WarpDataRequest = {
                if self.id > 0 {
                    return Warp.API.put(endPoint, parameters: self.dictionary, headers: warp.HEADER())
                } else {
                    return Warp.API.post(endPoint, parameters: self.dictionary, headers: warp.HEADER())
                }
            }()
            
            return request.warpResponse { (warpResult) in
                switch warpResult {
                case .success(let JSON):
                    let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                    switch warpResponse.statusType {
                    case .success:
                        self.dictionary = warpResponse.result!
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
        
        override public func destroy(_ completion: @escaping WarpResultBlock = ({ _, _ in })) -> WarpDataRequest {
            guard let warp = Warp.shared else {
                fatalError("[Warp] WarpServer is not yet initialized")
            }
            
            let endPoint = warp.generateEndpoint(.users(id: self.id))
            
            let request = Warp.API.delete(endPoint, parameters: self.dictionary, headers: warp.HEADER())
            
            guard self.id > 0 else {
                completion(false, WarpError(code: .objectDoesNotExist))
                return request
            }
            
            return request.warpResponse { (warpResult) in
                switch warpResult {
                case .success(let JSON):
                    let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                    switch warpResponse.statusType {
                    case .success:
                        self.dictionary = warpResponse.result!
                        completion(true, nil)
                    default:
                        completion(true, WarpError(message: warpResponse.message, status: warpResponse.status))
                    }
                case .failure(let error):
                    completion(false, error)
                }
            }
        }
        
        public static func Query() -> Warp.Query<Warp.User> {
            return Warp.Query<Warp.User>()
        }
    }
}

// MARK: - Calculated Objects
extension Warp.User {
    /// returns the username
    public var username: String {
        return self.dictionary["username"] as? String ?? ""
    }
    
    /// returns the password if there is a password
    public var password: String {
        return self.dictionary["password"] as? String ?? ""
    }
    
    /// returns the email
    public var email: String {
        return self.dictionary["email"] as? String ?? ""
    }
    
    /// returns the sessionToken
    public var sessionToken: String {
        return self.dictionary["session_token"] as? String ?? ""
    }
}

// MARK: - Login, Signup, Logout Calls
extension Warp.User {
    public func login(_ username: String, password: String, completion: @escaping WarpResultBlock) {
        guard let warp = Warp.shared else {
            fatalError("[Warp] WarpServer is not yet initialized")
        }
        let endPoint = warp.generateEndpoint(.login)
        
        let request = Warp.API.post(endPoint, parameters: ["username":username,"password":password], headers: warp.HEADER())
        
        _ = request.warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                switch warpResponse.statusType {
                case .success:
                    warpResponse.result!["username"] = username
                    self.dictionary = warpResponse.result!
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
            fatalError("[Warp] WarpServer is not yet initialized")
        }
        
        let endPoint = warp.generateEndpoint(.users(id: nil))
        
        let request = Warp.API.post(endPoint, parameters: self.dictionary, headers: warp.HEADER())
        
        _ = request.warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                switch warpResponse.statusType {
                case .success:
                    self.login(self.username, password: self.password, completion: completion)
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
            fatalError("[Warp] WarpServer is not yet initialized")
        }
        
        let endPoint = warp.generateEndpoint(.logout)
        
        let request = Warp.API.get(endPoint, parameters: nil, headers: warp.HEADER())
        
        _ = request.warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                switch warpResponse.statusType {
                case .success:
                    Warp.User.deleteCurrent()
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
extension Warp.User {
    internal func setCurrentUser(warpInstance: Warp? = Warp.shared) {
        var strings: [String] = []
        for key in self.dictionary.keys {
            strings.append(key)
        }
        
        UserDefaults.standard.set(strings, forKey: "swrxCurrentUserKeys_rbBEAFVAWFBVWW_\((warpInstance?.instanceIdentifier ?? ""))")
        for (key, value) in self.dictionary {
            UserDefaults.standard.set(value, forKey: "swrxCurrentUser\(key)_9gehrpnvr2pv3r_\((warpInstance?.instanceIdentifier ?? ""))")
        }
    }
    
    public static func current(warpInstance: Warp? = Warp.shared) -> Warp.User? {
        let user: Warp.User = Warp.User()
        
        let keys: [String] = UserDefaults.standard.array(forKey: "swrxCurrentUserKeys_rbBEAFVAWFBVWW_\((warpInstance?.instanceIdentifier ?? ""))") as? [String] ?? []
        
        if keys.count == 0 {
            return nil
        }
        
        for key in keys {
            _ = user.set(object: UserDefaults.standard.object(forKey: "swrxCurrentUser\(key)_9gehrpnvr2pv3r_\((warpInstance?.instanceIdentifier ?? ""))")! as Any, forKey: key)
        }
        return user
    }
    
    public static func deleteCurrent(warpInstance: Warp? = Warp.shared) {
        UserDefaults.standard.set([], forKey: "swrxCurrentUserKeys_rbBEAFVAWFBVWW_\((warpInstance?.instanceIdentifier ?? ""))")
        let keys: [String] = UserDefaults.standard.array(forKey: "swrxCurrentUserKeys_rbBEAFVAWFBVWW_\((warpInstance?.instanceIdentifier ?? ""))") as? [String] ?? []
        for key in keys {
            UserDefaults.standard.set("", forKey: "swrxCurrentUser\(key)_9gehrpnvr2pv3r_\((warpInstance?.instanceIdentifier ?? ""))")
        }
    }
}
