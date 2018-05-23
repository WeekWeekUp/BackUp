import Foundation
import XcodeEdit

enum ProjSource {
    case podsProj
    case xcodeProj
}

public struct InputInfo {
    let includes: [String]
    let excludes: [String]
    
    let outputPath: Path
    let xcodeprojPath: Path
    let podsRootPath: Path
    let podsProjPath: Path
    
    let buildProductsDirPath: Path
    let developerDirPath: Path
    let sourceRootPath: Path
    let sdkRootPath: Path

    public init(
        includes: [String],
        excludes: [String],
        outputPath: Path,
        xcodeprojPath: Path,
        podsRootPath: Path,
        podsProjPath: Path,

        buildProductsDirPath: Path,
        developerDirPath: Path,
        sourceRootPath: Path,
        sdkRootPath: Path
        ) {
        self.includes = includes
        self.excludes = excludes
        
        self.outputPath = outputPath
        self.xcodeprojPath = xcodeprojPath
        self.podsRootPath = podsRootPath
        self.podsProjPath = podsProjPath

        self.buildProductsDirPath = buildProductsDirPath
        self.developerDirPath = developerDirPath
        self.sourceRootPath = sourceRootPath
        self.sdkRootPath = sdkRootPath
    }


    func urlForSourceTreeFolder(_ sourceTreeFolder: SourceTreeFolder) -> URL {
        switch sourceTreeFolder {
        case .buildProductsDir:
            return buildProductsDirPath.url
        case .developerDir:
            return developerDirPath.url
        case .sdkRoot:
            return sdkRootPath.url
        case .sourceRoot:
            return sourceRootPath.url
        }
    }

    func urlForPodsSourceTreeFolder(_ sourceTreeFolder: SourceTreeFolder) -> URL {
        switch sourceTreeFolder {
        case .buildProductsDir:
            return buildProductsDirPath.url
        case .developerDir:
            return developerDirPath.url
        case .sdkRoot:
            return sdkRootPath.url
        case .sourceRoot:
            return podsRootPath.url
        }
    }
    
}
