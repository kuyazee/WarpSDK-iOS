//
//  WarpQueryBuilder.swift
//  SwipeRX
//
//  Created by Zonily Jame Pesquera on 27/10/2016.
//
//

import Foundation

// MARK: - Warp.QueryBuilder
public extension Warp {
    public class QueryBuilder {
        
        /// Builder Model for Parameters
        public struct Parameters {
            var include: [String] = []
            var `where`: [Warp.QueryBuilder.Constraint] = []
            var sort: [WarpSort] = []
            var limit: Int? = nil
            var skip: Int? = nil

        }
        
        /// dictionary to store values
        public var dictionary: [String: Any] = [:]
        
        public init(parameters: Parameters) {
            // parse parameters.include
            self.dictionary["include"] = String(describing: parameters.include)
            
            // parse parameters.where
            self.dictionary["where"] = {
                var string: String = ""
                parameters.where.enumerated().forEach { (i, value) in
                    let generatedString = "\"\(value.key)\":{\"\(value.constraint.rawValue)\":"
                    
                    if let stringValue = value.value as? String {
                        string = string + "\(generatedString)\"\(stringValue)\"}"
                    } else {
                        string = string + "\(generatedString)\(value.value)}"
                    }
                    
                    if parameters.where.count > 1 && i != parameters.where.count - 1 {
                        string = string + ", "
                    }
                }
                return "{\(string)}"
            }()
            
            // parse parameters.sort
            self.dictionary["sort"] = {
                var string: String = ""
                parameters.sort.enumerated().forEach { (i, value) in
                    string = string + "{\"\(value.key)\": \(value.order.rawValue)}"
                    if parameters.sort.count > 1 && i != parameters.sort.count - 1 {
                        string = string + ", "
                    }
                }
                return "[\(string)]"
            }()
            
            // parse parameters.limit
            if let limit = parameters.limit {
                self.dictionary["limit"] = limit
            }
            
            // parse parameters.skip
            if let skip = parameters.skip {
                self.dictionary["skip"] = skip
            }
            
        }
        
        public init(_ dictionary: [String: Any]) {
            self.dictionary = dictionary
        }
        
        open func showDebug() {
            guard self.dictionary.keys.count > 0 else {
                print("WARPLOG There are no parameters")
                return
            }
            
            print("\n\nWARPLOG START =================== \n")
            for key in self.dictionary.keys {
                switch key {
                case "include":
                    print("include: \(self.dictionary["include"] ?? "")")
                case "where":
                    print("where: \(self.dictionary["where"] ?? "")")
                case "sort":
                    print("sort: \(self.dictionary["sort"] ?? "")")
                case "limit":
                    print("limit: \(self.dictionary["limit"] ?? "")")
                case "skip":
                    print("skip: \(self.dictionary["skip"] ?? "")")
                default:
                    print(key + ": \(self.dictionary[key] ?? "")")
                }
            }
            print("WARPLOG END ===================\n\n")
        }
    }
}

// MARK: - Warp.QueryBuilder.Constraint
public extension Warp.QueryBuilder {
    
    /// This class will be used to map the Query Parameters.
    public struct Constraint {

        /// This is the database row keyy
        public var key: String
        
        /// This is the Constraint value that will be used
        public var constraint: WarpConstraint
        
        /// This is the query value
        public var value: Any

        
        public init(equalTo value: Any, key: String) {
            self.key = key
            self.constraint = .equalTo
            self.value = value
        }
        
        public init(notEqualTo value: Any, key: String) {
            self.key = key
            self.constraint = .notEqualTo
            self.value = value
        }
        
        public init(greaterThan value: Any, key: String) {
            self.key = key
            self.constraint = .greaterThan
            self.value = value
        }
        
        public init(greaterThanOrEqualTo value: Any, key: String) {
            self.key = key
            self.constraint = .greaterThanOrEqualTo
            self.value = value
        }
        
        public init(lessThan value: Any, key: String) {
            self.key = key
            self.constraint = .lessThan
            self.value = value
        }
        
