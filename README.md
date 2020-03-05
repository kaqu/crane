# Crane

Crane is a Swift library that allows you to build compact network clients in a declarative way.

**Work in progress... public api is yet subject to change.**

# OUT OF DATE

## Example

Let's have a quick look with few examples.

Imagine API where you like to get user details by its unique id. Firstly you have to define a request and associated response. We will use most of default behaviours provided by Crane. There are also additional protocols that simplifies JSON request/response descriptions even more.

``` swift
struct GetUserDetailsRequest: NetworkRequest {
  var userID: Int
  var urlParameters: URLParameters { ["userID": "\(userID)"] }

  static var httpMethod: HTTPMethod { .get }
  static var urlPathTemplate: URLPathTemplate = "/users/{userID}"

  typealias Session = URLNetworkSession
  typealias Body = Void

  struct Response: JSONNetworkResponse {
    var name: String
    var age: Int
  }
}
```

Then you have to make instances of both request and session to make a call. We will use minimal session implementation that is part of Crane. `URLNetworkSession` is adapter that uses `Foundation.URLSession` to execute requests.

``` swift
let session = URLNetworkSession(host: "example.org")
session.make(GetUserDetailsRequest(userID: 42)) { result in
  guard case let .success(response) = result else { /* handle the error */ }
  // access the response
  print(response.name)
  print(response.age)
}
```

This is the one of the simplest requests which uses a lot of default behaviours of request and response. You can howewer customise each request at any point. Let's see that in another example.

**TODO...**
``` swift
struct Request: NetworkRequest {
  var body: Body

  static var httpMethod: HTTPMethod { .post }
  static var urlPathTemplate: URLPathTemplate = ""

  typealias Session = URLNetworkSession
  struct Body: Codable {
  }
  struct Response: NetworkResponse {
  }
}
```

## Contents

The library provides a set of protocols and structs that are used to describe network communication.

`NetworkSession` is a protocol describing session used to communicate with given server. Its requirement is to define base `URLComponents` used to communicate with that server i.e host name or port. Additionally types conforming into this protocol have to define method to execute network calls using `NetworkRequest` conforming types. `NetworkSession` is intended to be a point of customisation for properties that are shared between multiple network calls i.e. autentication tokens or cache. Instance of session used to execute request is accesible in request description methods. `URLNetworkSession` is a basic implementation of `NetworkSession` using `Foundation.URLSession` without any additional customizations. 

`NetworkRequest` is a protocol that describes a HTTP network call. It requires to define its path, body, response type which is expected etc.. `NetworkRequest` instances are used to pass parameters that are specific to given request. Static parameters are used to define common properties while static methods are providing points of customization in context of session and produce final elements of HTTP request. All of those methods have default implementations based on static and instance properties with same names. Each of this methods have access to specific request instance and session executing that request. You can override those to implement custom behaviours but you have to understand default hierarchy of those in default implementation.

`JSONNetworkRequest` and `JSONNetworkResponse` are `NetworkRequest` and `NetworkResponse` extensions that simplifies JSON based communication.

`HTTPRequest`, `HTTPResponse`, `HTTPHeaders`, `URLParameters` and `URLQuery` are types that simplifies description and management of given elements sets.

`HTTPMethod` and `HTTPStatusCode` allow quicker and simpler access to common constants. 

## Request customization

`NetworkRequest` default method implementations have hierarchical structure. Final and most important is `static func httpRequest(for request: Self, in session: Session) -> Result<HTTPRequest, NetworkError>` which produces final request based on other methods. When you override that you have to ensure all properties usage manually. You can also ignore all properties by implementing this method. In most cases however you should keep that method unchanged.
`static func url(for request: Self, in session: Session) -> Result<URL, NetworkError>` uses `static func urlQuery(for request: Self, in session: Session) -> Result<URLQuery, NetworkError>`, `static func urlParameters(for request: Self, in session: Session) -> Result<URLParameters, NetworkError>` and `static var urlPathTemplate: URLPathTemplate` along with `var urlComponents: URLComponents` from specified session to produce final URL for the request. In most cases you should keep that method unchanged.
`static func httpBodyData(for request: Self, in session: Session) -> Result<Data, NetworkError>` uses `static func encodeBody(_ httpBody: Body) -> Result<Data, Error>` and request instance `var httpBody: Body` property to prepare body data.
`static func httpHeaders(for request: Self, in session: Session) -> Result<HTTPHeaders, NetworkError>`, `static func urlParameters(for request: Self, in session: Session) -> Result<URLParameters, NetworkError>` and `static func urlQuery(for request: Self, in session: Session) -> Result<URLQuery, NetworkError>` merges static and instance properties with the same name, where instance ones override static ones if needed. You can use `static func httpHeaders(for request: Self, in session: Session) -> Result<HTTPHeaders, NetworkError>` to implement header authentication based on currently used session. You have to remember though that you will be responsible for using instance and static header values manually in your implementation. 
All properties except `var httpBody: Body`, `static var httpMethod: HTTPMethod` and `static var urlPathTemplate: URLPathTemplate` have default, empty implementations. If you specify `Body` type to `Void` you can ommit `var httpBody: Body` and `static func encodeBody(_ httpBody: Body) -> Result<Data, Error>` since those have default implementations for that case.

## Session customization

You are mostly free in the way you implement custom sessions. Howewer it is intended to use request properties through dedicated method `static func httpRequest(for request: Self, in session: Session) -> Result<HTTPRequest, NetworkError>`. It will provide complete and final http request data. You can also use request instance and static properties to customize additional elements like timeout time or cache policy.

``` swift
public func make<Request>(
  _ request: Request,
  _ callback: @escaping ResultCallback<Request.Response, NetworkError>
) where URLNetworkSession == Request.Session, Request: NetworkRequest {
  switch Request.httpRequest(for: request, in: self) {
    case let .success(httpRequest):
      // execute request using httpRequest
    case let .failure(error):
      callback(.failure(error))
  }
}
```

## Sample solutions

**TODO...**

## Roadmap

- complete documentation
- complete unit tests
- provide GraphQL helpers
- provide more complex client for popular service as an example 
