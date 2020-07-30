import Foundation

/// Read text file line by line in efficient way
public class LineReader {
	public let path: String

    private let file: UnsafeMutablePointer<FILE>

	init?(path: String) {
        self.path = path
        guard let file = fopen(path, "r") else {
            return nil
        }
        self.file = file
	}

	public var nextLine: String? {
		var line: UnsafeMutablePointer<CChar>? = nil
		var linecap = 0
		defer { free(line) }
        let status = getline(&line, &linecap, file)
        guard status > 0, let unwrappedLine = line else { return nil }
        return String(cString: unwrappedLine)
	}

	deinit { fclose(file) }
}

extension LineReader: Sequence {
	public func  makeIterator() -> AnyIterator<String> {
		return AnyIterator<String> {
			return self.nextLine
		}
	}
}
