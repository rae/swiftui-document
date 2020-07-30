import Foundation
import Cocoa

class StreamReader  {

	let encoding: UInt
	let chunkSize: Int
	var atEof = false
	var streamData: NSData!
	var fileLength: Int
	var urlRequest: NSMutableURLRequest
	var currentOffset: Int
	var streamResponse: NSString

	var fileHandle: NSFileHandle!
	let buffer: NSMutableData!
	let delimData: NSData!

	var reponseError: NSError?
	var response: NSURLResponse?

	init?(
		path: NSURL,
		delimiter: String = "\n",
		encoding: UInt = NSUTF8StringEncoding,
		chunkSize: Int = 10001000
	) {
	    self.chunkSize = chunkSize
	    self.encoding = encoding
	    self.currentOffset = 0
	    urlRequest = NSMutableURLRequest(URL: path)
	    streamData = NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse:&response, error:&reponseError)
	    streamResponse = NSString(data:streamData!, encoding:NSUTF8StringEncoding)!
	    self.fileLength = streamData.length

	    if streamData == nil {
	        println("LINK HAS NO CONTENT!!!!!")
	    }

		self.fileLength = streamResponse.length
	    self.buffer = NSMutableData(capacity: chunkSize)!

	    // Create NSData object containing the line delimiter:
	    delimData = delimiter.dataUsingEncoding(NSUTF8StringEncoding)!
	}

	deinit {
	    self.close()
	}

	/// Return next line, or nil on EOF.
	func nextLine() -> String? {
		guard !atEof, currentOffset < fileLength else { return nil }

	    var blockLength = buffer.length

	    var range = buffer.rangeOfData(
			delimData,
			options: NSDataSearchOptions(0),
			range: NSMakeRange(currentOffset, blockLength)
		)

	    while range.location == NSNotFound {
	        var nRange = NSMakeRange(currentOffset, chunkSize)
	        var tmpData = streamData.subdataWithRange(nRange)
	        currentOffset += blockLength
	        if tmpData.length == 0 {
	            // EOF or read error.
	            atEof = true
	            if buffer.length > 0 {
	                // Buffer contains last line in file (not terminated by delimiter).
	                let line = NSString(data: buffer, encoding: encoding)
	                buffer.length = 0
	                return line
	            }
	            // No more lines.
	            return nil
	        }
	        buffer.appendData(tmpData)
	        range = buffer.rangeOfData(delimData, options: NSDataSearchOptions(0), range: NSMakeRange(0, buffer.length))
	    }

		let line = NSString(
			data: buffer.subdataWithRange(NSMakeRange(0, range.location + 1)),
	        encoding: encoding
		)
	    buffer.replaceBytesInRange(
			NSMakeRange(0, range.location + range.length),
			withBytes: nil,
			length: 0
		)
	    if line!.containsString("\n"){
	        return line
	    }
	    else {
	        atEof == true
	        return nil
	    }
	}

	/// Start reading from the beginning of file.
	func rewind() -> Void {
	    //streamData.seekToFileOffset(0)
	    buffer.length = 0
	    atEof = false
	}

	/// Close the underlying file. No reading must be done after calling this method.
	func close() -> Void {
	    streamData = nil
	}
}

extension StreamReader: SequenceType {
	func generate() -> GeneratorOf<String> {
	    return GeneratorOf<String> {
	        return self.nextLine()
	    }
	}
}
