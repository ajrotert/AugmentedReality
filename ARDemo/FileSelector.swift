import UIKit

extension ViewController : UIDocumentPickerDelegate,UINavigationControllerDelegate {

    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        self.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("filename: " + url.path.split(separator: "/").last!)
        print("Rel Path: " + url.relativePath)
        print("Rel String: " + url.relativeString)
        print("URL Path: " + url.path)
        print("Path: " + url.standardizedFileURL.absoluteString)
        
        if(!url.path.lowercased().contains(".obj") && !url.path.lowercased().contains(".dae") && !url.path.lowercased().contains(".usdz") && !url.path.lowercased().contains(".usda") && !url.path.lowercased().contains(".usd") && !url.path.lowercased().contains(".usdc") && !url.path.lowercased().contains(".abc") && !url.path.lowercased().contains(".ply") && !url.path.lowercased().contains(".stl") && !url.path.lowercased().contains(".scn") ){
            print("Multiple files selected")
            
            var urlpath = url.deletingLastPathComponent()
            let fileManager = FileManager.default
            
            do{
            let files = try fileManager.contentsOfDirectory(atPath: urlpath.path)
                for file in files{
                    if(file.lowercased().contains(".dae") || file.lowercased().contains(".usdz") || file.lowercased().contains(".usda") || file.lowercased().contains(".usd") || file.lowercased().contains(".usdc") || file.lowercased().contains(".abc") || file.lowercased().contains(".ply") || file.lowercased().contains(".stl") || file.lowercased().contains(".scn") || file.lowercased().contains(".obj"))
                    {
                        urlpath.appendPathComponent(file)
                        print("New URL: ", urlpath.path)
                    }
                    addObject(urlpath: urlpath)
                }
            }
            catch{
                print("File Selection Error: \(error)")
            }
            
        }
        else{
            addObject(urlpath: url)
        }

    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        hidePlaceholder(isHidden: true)
        dismiss(animated: true, completion: nil)
    }
}
