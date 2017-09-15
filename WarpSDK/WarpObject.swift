//
//  WarpObject.swift
//  Practice
//
//  Created by Zonily Jame Pesquera on 28/10/2016.
//
//

import Foundation
import PromiseKit

public extension Warp {
    public class Object: WarpObjectProtocol {
        internal let objectClassName: String
        internal var dictionary: [String: Any] = [:]
        
        /// returns the id
        public var id: Int {
            return self.dictionary["id"] as? Int ?? 0
        }
        
        /// returns the createdAt
        public var createdAt: String {
            return self.dictionary["created_at"] as? String ?? ""
        }
        
        /// returns the updatedAt
        public var updatedAt: String {
            return self.dictionary["updated_at"] as? String ?? ""
        }
        
        public class func createWithoutData(id: Int, className: String = "") -> Warp.Object {
            let object = Warp.Object(className: className)
            object.dictionary["id"] = id
            return object
        }
        
        public required init(className: String) {
            self.objectClassName = className
        }
        
        required public init(className: String, json: [String: Any]) {
            self.objectClassName = className
            self.dictionary = json
        }
        
        public func set(object value: Any, forKey: String) -> Self {
            switch forKey {
            case "created_at", "updated_at", "id":
                fatalError("This action is not permitted")
            default:
                if value is Warp.Object {
                    self.dictionary[forKey] = WarpPointer.map(warpObject: value as! Warp.Object)
                    return self
                }
                
                if value is Warp.User {
                    self.dictionary[forKey] = WarpPointer.map(warpUser: value as! Warp.User)
                    return self
                }
                
                self.dictionary[forKey] = value
                return self
            }
            
        }
        
        public func get(object forKey: String) -> Any? {
            return self.dictionary[forKey]
        }
        
        public func save(_ completion: @escaping WarpResultBlock) -> WarpDataRequest {
            guard let warp = Warp.shared else {
                fatalError("[Warp] WarpServer is not yet initialized")
            }
            
            let endPoint: String = {
                if self.id > 0 {
                    return warp.generateEndpoint(.classes(className: self.objectClassName, id: self.id))
                } else {
                    return warp.generateEndpoint(.classes(className: self.objectClassName, id: nil))
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
        
        public func destroy(_ completion: @escaping WarpResultBlock) -> WarpDataRequest {
            guard let warp = Warp.shared else {
                fatalError("WarpServer is not yet initialized")
            }
            
            let endPoint = warp.generateEndpoint(.classes(className: self.objectClassName, id: self.id))
            
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
        
        public func save() -> Promise<Warp.Object> {
            return Promise { fulfill, reject in
                _ = self.save({ (isSuccess, error) in
                    if let error = error {
                        reject(error)
                    } else {
                        fulfill(self)
                    }
                })
            }
        }
        
        public func destroy() -> Promise<Warp.Object> {
            return Promise { fulfill, reject in
                _ = self.destroy({ (isSuccess, error) in
                    if let error = error {
                        reject(error)
                    } else {
                        fulfill(self)
                    }
                })
            }
        }
    }
}
