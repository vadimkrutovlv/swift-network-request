# ``SwiftNetworkRequest``
A lightweight and developer-friendly Swift framework for performing RESTful network requests with minimal boilerplate code on Apple platforms.

## Overview

This framework abstracts away the complexities of URL construction, parameter encoding, headers, and response parsing—making it easy to interact with REST APIs using concise and readable syntax.


By using macros like **@Get**, **@GetCollection**, **@Post**, **@Put**, and **@Delete**, you can define network behavior declaratively—directly alongside your model types. The result is a drastically simplified API layer that stays **readable**, **testable**, and **type-safe**.


## Topics

### Getting Started
- <doc:QuickStart>
- <doc:FetchResources>
- <doc:CreateNewResource>
- <doc:UpdateResource>
- <doc:DeleteResource>

### Advanced
- <doc:RequestConfig>
- <doc:Authorization>
- <doc:Encoding_Decoding>

### Structures
- ``KeyValuePair``
- ``RequestConfig``

### Protocols
``HTTPSession``

### Macros
``Get(url:headers:queryParams:)``
``GetCollection(url:headers:queryParams:)``
``Post(url:headers:queryParams:)``
``Put(url:headers:queryParams:)``
``Delete(url:headers:queryParams:)``

### Extensions
``Dependencies``
