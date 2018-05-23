import Foundation
import ModuleSearchCore
import XcodeEdit
import Commander
import PathKit


extension ProcessInfo {
    func value(from current: String, name: String, key: String) throws -> String {
        if current != key { return current }
        guard let value = self.environment[key] else {
            throw ModuleSearchError.missingArgument(key)
        }
        return value
    }
}


struct EnvironmentKeys {
    static let xcodeproj = "PROJECT_FILE_PATH"
    static let podsRoot = "PODS_ROOT"
    static let productModuleName = "PRODUCT_MODULE_NAME"
    static let buildProductsDir = SourceTreeFolder.buildProductsDir.rawValue
    static let developerDir = SourceTreeFolder.developerDir.rawValue
    static let sourceRoot = SourceTreeFolder.sourceRoot.rawValue
    static let sdkRoot = SourceTreeFolder.sdkRoot.rawValue
}


struct CommanderOptions {
    static let includeModules = Option("include", default: "", flag: "i", description: "Add modules that should be include, comma seperated, can use regex")
    
    static let excludeModules = Option("exclude", default: "", flag: "e", description: "Add modules that should be excluded, comma seperated. can use regex")
    
    static let xcodeproj = Option("xcodeproj", default: EnvironmentKeys.xcodeproj, flag: "x", description: "Path to the xcodeproj file.")

    static let podsRoot = Option("podsRoot", default: EnvironmentKeys.podsRoot, flag: "p", description: "Path to the Pod file.")

    static let productModuleName = Option("productModuleName", default: EnvironmentKeys.productModuleName, description: "Product module name the R-file is generated for.")

    static let buildProductsDir = Option("buildProductsDir",default:  EnvironmentKeys.buildProductsDir, description: "Build products folder that Xcode uses during build.")

    static let developerDir = Option("developerDir", default: EnvironmentKeys.developerDir, description: "Developer folder that Xcode uses during build.")

    static let sourceRoot = Option("sourceRoot", default: EnvironmentKeys.sourceRoot, description: "Source root folder that Xcode uses during build.")
    
    static let sdkRoot = Option("sdkRoot", default: EnvironmentKeys.sdkRoot, description: "SDK root folder that Xcode uses during build.")
    
    static let outputDir = Option("outputDir", default: EnvironmentKeys.sourceRoot, description: "Output directory for the '\(outputName)' file.")
}


let generate = command(
    CommanderOptions.includeModules,
    CommanderOptions.excludeModules,
    CommanderOptions.xcodeproj,
    CommanderOptions.podsRoot,
    CommanderOptions.buildProductsDir,
    CommanderOptions.developerDir,
    CommanderOptions.sourceRoot,
    CommanderOptions.sdkRoot,
    CommanderOptions.outputDir
) { includes, excludes, xcodeproj, podsRoot, buildProductsDir, developerDir, sourceRoot, sdkRoot, outputDir in
    
    let inculdeModules = includes.components(separatedBy: ",").filter{ !$0.isEmpty }
    let excludeModules = excludes.components(separatedBy: ",").filter{ !$0.isEmpty }
    
    Log(inculdeModules, .debug)
    
    let info = ProcessInfo()

    let xcodeprojPath = try info.value(from: xcodeproj, name: "xcodeproj", key: EnvironmentKeys.xcodeproj)
    let podsRootPath = try info.value(from: podsRoot, name: "podsRoot", key: EnvironmentKeys.podsRoot)

    let buildProductsDirPath = try info.value(from: buildProductsDir, name: "buildProductsDir", key: EnvironmentKeys.buildProductsDir)
    let developerDirPath = try info.value(from: developerDir, name: "developerDir", key: EnvironmentKeys.developerDir)
    let sourceRootPath = try info.value(from: sourceRoot, name: "sourceRoot", key: EnvironmentKeys.sourceRoot)
    let sdkRootPath = try info.value(from: sdkRoot, name: "sdkRoot", key: EnvironmentKeys.sdkRoot)

    let outputPath = sourceRootPath

    let inputInfo = InputInfo(
        includes: inculdeModules,
        excludes: excludeModules,
        outputPath: Path(outputPath) + outputName,
        xcodeprojPath: Path(xcodeprojPath),
        podsRootPath: Path(podsRootPath),
        podsProjPath: Path(podsRootPath) + podsProj,
        buildProductsDirPath: Path(buildProductsDirPath),
        developerDirPath: Path(developerDirPath),
        sourceRootPath: Path(sourceRootPath),
        sdkRootPath: Path(sdkRootPath)
    )

    try ModuleSearchCore.run(inputInfo)
}


let group = Group()

group.addCommand("generate", "Generates \(outputName)", generate)
group.run()