        public init(lessThanOrEqualTo value: Any, key: String) {
            self.key = key
            self.constraint = .lessThanOrEqualTo
            self.value = value
        }
        
        public init(existsKey key: String) {
            self.key = key
            self.constraint = .exists
            self.value = 1
        }
        
        public init(notExistsKey key: String) {
            self.key = key
            self.constraint = .exists
            self.value = 0
        }
        
        public init(containedIn values: [Any], key: String) {
            self.key = key
            self.constraint = .containedInArray
            self.value = values
        }
        
        public init(notContainedIn values: [Any], key: String) {
            self.key = key
            self.constraint = .notContainedInArray
            self.value = values
        }
        
        public init(containedInOrDoesNotExist values: [Any], key: String) {
            self.key = key
            self.constraint = .containedInOrDoesNotExist
            self.value = "\(values)"
        }
        
        public init(startsWith value: String, key: String) {
            self.key = key
            self.constraint = .startsWithString
            self.value = value
        }
        
        public init(endsWith value: String, key: String) {
            self.key = key
            self.constraint = .endsWithString
            self.value = value
        }
        
        public init(contains value: String, key: String) {
            self.key = key
            self.constraint = .containsString
            self.value = value
        }
        
        public init(contains value: String, keys: [String]) {
            var string: String = ""
            keys.enumerated().forEach { (i, key) in
                switch i {
                case 0:
                    string = key
                case keys.count:
                    string = string + key
                default:
                    string = string + "|" + key
                }
            }
            self.key = "\(string)"
            self.constraint = .containsString
            self.value = value
        }
        
        public init(containsEither values: [String], key: String) {
            self.key = key
            self.constraint = .containsEitherStrings
            self.value = "\(values)"
        }
        
        public init(containsAll values: [String], key: String) {
            self.key = key
            self.constraint = .containsAllStrings
            self.value = "\(values)"
        }
    }
}

// MARK: - Warp.QueryBuilder.Sort
public extension Warp.QueryBuilder {
    public struct Sort {
        public var key: String = ""
        public var order: WarpOrder = .ascending
        
        public init(by key: String) {
            self.key = key
            self.order = .ascending
        }
        
        public init(byDescending key: String) {
            self.key = key
            self.order = .descending
        }
    }
}

public enum WarpConstraint: String {
    /// eq: equal to
    case equalTo = "eq"
    
    /// neq: not equal to
    case notEqualTo = "neq"
    
    /// gt: greater than
    case greaterThan = "gt"
    
    /// gte: greater than or equal to
    case greaterThanOrEqualTo = "gte"
    
    /// lt: less than
    case lessThan = "lt"
    
    /// lte: less than or equal to
    case lessThanOrEqualTo = "lte"
    
    /// ex: is not null/is null (value is either true or false)
    case exists = "ex"
    
    /// in: contained in array
    case containedInArray = "in"
    
    /// nin: not contained in array
    case notContainedInArray = "nin"
    
    /// inx: contained in array, or is null
    case containedInOrDoesNotExist = "inx"
    
    /// str: starts with the specified string
    case startsWithString = "str"
    
    /// end: ends with the specified string
    case endsWithString = "end"
    
    /// has: contains the specified string (to search multiple keys, separate the key names with |)
    case containsString = "has"
    
    /// hasi: contains either of the specified strings
    case containsEitherStrings = "hasi"
    
    /// hasa: contains all of the specified strings
    case containsAllStrings = "hasa"
    
    
//    fi: found in the given subquery, for more info, see the Subqueries section
//    fie: found in either of the given subqueries, for more info, see the Subqueries section
//    fia: found in all of the given subqueries, for more info, see the Subqueries section
//    nfi: not found in the given subquery, for more info, see the Subqueries section
//    nfe: not found in either of the given subqueries, for more info, see the Subqueries section
}

public struct WarpSort {
    var key: String = ""
    var order: WarpOrder = .ascending
    
    public init(by key: String) {
        self.key = key
        self.order = .ascending
    }
    
    public init(byDescending key: String) {
        self.key = key
        self.order = .descending
    }
}

public enum WarpOrder: Int {
    case ascending = 1
    case descending = -1
}
