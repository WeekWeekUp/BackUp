import Foundation

enum RegPatterns: String {
    //(class)[^\{]*?:[^\{]*?(?=ModuleLifeCycleEntry)
    case lifeCyclePattern = "(class)[^\\{]*?:[^\\{]*?(?=ModuleLifeCycleEntry)"
    //[\s\S]+:
    case classPattern = "[\\s\\S]+:"
    //[\w\d]+
    case resultPattern = "[\\w\\d]+"
}

struct Searcher {
    static func search(in content: String, module: String) -> [String] {

        let lifeCycles = searchLifeCycles(in: content, module: module)

        return lifeCycles
    }


    static func searchLifeCycles(in content: String, module: String) -> [String] {
        var result = [String]()

        let lifeCycleClass = match(.lifeCyclePattern, content: content)

        result = lifeCycleClass.flatMap{ match(.classPattern, content: $0).last }
        
        result = result.flatMap{ match(.resultPattern, content: $0).last }

        result = result.map{ [module, $0].joined(separator: ".") }

        return result
    }


    static func match(_ pattern: RegPatterns, content: String) -> [String] {
        return RegularMatcher.match(pattern.rawValue, content: content)
    }
}


struct RegularMatcher {
    static func match(_ pattern: String, content: String) -> [String] {
        
        let nsstring = NSString(string: content)
        var result: [String] = []
        
        let reg: NSRegularExpression
        do {
            reg = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } catch {
            return []
        }
        
        let matches = reg.matches(in: content, options: [], range: content.fullRange)
        
        for checkingResult in matches {
            let extracted = nsstring.substring(with: checkingResult.range(at: 0))
            
            result.append(extracted)
        }
        return result
    }
}





