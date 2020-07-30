# What's new in Swift

- Swift standard library now sits below Foundation
- Code completion 5x-10x faster
- Swift 5.3 will be available on Windows
- Swift for AWS Lambda (?)
## Phrase salad

Many topics were thrown up on the screen. Not all of them were talked about. Each has a Swift feature ID.

- KeyPath expressions as functions (SE-0249)
- callable values of user-defined nominal types (SE-0253)
- string init with access to unintiialized storage (SE-0263)
- std lib preview package (SE-0264)
- "where" clauses on contextually generic declarations (SE-0267)
- refined `didSet` semantics (SE-0268)
- collection operations on noncontiguous elements (SE-0270)
- `Float16` (SE-0277)
   - more efficient 156-bit floats for faster code (with less precision)

### multiple trailing closures (SE-0279)

```
UIView.animate(withDuration: 0.3) {
	self.view.alpha = 0
} completion: { _ in
	self.view.removeFromSuperview()
}
```

- `@main` - type-based program entry points (SE-0281)

```
import ArgumentParser

@main
struct Hello: ParsableCommand {
	@Argument(help: "The name to greet")
	var name: String
	
	func run() { print("Hello, \(name)!") }
}
```


```
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	func application(
		_ app: UIApplication,
		didFinishLaunchingWithOptons options: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool { true }
}
```


```
import SwiftUI

@main
struct MyApp: App {
	var body: some Scene {
		WindowGroup {
			Text("Hellow, world").padding()
		}
	}
}
```

### increased availablility of implicit `self` in closures (SE-0269)

```
UIView.animate(withDuration: 0.3) { [self] in
	view.alpha = 0
} completion: { [self] _ in
	view.removeFromSuperview()
}
```

- can always omit `self.` from enclosure if self is a `struct` or `enum` (good for SwiftUI!)

### multi-pattern catch clauses (SE-0276)

```
import System

do {
	fd = try FileDescriptor.open(
		path,
		.readOnly,
		options: .create,
		permissions: .ownerReadWrite
	)
} catch Errno.noSuchFileOrDirectory, Errno.notDirectory {
	// create dir
} catch {
	print(error)
}
```

### synthesized comparable conformance for enum types (SE-0266)


```
enum Status: Hashable, Comparable {
	case draft
	case saved
	case failedToSend
	case sent
	case delivered
	case read
	
	var wasSend: Bool {
		// Old way: self == .sent || self == .delivered || self == .read
		self >= .sent
	}
}
```

#### enum cases as protocol witnesses (SE-0280)

```
let error1 = JSONDecodingError.fileCorrupted
let error2 = JSONDecodingError.keyNotFound("shoeSize")

protocol DecodingError {
	static var fileCorrupted: Self { get }
	static func keyNotFound(_ key: String) -> Self
}

enum JSONDecodingError: DecodingError {
	case fileCorrupted
	case keyNotFound(_ key: String)
}

```

#### Apple archive

New archive file format (.aar files)
- optimized for multi-threaded compression and access

```
import AppleArchive

try ArchiveByteStream.withFileStram(
	path: "/tmp/photos.aar",
	mode: .writeOnly,
	options: [.create, .truncate],
	permissions: [.ownerReadWrite, .groupRead, otherRead]
) { file in
	try ArchiveByteStream.withCompressionStream(using: .lzfse, writingTo: file) { compressor in
		try ArchiveStream.withEncodedStream(writingTo: compressor) { encode in
			try encoder.writeDirectoryContents(
				archiveFrom: source,
				keySet: fieldKeySet
			)
		}
	}
}
```

#### Swift system
- idiomatic Swift interfaces to system calls
- low-level currency types
- -> less `UnsafePointer<CChar>`!

##### Was:
```
public func open(
	_ path: UnsafePointer<CChar>,
	_ oflag: Int32,
	_ mode: mode_t
) -> Int32
```

#### Becomes:

```
extension FileDescriptor: RawRepresentable {
	public static func open (
		_ path: FilePath,
		_ mode: FileDescriptor.AccessMode,
		options: FileDescriptor.OpenOptions = FileDescriptor.OpenOptions(),
		permissions: FilePermissions? = nil
	) throws -> FileDescriptor
}
```

#### OSLog

old:

```
logger.log("order received from \(name)")
logger.log("ordered smoothie \(smoothiename, privacy: .public)")
```

new:

```
logger.log("\(offerId, align: .left(columns: 10), privacy: .public)")
logger.log("\(seconds, format: .fixed(precision: 2)) seconds")
```

#### Packages

- [Swift numerics](https://github.com/apple/swift-numerics)
   - basic math functions for generic contexts
- [Swift ArgumentParser](https://github.com/apple/swift-argument-parser)
- [Swift StandardLibraryPreview](https://github.com/apple/swift-standard-library-preview)
   - early access to upcoming Swift features
   - like Python's `import from future`

```
import StandardLibraryPreview

var a = [1, 2, 3, 4, -3, -4, 23, -5, 13, 15]
let negs = a.subranges { $0 < 0 }
a.moveSubranges(negs, to: 0)
// [-3, -4, -5, 1, 2, 3, 4, 23, 13, 15]
```
