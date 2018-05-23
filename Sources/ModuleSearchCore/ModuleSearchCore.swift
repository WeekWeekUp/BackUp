import Foundation
import PathKit
import Commander
import XcodeEdit

public typealias Path = PathKit.Path
public typealias XPath = XcodeEdit.Path


public struct ModuleSearchCore {
    public static func run(_ inputInfo: InputInfo) throws {
        var lifeCycleArray = [String]()
        
        let podsproj = try Xcodeproj(path: inputInfo.podsProjPath)
        let xcodeproj = try Xcodeproj(path: inputInfo.xcodeprojPath)

        let podsMap = try resourceMap(proj: podsproj, inputInfo: inputInfo, isPods: true)
        let projMap = try resourceMap(proj: xcodeproj, inputInfo: inputInfo, isPods: false)

        lifeCycleArray.append(contentsOf: podsMap)
        lifeCycleArray.append(contentsOf: projMap)

        lifeCycleArray = Array(Set(lifeCycleArray))

        let plistMap = lifeCycleArray as NSArray
        plistMap.write(to: inputInfo.outputPath.url, atomically: true)

        // Log
        Log("output dir ---->", .debug)
        Log(inputInfo.outputPath.url, .debug)
    }

    
    static func resourceMap(proj: Xcodeproj, inputInfo: InputInfo, isPods: Bool) throws -> [String] {
        var shouldRegisterMap = [String]()
        let resourceMap = try proj.resourcePathsForModules(inputInfo: inputInfo)
        

        for obj in resourceMap {

            let resourceURLs = obj.value
                .map{ path in path.url(with: isPods ?
                    inputInfo.urlForPodsSourceTreeFolder
                    : inputInfo.urlForSourceTreeFolder) }
                .flatMap { $0 }
                .filter{ $0.description.hasSuffix(".swift") }

            let holdModuleName = obj.key

            let searchMap = try search(resourceURLs: resourceURLs, module: holdModuleName)

            shouldRegisterMap.append(contentsOf: searchMap)

            // Log
            Log("all module service that should be registered", .debug)

            Log("all resources ---------", .verbose)
            resourceURLs.forEach{
                Log($0, .verbose)
            }
        }
        return shouldRegisterMap
    }


    static func search(resourceURLs: [URL], module: String) throws -> [String] {
        var result = [String]()
        for resouceURL in resourceURLs {
            let content = try String(contentsOf: resouceURL, encoding: .utf8)
            let map = Searcher.search(in: content, module: module)

            result.append(contentsOf: map)
        }
        return result
    }
}




