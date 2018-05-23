import Foundation
import XcodeEdit

typealias ModuleName = String

extension XCBuildConfiguration {
    var moduleName: String? {
        if let name = self.buildSettings["PRODUCT_NAME"] as? String,
            !name.hasPrefix("$(TARGET_NAME") {
            return name
        }
        return nil
    }
}

struct Xcodeproj {
    private let projectFile: XCProjectFile

    init(path: Path) throws {
        let projectFile: XCProjectFile
        // Parse project file
        do {
            do {
                projectFile = try XCProjectFile(xcodeprojURL: path.url)
            }
            catch _ as ProjectFileError {
                projectFile = try XCProjectFile(xcodeprojURL: path.url, ignoreReferenceErrors: true)
            }
        }
        catch {
            throw ModuleSearchError.parsingFailed("Parse projectFile of \"\(path.url)\" failed. check out you input the right path")
        }

        self.projectFile = projectFile
    }
    
    func resourcePathsForModules(inputInfo: InputInfo) throws -> [ModuleName : [XPath]] {
        
        let allTargets = projectFile.project.targets.flatMap { $0.value }
        var moduleMap: [ModuleName : [XcodeEdit.Path]] = [:]
        
        targetLoop: for target in allTargets {
            
            var moduleName: ModuleName = ""
            
            if let buildConfiguration = target.buildConfigurationList.value?.buildConfigurations.first,
                let name = buildConfiguration.value?.moduleName {
                moduleName = name
            } else {
                moduleName = target.name
            }
            
            if inputInfo.excludes._contains(moduleName) {
                continue
            }
            
            if !inputInfo.includes.isEmpty
                && !inputInfo.includes._contains(moduleName) {
                continue
            }
            
            let resourcesFileRefs = target.buildPhases
                .flatMap { $0.value as? PBXSourcesBuildPhase }
                .flatMap { $0.files }
                .flatMap { $0.value?.fileRef }
            
            let fileRefPaths = resourcesFileRefs
                .flatMap { $0.value as? PBXFileReference }
                .flatMap { $0.fullPath }
            
            let variantGroupPaths = resourcesFileRefs
                .flatMap { $0.value as? PBXVariantGroup }
                .flatMap { $0.fileRefs }
                .flatMap { $0.value?.fullPath }
            
            let paths = fileRefPaths + variantGroupPaths
            
            moduleMap[moduleName] = paths
            
            // Log
            Log(moduleName, .debug)
        }
        
        return moduleMap
    }
}

extension Array where Element == String {
    func _contains(_ element: String) -> Bool {
        if self.contains(element) { return true }
        let array = self.flatMap{ match($0, content: element) }
        return !array.isEmpty
    }
    
    func match(_ pattern: String, content: String) -> [String] {
        return RegularMatcher.match(pattern, content: content)
    }
}
