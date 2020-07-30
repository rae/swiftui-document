# What is the `@StateObject` property wrapper?

_[Paul Hudson @twostraws](https://twitter.com/twostraws) June 28th 2020_

**Updated for Xcode 12.0**

### New in iOS 14

SwiftUI’s `@StateObject` property wrapper is designed to fill a very specific gap in state management: when you need to create a reference type inside one of your views and make sure it stays alive for use in that view and others you share it with.

As an example, consider a simple `User` class such as this one:

```
class User: ObservableObject {
    var username = "@twostraws"
}
```

If you want to use that inside various views, you either need to create it externally to SwiftUI and inject it in, or create it inside one of your SwiftUI views and use `@StateObject`, like this:

```
struct ContentView: View {
    @StateObject var user = User()

    var body: some View {
        Text("Username: \(user.username)")
    }
}
```

That will make sure the `User` instance does not get destroyed when the view updates.

Previously you might have used `@ObservedObject` to get the same result, but that was dangerous – sometimes, and only sometimes, `@ObservedObject` could accidentally release the object it was storing, because it wasn’t designed to be the ultimate source of truth for the object. This won’t happen with `@StateObject`, so you should use it instead.