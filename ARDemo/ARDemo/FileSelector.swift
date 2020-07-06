import UIKit

extension ViewController : UIDocumentPickerDelegate,UINavigationControllerDelegate {

    // MARK: DocumentPicker Delegates
    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        self.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        //url returned is the last file to be selected by the user. Since multiple files can be selected they are loaded into a temp directory, NSTempDirectory(). If the url returned is not a supported file, we traverse the directory and load the model if a supported file is found. If only one file is selected, or the last file selected is a supported file, then the model is loaded from the inital url returned.
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
                        addObject(urlpath: urlpath)
                        break
                    }
                }
                addObject(urlpath: urlpath)
            }
            catch{
                print("File Selection Error: \(error)")
                hidePlaceholder(isHidden: true)
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
