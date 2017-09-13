//
//  WarpUserQuery.swift
//  WarpSDK
//
//  Created by Zonily Jame Pesquera on 15/06/2017.
//  Copyright © 2017 kz. All rights reserved.
//

import UIKit

public class WarpUserQuery {
    fileprivate var queryConstraints: [WarpQueryConstraint] = []
    fileprivate var queryBuilder: WarpQueryBuilder = WarpQueryBuilder()
    
    init() { }
}


// MARK: - Fetch Functions
public extension WarpUserQuery {
    public func get(_ objectId: Int, completion: @escaping (_ warpObject: WarpUser?, _ error: WarpError?) -> Void) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        let _ = Warp.API.get(warp.generateEndpoint(.users(id: objectId)), parameters: queryBuilder.query(queryConstraints).param, headers: warp.HEADER()).warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                switch warpResponse.statusType {
                case .success:
                    let user = WarpUser()
                    user.setValues(warpResponse.result!)
                    
                    completion(user, nil)
                default:
                    completion(nil, WarpError(message: warpResponse.message, status: warpResponse.status))
                }
                break
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    public func find(_ completion: @escaping (_ warpObjects: [WarpUser]?, _ error: WarpError?) -> Void) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        let _ = Warp.API.get(warp.generateEndpoint(.users(id: nil)), parameters: queryBuilder.query(queryConstraints).param, headers: warp.HEADER()).warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: Array<Dictionary<String,Any>>.self)
                switch warpResponse.statusType {
                case .success:
                    let warpObjects: [WarpUser] = warpResponse.result!.map({ (result) -> WarpUser in
                        let user = WarpUser()
                        user.setValues(result)
                        return user
                    })
                    completion(warpObjects, nil)
                default:
                    completion(nil, WarpError(message: warpResponse.message, status: warpResponse.status))
                }
                break
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    public func first(_ completion: @escaping (_ warpObject: WarpUser?, _ error: WarpError?) -> Void) {
        let _ = limit(1).find { (warpObjects, error) in
            completion(warpObjects?.first, error)
        }
    }
}

// MARK: - Query Functions
public extension WarpUserQuery {
    public func limit(_ value: Int) -> WarpUserQuery {
        queryBuilder.param["limit"] = value as Any?
        return self
    }
    
    public func skip(_ value: Int) -> WarpUserQuery {
        queryBuilder.param["skip"] = value as Any?
        return self
    }
    
    public func include(_ values: String...) -> WarpUserQuery {
        queryBuilder.param["include"] = String(describing: values) as Any?
        return self
    }
    
    public func sort(_ values: WarpSort...) -> WarpUserQuery {
        var string: String = ""
        for i in 0..<values.count {
            let value = values[i]
            string = string + "{\"\(value.key)\": \(value.order.rawValue)}"
            if values.count > 1 && i != values.count - 1 {
                string = string + ", "
            }
        }
        queryBuilder.param["sort"] = "[\(string)]" as Any?
        return self
    }
    
    public func equalTo(_ value: Any, forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(equalTo: value, key: key))
        return self
    }
    
    public func notEqualTo(_ value: Any, forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(notEqualTo: value, key: key))
        return self
    }
    
    public func lessThan(_ value: Any, forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(lessThan: value, key: key))
        return self
    }
    
    public func lessThanOrEqualTo(_ value: Any, forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(lessThanOrEqualTo: value, key: key))
        return self
    }
    
    public func greaterThanOrEqualTo(_ value: Any, forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(greaterThanOrEqualTo: value, key: key))
        return self
    }
    
    public func greaterThan(_ value: Any, forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(greaterThan: value, key: key))
        return self
    }
    
    public func existsKey(_ key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(existsKey: key))
        return self
    }
    
    public func notExistsKey(_ key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(notExistsKey: key))
        return self
    }
    
    public func containedIn(_ values: Any..., forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(containedIn: values, key: key))
        return self
    }
    
    public func notContainedIn(_ values:[Any], forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(notContainedIn: values, key: key))
        return self
    }
    
    public func startsWith(_ value: String, forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(startsWith: value, key: key))
        return self
    }
    
    public func endsWith(_ value: String, forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(endsWith: value, key: key))
        return self
    }
    
    public func contains(_ value: String, forKey key: String) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(contains: value, key: key))
        return self
    }
    
    public func contains(_ value: String, keys: String...) -> WarpUserQuery {
        queryConstraints.append(WarpQueryConstraint(contains: value, keys: keys))
        return self
    }
}
