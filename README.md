# WarpSDK-iOS

[![Twitter](https://img.shields.io/badge/Twitter-%40kuyazee-blue.svg)](http://twitter.com/kuyazee)

__The Warp iOS SDK__ is available through the dependency manager [CocoaPods](http://cocoapods.org). 

===================

__The Warp iOS SDK__ is a library built in top of **[Alamofire](https://github.com/Alamofire/Alamofire)** for implementing the Warp Framework using Swift. It is designed to work with projects built on-top of the **[Warp Server](http://github.com/dividedbyzeroco/warp-server)**.

## Table of Contents
- **[Installation](#installation)**  
- **[Configuration](#configuration)**
- **[Objects](#objects)**
    - **[Saving Objects](#saving-objects)**
    - **[Retrieving Objects](#retrieving-objects)**
    - **[Updating Objects](#updating-objects)**
    - **[Deleting Objects](#deleting-objects)**
    - **[Pointers](#pointers)**
- **[Queries](#queries)**
    - **[Constraints](#constraints)**
    - **[Limit](#limit)**
    - **[Sorting](#sorting)**
    - **[Including Pointer Keys](#including-pointer-keys)**
- **[Users](#users)**
    - **[Getting Special User Keys](#getting-special-user-keys)**
    - **[Logging In](#logging-in)**
    - **[Fetching Current User](#fetching-current-user)**
    - **[Signing Up](#signing-up)**
    - **[Logging Out](#logging-out)**
- **[Functions](#functions)**
    
## Installation

To install the Warp iOS SDK via cocoapods, simply use the install command to save it in your podfile:

```Cocoapods
pod 'WarpSDK'
```

## Configuration

To initialize the SDK for **client-side development**, simply add the following configruation to the main file of your project:

```Swift
// Import Warp
import WarpSDK

// Initialize Warp Inside AppDelegate 
func applicationDidFinishLaunching(application: UIApplication) {
    Warp.Initialize("http://my-warp-server.com/api/1/", apiKey: "12345678abcdefg")
}
```

## Objects

Objects represent individual instances of models. In terms of the database, an Object can be thought of as being a `row` in a table. Throughout the Warp Framework, Objects are the basic vehicles for data to be transmitted to and fro the server.

Each Object contains different keys which can be set or retrieved as needed. Among these keys are three special ones:

- objectId: a unique identifier that distinguishes an object inside a table
- createdAt: a timestamp that records the date and time when a particular object was created (UTC)
- updatedAt: a timestamp that records the date and time when a particular object was last modified (UTC)

These keys are specifically set by the server and cannot be modified by the user.


### Saving Objects

To save an Object for a specific model, use the `WarpObject` class:

```Swift
let alien = WarpObject(className: "alien")
```

You can set the values of the Object's keys using the `.setObject(value:AnyObject, forKey:String)` method:

```Swift
alien.setObject("TheDoctor", forKey: "name")
alien.setObject("150000", forKey: "age")
alien.setObject(4, forKey: "type")
```

Then, save the Object using the `.save()` method:

```Swift
alien.save()

// or 

alien.save { (success, error) in
    if error != nil {
        print(error)
    } else {
        print("The alien has been created with the following ID:", alien.objectId)
        print("The alien has been named:", alien.objectForKey("name"))
    }
}
```


### Retrieving Objects

To retrieve an Object for a specific model, you can use `Warp Queries`. For more info, see the section on [Queries](#queries):

```Swift
let alienQuery = WarpQuery(className: "alien")
alienQuery.equalTo(16, forKey: "id")
alienQuery.first { (warpObject, error) in
    // You now have a copy of alien (id: 16) from the database        
}
```

Now that you have fetched the object, you can also get its keys using the `.objectForKey(key:String)` method:

```Swift
let name = alien.objectForKey("name")
let age = alien.objectForKey("age")
let type = alien.objectForKey("type")
```

For special keys as mentioned in the section on [Objects](#objects), you can retrieve their values via the following properties:

```Swift
var id = alien.objectId
var createdAt = alien.createdAt
var updatedAt = alien.updatedAt
```

Note that these fields cannot be retrieved via the `.objectForKey(key:String)` method.


### Updating Objects

Whenever you use `.save()` or `Warp Queries` to save/retrieve objects, you can modify the keys of these objects directly using the same `.setObject(value:AnyObject, forKey:String)` method. Warp automatically knows that you've updated these fields and prepares the object for updating.

For example, after the `.save()` method:

```Swift
let alien = WarpObject(className: "alien")
alien.setObject("Madam Vestra", forKey: "name")
alien.setObject(4, forKey: "type")

alien.save { (success, error) in
    // If this is the 200th alien, change its type, for example
    if alien.objectId > 200 {
        alien.setObject(5, forKey: "type")
    }
    
    // Update the alien
    alien.save { (success, error) in
        // The alien has been successfully updated
    }
}
```

For example, after retrieving from `Warp Queries`:

```Swift
let alienQuery = WarpQuery(className: "alien")
alienQuery.equalTo(5, forKey: "id")

alienQuery.first { (warpObject, error) in
    alien.setObject(5, forKey: "age")
    
    alien.save { (success, error) in
        // The alien has been successfully updated
    }
}
```

Additionally, if the key you are trying to update is an `integer` and you want to atomically increase or decrease its value, you can opt to use the `.increment()` method instead.

### Deleting Objects

If you want to delete a saved or retrieved object, all you need to do is call the `.destroy()` method of the object:

```Swift
alien.destroy()

// or

alien.destroy { (success, error) in
    print("The alien has been destroyed")            
}
```


### Pointers

If your objects use [pointers](https://github.com/dividedbyzeroco/warp-server#pointers) for some of its keys, you can directly set them via the `.set()` method.

For example, if you are creating a `planet` for an `alien` object, you can use the following approach:

```Swift
planet.save { (success, error) in
    let alien = WarpObject(className: "alien")
    alien.setObject("Slitheen", forKey: "name")
    alien.setObject(planet, forKey: "planet")

    alien.save { (success, error) in
        // The alien has been successfully saved
    }
}
```

If, for example, you have an existing `planet` and you want to use it for an `alien` object, you can use the following approach:

```Swift
// For Objects, WarpObject.createWithoutData(id: Int, className: String)
// For users, WarpUser.createWithoutData(id: Int)
let planet = WarpObject.createWithoutData(id: 2, className: "planet")
let alien = WarpObject(className: "alien")
alien.set('name', 'Captain Jack Harkness');
alien.set('planet', planet); // Set the object directly

alien.save { (success, error) in
    // The alien has been successfully saved
}
```

## Queries

There are certain scenarios when you may need to find Objects from a model. In these instances, it would be convenient to use Queries. Queries allow you to find specific Objects based on a set of criteria.

For example, if you want to query objects from the `alien` model, you would use the following code:

```Swift
// Prepare query
let alienQuery = WarpQuery(className: "alien")

// Use `.find()` to get all the objects in the `alien` table
alienQuery.find { (aliens, error) in
    // You now have a collection of all the aliens        
}

// Use `.first()` to get the first object in the `alien` table
alienQuery.first { (alien, error) in
    // You now have the first alien object            
}
```

### Constraints

Constraints help filter the results of a specific query. In order to pass constraints for a Query, use any of the following constraints you wish to apply:

```Swift
// Prepare query
let alienQuery = WarpQuery(className: "alien")

// Find an exact match for the specified key
alienQuery.equalTo("The Doctor", forKey: "name")
alienQuery.notEqualTo("The Master", forKey: "name")

// If the key is ordinal (i.e. a string, a number or a date), you can use the following constraints
alienQuery.lessThan(21, forKey: "age")
alienQuery.lessThanOrEqualTo("Weeping Angels", forKey: "name")
alienQuery.greaterThanOrEqualTo(500, forKey: "life_points")
alienQuery.greaterThan("2016-08-15 17:30:00+00:00", forKey: "created_at")

// If you need to check if a field is null or not null
alienQuery.existsKey("type")
alienQuery.notExistsKey("type")

// If you need to find if a given key belongs in a list, you can use the following constraints
alienQuery.containedIn(["Doctor", "Warrior"], forKey: "role")
alienQuery.notContainedIn([18, 20], forKey: "age")

// If you need to search a string for a substring
alienQuery.startsWith("The", forKey: "name")
alienQuery.endsWith("Master", forKey: "name")
alienQuery.contains("M", forKey: "name")

// If you need to search multiple keys for a substring
alienQuery.contains("M", keys: ["name", "username", "email"])
```


### Limit

By default, Warp limits results to the top 100 objects that satisfy the query criteria. In order to increase the limit, you can specify the desired value via the `.limit()` method. Also, in order to implement pagination for the results, you can combine the `.limit()` with the `.skip()` methods. The `.skip()` method indicates how many items are to be skipped when executing the query. In terms of scalability, it is advisable to limit results to 1000 and use skip to determine pagination.

For example:

```Swift
alienQuery.limit(1000) // Top 1000 results
alienQuery.skip(1000) // Skip the first 1000 results
```

NOTE: It is recommended that you use the sorting methods in order to retrieve more predictable results. For more info, see the section below.


### Sorting

Sorting determines the order by which the results are returned. They are also crucial when using the limit and skip parameters. To sort the query, use the following methods:

```Swift
alienQuery.sortBy('age'); // Sorts the query by age, in ascending order
alienQuery.sortByDescending(['created_at', 'life_points']); // You can also use an array to sort by multiple keys
```


### Including Pointer Keys

In order to include keys that belong to a pointer, we can use the `.include(values: [String])` method.

```Swift
alienQuery.include(["planet.name", "planet.color"])
```

The above query will return aliens with their respective planets as pointers:

```Swift
alienQuery.find { (aliens, error) in
    if error == nil {
        for alien in aliens! {
            let greeting = "I am " + (alien.objectForKey("name") as! String) + " and I come from the Planet " + (alien.objectForKey("planet")?.objectForKey("name") as! String)
            print(greeting)
        }
    }
}
```

## Users

User accounts are often an essential part of an application. In Warp, these are represented by Warp Users. Warp Users are extended from the Warp Object, which means you can use the same methods found in Warp Objects; however, Warp Users have additional methods specifically tailored for user account management.


### Getting Special User Keys

Aside from id, createdAt and updatedAt, Warp User also has the following get methods:

```Swift
var userQuery = new Warp.Query(Warp.User);
userQuery.equalTo('id', 5).first().then(user => {
    var id = user.id;
    var createdAt = user.createdAt;
    var updatedAt = user.updatedAt;
    var username = user.getUsername();
    var email = user.getEmail();
});
```

Note that for Warp Query, instead of specifiying 'user' as the string, we can simply place Warp.User as the parameter.


### Logging In

In order to log in to a user account, you would use the `.login(username:String, password: String, completion: { (success, error) in })` method:

```Swift
WarpUser().login("username", password: "password") { (success, error) in
    if error != nil {
        // Successfully logged in
    } else {
        // There was an error
    }
}
```


### Fetching Current User

To get the currently logged in user, you would use the `.current()` method:

```Swift
var current = WarpUser.current()
```


### Signing Up

To register a new user account, you would use the `.signUp({ (success, error) in })` method:

```Swift
let user = WarpUser()
user.setUsername("Luke Smith")
user.setPassword("k9_and_sara")

user.signUp { (success, error) in
    if error != nil {
        // Signed up; `.current()` returns the registered user
        let current = WarpUser.current()
    } else {
        // There was an error
    }
}
```

Note that you cannot use `.save()` to create a user. You can only use `.save()` to update a user which has been registered or logged in.


### Logging Out

To log out of a user account, you would use the `.logOut()` method:

```Swift
user.logout { (success, error) in
    if error != nil {
        // Logged out; `.current()` now returns nil
        var current = WarpUser.current()
    } else {
        // There was an error
    }
}
```

## Functions

To run Warp [Functions](http://github.com/dividedbyzeroco/warp-server#functions) from the API, you may use Warp Functions:

```Swift
// WarpFunction.run(functionName:String, parameters: [String:AnyObject]?, completion: { (result, error) in })

WarpFunction.run("get-votes", parameters: ["from":"2016-08-14", "to":"2016-08-15"]) { (result, error) in
    if error == nil {
        // `result` contains a JSON Object of the results from the API
    } else {
        // There was an error
    }
}
```
