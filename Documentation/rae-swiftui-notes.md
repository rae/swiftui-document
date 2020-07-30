# SwiftUI @State

When an immutable struct's variable is annotated with `@State`, it is like memory for that variable is stored separately and (an immutable) pointer to that memory is in the struct.

On top of using a pointer to separate memory, it sets up a watchpoint on that memory so any changes percolate to anything else in the struct that depends on that state variable (i.e. is "bound" to it -- llvm FTW).

If you have UI that manipulates state, you can use the `$` prefix to "dereference" the memory and update it. e.g. a field:
> `TextField($stringVar)`

Since the state variable can only be used within the struct, it should always be marked as `private`.
> `@State private var foo = 0`

`@State` cannot be used with instances of a reference type (e.g. class). For that, you need `@ObjectBinding`.

# @ObjectBinding

Since struct state vars can only have one "owner", _ObjectBinding_ allows one **class instance** (actually reference type instance) to be shared as state among structs.

However, changing any state in the instance does not automatically percolate out to view (or other) structs that depend on it.

Use `Combine` in the state data class to handle this.

In the struct (e.g. view) use `@ObjectBinding` instead of `@State` to bind the struct's var to the instance.

# Combine

_Combine_ is a means for notifying objects about changes in other objects.

Instances (of classes, not structs) can "announce" changes, allowing subscribers to react to those changes.

This is handled in the `BindableObject` protocol, which the class must conform to:

> `var didChange = PassthroughSubject<Void, Never>()`

- not publishing any specific data, just the fact that there is a change ("`Void`")
- no errors are ever thrown ("`Never`" )

Call `didChange.send()` whenever anything changes (e.g. using a `didSet{}` on any instance vars)
- must **always** be called on the main thread (since it potentially updates UI views)

# @EnvironmentObject (a.k.a. view globals)

The `@EnvironmentObject` annotation means the variable is global to view ancestors of the object that added it to the environment. It is also _optional_ *and* implicitly unwrapped.
- if an _EnvironmentObject_ is not initialized when a view uses it, the app will crash.

It can be initialized in e.g. the `SceneDelegate` and passed in to the _ContentView__ via its `scene()` func by appending this:
> `// say in SceneDelegate there is an instance var userData = User()`
> `...ContantView().environmentObject(userData)`

This `environmentObject` won't get called for previews though. For that, inside the `#if DEBUG` insert this:
> `let userData = User()`

and then append to the _ContentView_:
> `ContentView().environmentObject(userData)`

Since view structs reference _EnvironmentObjects_ using only the class **type** -- not a specific instance -- this is an excellent pattern for (view hierarchy-specific) singletons.
