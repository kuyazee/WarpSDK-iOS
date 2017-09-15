//
//  WarpQuery.swift
//  Practice
//
//  Created by Zonily Jame Pesquera on 28/10/2016.
//
//

import Foundation

public extension Warp {
    public class Query <Class> where Class: Warp.Object {
        fileprivate var queryConstraints: [WarpQueryConstraint] = []
        fileprivate var queryBuilder: WarpQueryBuilder = WarpQueryBuilder()
        fileprivate let className: String
        
        init(className: String) {
            self.className = className
        }
        
        /// private initializer for userQuery
        init() {
            self.className = "user"
        }
    }
}

// MARK: - Since static stored properties can't be placed inside Generic classes yet I placed this here. 
public extension Warp {
    public static func UserQuery() -> Warp.Query<Warp.User> {
        return Warp.Query<Warp.User>()
    }
    
    public static func ObjectQuery(className: String) -> Warp.Query<Warp.Object> {
        return Warp.Query(className: className)
    }
}

public extension Warp.User {
    public static func Query() -> Warp.Query<Warp.User> {
        return Warp.Query<Warp.User>()
    }
}

public extension Warp.Object {
    public static func Query(className: String) -> Warp.Query<Warp.Object> {
        return Warp.Query(className: className)
    }
}

// MARK: - Warp.Object where Class: Warp.Object
public extension Warp.Query where Class: Warp.Object {
    public func get(_ objectId: Int, completion: @escaping (_ warpObject: Class?, _ error: WarpError?) -> Void) {
        
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        
        let endPoint: String = warp.generateEndpoint(.classes(className: self.className, id: objectId))
        
        let request = Warp.API.get(endPoint, parameters: queryBuilder.query(queryConstraints).param, headers: warp.HEADER())
        
        _ = request.warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                switch warpResponse.statusType {
                case .success:
                    completion(Class(className: self.className, json: warpResponse.result!), nil)
                default:
                    completion(nil, WarpError(message: warpResponse.message, status: warpResponse.status))
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    public func find(_ completion: @escaping (_ warpObjects: [Class]?, _ error: WarpError?) -> Void) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        
        let endPoint: String = warp.generateEndpoint(.classes(className: self.className, id: nil))
        
        let request = Warp.API.get(endPoint, parameters: queryBuilder.query(queryConstraints).param, headers: warp.HEADER())
        
        _ = request.warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                
                let warpResponse = WarpResponse(json: JSON, result: [[String: Any]].self)
                switch warpResponse.statusType {
                case .success:
                    let warpObjects: [Class] = (warpResponse.result ?? []).map({ Class(className: self.className, json: $0) })
                    completion(warpObjects, nil)
                default:
                    completion(nil, WarpError(message: warpResponse.message, status: warpResponse.status))
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    public func first(_ completion: @escaping (_ warpObject: Class?, _ error: WarpError?) -> Void) {
        self.limit(1).find { (warpObjects, error) in
            completion(warpObjects?.first, error)
        }
    }
}

// MARK: - Warp.Query where Class: Warp.User
public extension Warp.Query where Class: Warp.User {
    public func get(_ objectId: Int, completion: @escaping (_ warpObject: Class?, _ error: WarpError?) -> Void) {
        
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        
        let endPoint: String = warp.generateEndpoint(.users(id: objectId))
        
        let request = Warp.API.get(endPoint, parameters: queryBuilder.query(queryConstraints).param, headers: warp.HEADER())
        
        _ = request.warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: [String: Any].self)
                switch warpResponse.statusType {
                case .success:
                    completion(Class(className: self.className, json: warpResponse.result!), nil)
                default:
                    completion(nil, WarpError(message: warpResponse.message, status: warpResponse.status))
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    public func find(_ completion: @escaping (_ warpObjects: [Class]?, _ error: WarpError?) -> Void) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        
        let endPoint: String = warp.generateEndpoint(.users(id: nil))
        
        let request = Warp.API.get(endPoint, parameters: queryBuilder.query(queryConstraints).param, headers: warp.HEADER())
        
        _ = request.warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                
                let warpResponse = WarpResponse(json: JSON, result: [[String: Any]].self)
                switch warpResponse.statusType {
                case .success:
                    let warpObjects: [Class] = (warpResponse.result ?? []).map({ Class(className: self.className, json: $0) })
                    completion(warpObjects, nil)
                default:
                    completion(nil, WarpError(message: warpResponse.message, status: warpResponse.status))
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    public func first(_ completion: @escaping (_ warpObject: Class?, _ error: WarpError?) -> Void) {
        self.limit(1).find { (warpObjects, error) in
            completion(warpObjects?.first, error)
        }
    }

}

// MARK: - Fetch Functions
public extension Warp.Query {
}

// MARK: - Query Functions
public extension Warp.Query {
    public func limit(_ value: Int) -> Warp.Query<Class> {
        self.queryBuilder.param["limit"] = value
        return self
    }
    
    public func skip(_ value: Int) -> Warp.Query<Class> {
        self.queryBuilder.param["skip"] = value
        return self
    }
    
    public func include(_ values: String...) -> Warp.Query<Class> {
        self.queryBuilder.param["include"] = String(describing: values) as Any?
        return self
    }
    
    public func sort(_ values: WarpSort...) -> Warp.Query<Class> {
        var string: String = ""
        values.enumerated().forEach { (i, value) in
            string = string + "{\"\(value.key)\": \(value.order.rawValue)}"
            if values.count > 1 && i != values.count - 1 {
                string = string + ", "
            }
        }
        self.queryBuilder.param["sort"] = "[\(string)]"
        return self
    }
    
    public func equalTo(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(equalTo: value, key: key))
        return self
    }
    
    public func notEqualTo(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(notEqualTo: value, key: key))
        return self
    }
    
    public func lessThan(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(lessThan: value, key: key))
        return self
    }
    
    public func lessThanOrEqualTo(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(lessThanOrEqualTo: value, key: key))
        return self
    }
    
    public func greaterThanOrEqualTo(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(greaterThanOrEqualTo: value, key: key))
        return self
    }
    
    public func greaterThan(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(greaterThan: value, key: key))
        return self
    }
    
    public func existsKey(_ key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(existsKey: key))
        return self
    }
    
    public func notExistsKey(_ key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(notExistsKey: key))
        return self
    }
    
    public func containedIn(_ values: Any..., forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(containedIn: values, key: key))
        return self
    }
    
    public func notContainedIn(_ values:[Any], forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(notContainedIn: values, key: key))
        return self
    }
    
    public func startsWith(_ value: String, forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(startsWith: value, key: key))
        return self
    }
    
    public func endsWith(_ value: String, forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(endsWith: value, key: key))
        return self
    }
    
    public func contains(_ value: String, forKey key: String) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(contains: value, key: key))
        return self
    }
    
    public func contains(_ value: String, keys: String...) -> Warp.Query<Class> {
        self.queryConstraints.append(WarpQueryConstraint(contains: value, keys: keys))
        return self
    }
}
