# Creating a new resource
Learn how to create a new resource.

## Overview

The **@Post** macro generates Swift code for making HTTP **POST** requests to a specified endpoint. It automatically creates request body structures, handles URL construction with path parameters, and provides a convenient async function for executing the request.

## Usage

Use the **@Post** macro to generate an instance method for creating a new resource.

### Basic Usage

```swift
// Define you data  model
@Post(url: "https://api.example.com/posts")
struct Post {
    @ExcludeFromRequest let id: Int
    var title: String
    var body: String
}
```

Due to the limitation that macros do not have knowledge of each other, it becomes impossible to automatically generate an initializer that excludes properties marked with **@ExcludedFromRequest**. The compiler will attempt to generate two identical initializers, which is not allowed.

To work around this, you have two options:

- Manually define an initializer.
- Create an extension with a static draft property that provides default values for a post request, like this:

```swift
extension Post {
    static let draft = Self(id: 0, userId: 0, title: "", body: "")
}
```

You can then use it as follows:

```swift
var newPost = Post.draft
newPost.title = "My Title"
newPost.body = "My Body"

try await newPost.post()

```

Alternatively, you can simply pass default values for properties marked with **@ExcludedFromRequest** when using the auto-generated initializer, avoiding the steps above altogether.

```swift
// Create an instance with required properties
var newPost = Post(id: 0, title: "My New Post", body: "My post body")

// Execute the POST request
try await newPost.post()
```

### With Dynamic Headers

```swift
let customHeaders = [
    KeyValuePair(key: "X-Custom-Header", value: "CustomValue"),
    KeyValuePair(key: "Content-Type", value: "application/json")
]

try await newPost.post(dynamicHeaders: customHeaders)
```

### With Dynamic Query Parameters

```swift
let queryParams = [
    KeyValuePair(key: "version", value: "1.0"),
    KeyValuePair(key: "format", value: "json")
]

try await newPost.post(dynamicQueryParams: queryParams)
```

### With Both Dynamic Headers and Query Parameters

```swift
try await newPost.post(
    dynamicHeaders: customHeaders,
    dynamicQueryParams: queryParams
)
```

Additionally, you can define default headers for every request by overriding the **request configuration** or **default authorization** properties. To learn more, refer to the <doc:RequestConfig> and <doc:Authorization> documentation.


## Path Parameters

The macro supports path parameters denoted by a colon prefix in the URL. For example, if you need to create a post assigned to a specific user, you should specify the **userId** parameter as a path argument and also define a property with the same name in your model.  

```swift
@Post(url: "https://api.example.com/posts/:userId")
struct Post {
    let userId: Int
    ...
}
```

In the example above:
 
- `:userId` -  is a path parameter that will be replaced with the actual **userId** property value from the model when constructing the final URL.
- The final URL becomes: `https://jsonplaceholder.typicode.com/posts/{actualUserId}`

Path parameters are automatically extracted from the URL and used to build the complete endpoint URL at runtime.

**Important**: Path parameters must match property names defined in your model. If a path parameter doesn't correspond to an existing property, a compilation error will be thrown.


## Request Body

The macro automatically generates a **PostRequestBody** struct that conforms to `Codable` and `Equatable`. The request body is JSON-encoded and sent with the POST request.

**Note**: Properties can be excluded from the generated request body by using the `@ExcludeFromRequest` macro. Any property marked with this macro will not be included in the `PostRequestBody` struct.


## Error Handling

The function is marked with `throws`, so wrap calls in a `do-catch` block for error handling:

```swift
do {
    try await postRequest.post()
    print("Post created successfully")
} catch {
    print("Failed to create post: \(error)")
}
```
