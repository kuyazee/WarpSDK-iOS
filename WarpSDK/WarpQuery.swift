//
//  WarpQuery.swift
//  Practice
//
//  Created by Zonily Jame Pesquera on 28/10/2016.
//
//

import Foundation
import PromiseKit

public extension Warp {
    public class Query <Class> where Class: Warp.Object {
        public typealias SingleResultQueryBlock =  (_ warpObject: Class?, _ error: WarpError?) -> Void
        public typealias MultiResultQueryBlock =  (_ warpObjects: [Class]?, _ error: WarpError?) -> Void
        
        fileprivate let className: String
        fileprivate var queryParameters: Warp.QueryBuilder.Parameters = Warp.QueryBuilder.Parameters()
        fileprivate var queryBuilder: Warp.QueryBuilder {
            return Warp.QueryBuilder(parameters: self.queryParameters)
        }
        
        /// Description
        ///
        /// - Parameter className: creates a Warp.Query<Warp.Object> instance
        public init(className: String) {
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

// MARK: - Warp.Object where Class: Warp.Object
public extension Warp.Query where Class: Warp.Object {
    public func get(_ objectId: Int, completion: @escaping SingleResultQueryBlock) -> WarpDataRequest {
        
        guard let warp = Warp.shared else {
            fatalError("[Warp] WarpServer is not yet initialized")
        }
        
        let endPoint: String = warp.generateEndpoint(.classes(className: self.className, id: objectId))
        
        let request = Warp.API.get(endPoint, parameters: self.queryBuilder.dictionary, headers: warp.HEADER())
        
        return request.warpResponse { (warpResult) in
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
    
    public func find(_ completion: @escaping MultiResultQueryBlock) -> WarpDataRequest {
        guard let warp = Warp.shared else {
            fatalError("[Warp] WarpServer is not yet initialized")
        }
        
        let endPoint: String = warp.generateEndpoint(.classes(className: self.className, id: nil))
        
        let request = Warp.API.get(endPoint, parameters: self.queryBuilder.dictionary, headers: warp.HEADER())
        
        return request.warpResponse { (warpResult) in
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
    
    public func first(_ completion: @escaping SingleResultQueryBlock) -> WarpDataRequest {
        return self.limit(1).find { (warpObjects, error) in
            completion(warpObjects?.first, error)
        }
    }
    
    public func find() -> Promise<[Class]?> {
        return Promise { fulfill, reject in
            _ = self.find({ (result, error) in
                if let error = error {
                    reject(error)
                } else {
                    fulfill(result)
                }
            })
        }
    }
    
    public func get(_ objectId: Int) -> Promise<Class?> {
        return Promise { fulfill, reject in
            _ = self.get(objectId, completion: { (result, error) in
                if let error = error {
                    reject(error)
                } else {
                    fulfill(result)
                }
            })
        }
    }
    
    public func first() -> Promise<Class?> {
        return Promise { fulfill, reject in
            _ = self.first({ (result, error) in
                if let error = error {
                    reject(error)
                } else {
                    fulfill(result)
                }
            })
        }
    }
}

// MARK: - Warp.Query where Class: Warp.User
public extension Warp.Query where Class: Warp.User {
    public func get(_ objectId: Int, completion: @escaping SingleResultQueryBlock) -> WarpDataRequest {
        
        guard let warp = Warp.shared else {
            fatalError("[Warp] WarpServer is not yet initialized")
        }
        
        let endPoint: String = warp.generateEndpoint(.users(id: objectId))
        
        let request = Warp.API.get(endPoint, parameters: self.queryBuilder.dictionary, headers: warp.HEADER())
        
        return request.warpResponse { (warpResult) in
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
    
    public func find(_ completion: @escaping MultiResultQueryBlock) -> WarpDataRequest {
        guard let warp = Warp.shared else {
            fatalError("[Warp] WarpServer is not yet initialized")
        }
        
        let endPoint: String = warp.generateEndpoint(.users(id: nil))
        
        let request = Warp.API.get(endPoint, parameters: self.queryBuilder.dictionary, headers: warp.HEADER())
        
        return request.warpResponse { (warpResult) in
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
    
    public func first(_ completion: @escaping SingleResultQueryBlock) -> WarpDataRequest {
        return self.limit(1).find { (warpObjects, error) in
            completion(warpObjects?.first, error)
        }
    }
    
    public func find() -> Promise<[Class]?> {
        return Promise { fulfill, reject in
            _ = self.find({ (result, error) in
                if let error = error {
                    reject(error)
                } else {
                    fulfill(result)
                }
            })
        }
    }
    
    public func get(_ objectId: Int) -> Promise<Class?> {
        return Promise { fulfill, reject in
            _ = self.get(objectId, completion: { (result, error) in
                if let error = error {
                    reject(error)
                } else {
                    fulfill(result)
                }
            })
        }
    }
    
    public func first() -> Promise<Class?> {
        return Promise { fulfill, reject in
            _ = self.first({ (result, error) in
                if let error = error {
                    reject(error)
                } else {
                    fulfill(result)
                }
            })
        }
    }

}

// MARK: - Query Functions
public extension Warp.Query {
    public func limit(_ value: Int) -> Warp.Query<Class> {
        self.queryParameters.limit = value
        return self
    }
    
    public func skip(_ value: Int) -> Warp.Query<Class> {
        self.queryParameters.skip = value
        return self
    }
    
    public func include(_ values: String...) -> Warp.Query<Class> {
        self.queryParameters.include = values
        return self
    }
    
    public func sort(_ values: WarpSort...) -> Warp.Query<Class> {
        self.queryParameters.sort = values
        return self
    }
    
    
    public func equalTo(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(equalTo: value, key: key))
        return self
    }
    
    public func notEqualTo(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(notEqualTo: value, key: key))
        return self
    }
    
    public func greaterThan(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(greaterThan: value, key: key))
        return self
    }
    
    public func greaterThanOrEqualTo(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(greaterThanOrEqualTo: value, key: key))
        return self
    }
    
    public func lessThan(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(lessThan: value, key: key))
        return self
    }
    
    public func lessThanOrEqualTo(_ value: Any, forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(lessThanOrEqualTo: value, key: key))
        return self
    }
    
    public func existsKey(_ key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(existsKey: key))
        return self
    }
    
    public func notExistsKey(_ key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(notExistsKey: key))
        return self
    }
    
    public func containedIn(_ values: Any..., forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(containedIn: values, key: key))
        return self
    }
    
    public func notContainedIn(_ values: [Any], forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(notContainedIn: values, key: key))
        return self
    }
    
    public func containedInOrDoesNotExist(_ values: [Any], key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(containedInOrDoesNotExist: values, key: key))
        return self
    }
    
    public func startsWith(_ value: String, forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(startsWith: value, key: key))
        return self
    }
    
    public func endsWith(_ value: String, forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(endsWith: value, key: key))
        return self
    }
    
    public func contains(_ value: String, forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(contains: value, key: key))
        return self
    }
    
    public func contains(_ value: String, keys: String...) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(contains: value, keys: keys))
        return self
    }
    
    public func containsEitherStrings(_ values: [String], forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint(containsEither: values, key: key))
        return self
    }
    
    public func containsAllStrings(_ values: [String], forKey key: String) -> Warp.Query<Class> {
        self.queryParameters.where.append(Warp.QueryBuilder.Constraint.init(containsAll: values, key: key))
        return self
    }
}
