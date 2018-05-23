import Foundation
import PathKit


public var logLevel: LogLevel = .debug

public func Log<T>(_ message:T, _ level: LogLevel = .debug,
                   file:String = #file,
                   function:String = #function,
                   line:Int = #line) {

    if logLevel == .none { return }
    Logger.shared.log(message, level: level, file: file, function: function, line: line)
}


public enum LogLevel: Int {
    case none = 0
    case verbose
    case debug
    case info
    case warn
    case error
    case logToFile
}

let logURL = Path.current + "ModuleLog.txt"

struct Logger {

    static let shared = Logger()
    let dformatter: DateFormatter

    private init() {
        dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }

    func log<T>(_ message:T, level: LogLevel, file:String = #file, function:String = #function,
                line:Int = #line) {

        let fileName = (file as NSString).lastPathComponent

        let consoleStr = "\(fileName):\(line) \(function) | \(message)"
        let datestr = dformatter.string(from: Date())
        let info = "\(datestr) \(consoleStr)"

        logLevel.rawValue < level.rawValue
        ? print(info)
        : ()

        logLevel == .logToFile || level == .logToFile
        ? appendText(fileURL: logURL.url, string: info)
        : ()
    }

    func appendText(fileURL: URL, string: String) {
        print(string)
        do {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
            }

            let fileHandle = try FileHandle(forWritingTo: fileURL)
            let stringToWrite = "\n" + string

            fileHandle.seekToEndOfFile()
            fileHandle.write(stringToWrite.data(using: String.Encoding.utf8)!)

        } catch let error as NSError {
            print("failed to append: \(error) -- Log error")
        }
    }
}
