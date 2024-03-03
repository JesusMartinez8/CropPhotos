//
//  ViewController.swift
//  CropPhotos
//
//  Created by Jesus Martinez on 1/4/24.
//
import CropViewController
import UIKit
import MessageUI
import ContactsUI

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate, MFMessageComposeViewControllerDelegate, CNContactPickerDelegate
{
    var selectedContact: CNContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.darkGray
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        button.setTitle("Select To Edit Photo", for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        view.addSubview(button)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        
        button.center = view.center
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
       
        
    }
    
    @objc func didTapButton() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker,animated: true)
    }
    
    @objc func didTapSendButton(_ sender: UIButton) {
        guard let croppedImageView = view.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
              let croppedImage = croppedImageView.image else {
            return
        }

        // Create an array with the items you want to share
        let items: [Any] = ["Check out this image!", croppedImage]

        // Create an activity view controller
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // Exclude some activities if needed
        activityViewController.excludedActivityTypes = [
            .assignToContact,
        ]

        // Present the activity view controller
        present(activityViewController, animated: true, completion: nil)
    }

    
    func sendImage(_ image: UIImage, to contact: CNContact) {
        if MFMessageComposeViewController.canSendText() {
            let messageComposer = MFMessageComposeViewController()
            messageComposer.messageComposeDelegate = self
            messageComposer.body = "Check out this image!"

            if let imageData = image.jpegData(compressionQuality: 1.0) {
                messageComposer.addAttachmentData(imageData, typeIdentifier: "public.jpeg", filename: "image.jpg")
            }

            present(messageComposer, animated: true, completion: nil)
        } else {
            // Handle the case where the device is not able to send messages
            print("Device cannot send messages")
        }
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            // Store the selected contact
            selectedContact = contact

            // Get the cropped image
            guard let croppedImageView = view.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
                  let croppedImage = croppedImageView.image else {
                return
            }

            // Send the image to the selected contact
            sendImage(croppedImage, to: contact)
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true)
        
        showCrop(image: image)
    }
    
    func showCrop(image: UIImage){
        let vc = CropViewController(croppingStyle: .default, image: image)
        vc.aspectRatioPreset = .presetSquare
        vc.aspectRatioLockEnabled = true
        vc.doneButtonColor = .systemGreen
        vc.doneButtonColor = .systemMint
        vc.toolbarPosition = .top
        vc.doneButtonTitle = "Continue"
        vc.cancelButtonTitle = "Exit"
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated:true)
    }
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        
        cropViewController.dismiss(animated:true)
        print("Did crop")
        
        
        
        let imageView = UIImageView(frame: view.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        view.addSubview(imageView)
        
        let saveButton = UIButton(frame: CGRect(x: 175 , y: view.frame.height - 100, width: 200, height: 50))
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(UIColor.black, for: .normal)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        view.addSubview(saveButton)
        
        let sendButton = UIButton(frame: CGRect(x: 0 , y: view.frame.height - 100, width: 200, height: 50))
           sendButton.setTitle("Send", for: .normal)
           sendButton.setTitleColor(UIColor.black, for: .normal)
           sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
           view.addSubview(sendButton)
      
        
    }
    
    
    @objc func didTapSaveButton(_sender:UIButton){
        guard let croppedImageView = view.subviews.first(where: { $0 is UIImageView }) as? UIImageView,
              let croppedImage = croppedImageView.image else {
            return
            
           
        }
        
        UIImageWriteToSavedPhotosAlbum(croppedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
        dismiss(animated: true,completion: nil)
        
       
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully.")
            // Dismiss the current view controller
                   dismiss(animated: true, completion: {
                       // After dismissing, present the photo library again
                       let picker = UIImagePickerController()
                       picker.sourceType = .photoLibrary
                       picker.delegate = self
                       self.present(picker, animated: true)
                   })
        }
        
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true, completion: nil)
        }
    
}
