import Foundation

public enum ModuleSearchError: Error {
    case parsingFailed(String)
    case missingArgument(String)
}
