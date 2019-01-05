import UIKit

//: > Constructing an URL

//print("https://hn.algolia.com/api/v1/search?tags=story&page=0&hitsPerPage=100")
//
//let urlComponents = NSURLComponents()
//urlComponents.scheme = "https";
//urlComponents.host = "hn.algolia.com";
//urlComponents.path = "/api/v1/search";
//
//// add params
//let tagsQueryItem = URLQueryItem(name: "tags", value: "story")
//let pageQueryItem = URLQueryItem(name: "page", value: "0")
//let hitsPerPageQueryItem = URLQueryItem(name: "hitsPerPage", value: "100")
//urlComponents.queryItems = [tagsQueryItem, pageQueryItem, hitsPerPageQueryItem]
//
//print(urlComponents.url!)

//: > Deconstructing an URL

//print("https://hn.algolia.com/api/v1/search?tags=story&page=0&hitsPerPage=100")

//let url = URL(string: "https://hn.algolia.com/api/v1/search?tags=story&page=0&hitsPerPage=100")!
//let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
//
//if let components = components {
//    components.path
//    components.host
//    components.query
//    components.percentEncodedQuery
//
//    if let queryItems = components.queryItems {
//        for queryItem in queryItems {
//            print("\(queryItem.name): \(queryItem.value)")
//        }
//    }
//}


//: > Modifying a Query Item's Value
//let oldURL = URL(string: "https://hn.algolia.com/api/v1/search?tags=story&page=0&hitsPerPage=100")!
//let oldComponents = URLComponents(url: oldURL, resolvingAgainstBaseURL: false)!
//
//let newURLComponents = modifyOrAddQueryItem(
//                URLcomponents: oldComponents,
//                queryItem: URLQueryItem(name: "hitsPerPage", value: "200")
//                    )
//
//print(newURLComponents.url!)
//
//
//func modifyOrAddQueryItem(URLcomponents: URLComponents, queryItem: URLQueryItem) -> URLComponents {
//    var components = URLcomponents
//
//    // If there are exisiting queryItems - I will either modify it or add it if it doesn't exist
//    if let _ = components.queryItems {
//
//        var queryItemWasFound: Bool = false
//
//        // I can force unwrap - because I already checked .queryItems for nil
//        for (index, item) in components.queryItems!.enumerated() {
//            if item.name == queryItem.name {
//                queryItemWasFound = true
//                components.queryItems?[index].value = queryItem.value
//            }
//        }
//
//        if !queryItemWasFound {
//            components.queryItems?.append(queryItem)
//        }
//    // If there are no exisiting queryItems - I add an array with the new queryItem
//    } else {
//        components.queryItems = [queryItem]
//    }
//
//
//    return components
//}


//: > Modifying a Query Item's Value - Extension to URLComponents
let oldURL = URL(string: "https://hn.algolia.com/api/v1/search?tags=story&page=0&hitsPerPage=100")!

var oldComponents = URLComponents(url: oldURL, resolvingAgainstBaseURL: false)!
oldComponents.addOrModify(URLQueryItem(name: "hitsPerPage", value: "200"))

print(oldComponents.url!)

extension URLComponents {
    mutating func addOrModify(_ queryItem: URLQueryItem) {

        if let _ = self.queryItems {
            
            var queryItemWasFound: Bool = false
            
            for (index, item) in self.queryItems!.enumerated() {
                if item.name == queryItem.name {
                    queryItemWasFound = true
                    self.queryItems?[index].value = queryItem.value
                }
            }
            
            if !queryItemWasFound {
                self.queryItems?.append(queryItem)
            }
            
        } else {
            self.queryItems = [queryItem]
        }
        
    }
}
