import SwiftUI
import Foundation

struct SDKDownload: View {
    @State private var sdks: [String] = ["9.3","10.3","11.4","12.4","13.7","14.5","15.6","16.5"]
    @State private var listid: UUID = UUID()
    var body: some View {
        List {
            ForEach(sdks, id:\.self) { item in
                if !FileManager.default.fileExists(atPath: "\(global_sdkpath)/iPhoneOS\(item).sdk") {
                    Button( action: {
                        download(item)
                    }) {
                        Label("iOS \(item)", systemImage: "arrow.down")
                    }
                } else {
                    Button( action: {
                        remove(item)
                    }) {
                        Label("iOS \(item)", systemImage: "trash.fill")
                    }
                }
            }
        }
        .navigationTitle("SDK Hub")
        .navigationBarTitleDisplayMode(.inline)
        .id(listid)
    }
    private func download(_ sdk: String) {
        DispatchQueue.global(qos: .utility).async {
            ShowAlert(UIAlertController(title: "Downloading SDK", message: "", preferredStyle: .alert))
            cfolder(atPath: "\(global_sdkpath)")
            fdownload("https://polcom.de/sdk/iOS\(sdk).zip", "tmp/sdk.zip")
            if shell("unzip '\(global_container)/tmp/sdk.zip' -d '\(global_sdkpath)/iPhoneOS\(sdk).sdk'") != 0 {
                // back then we did ran download tasks unnecessarily as root
                shell("chown mobile \(global_sdkpath)", uid: 0)
                shell("unzip '\(global_container)/tmp/sdk.zip' -d '\(global_sdkpath)/iPhoneOS\(sdk).sdk'")
            }
            rm("\(global_container)/tmp/sdk.zip")
            listid = UUID()
            DismissAlert()
        }
    }
    private func remove(_ sdk: String) {
        if sdk == "/" {
            return
        }
        DispatchQueue.global(qos: .utility).async {
            ShowAlert(UIAlertController(title: "Removing SDK", message: "", preferredStyle: .alert))
            // some people might have downloaded SDKs in the past that got unnecessarily stored as root
            if rm("\(global_sdkpath)/iPhoneOS\(sdk).sdk") != 0 {
                shell("rm -rf \(global_sdkpath)/iPhoneOS\(sdk).sdk", uid: 0)
            }
            listid = UUID()
            DismissAlert()
        }
    }
}
