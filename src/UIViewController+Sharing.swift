//
//  Sharing
//  Copyright © 2016 Snarkbots. All rights reserved.
//

import UIKit

import MessageUI
import Social
import ObjectiveC.runtime


// MARK: MessageAttachment

public class MessageAttachment {

    let attachmentType: String
    let filename: String
    let data: NSData

    init(attachmentType: String, filename: String, data: NSData) {
        self.attachmentType = attachmentType
        self.filename = filename
        self.data = data
    }

}


// MARK: SharingCompletedEvent

typealias SharingCompletedEvent = ((success: Bool, sharingService: String) -> ())


// MARK: Extension

public extension UIViewController {

    func canShareViaText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }

    func canShareViaEmail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }

    func canShareViaTwitter() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
    }

    func canShareViaFacebook() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
    }

    func canShareViaSinaWeibo() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeSinaWeibo)
    }

    func canShareViaTencentWeibo() -> Bool {
        return SLComposeViewController.isAvailableForServiceType(SLServiceTypeTencentWeibo)
    }

    func shareViaActivityController(activityItems: [AnyObject], excludedActivityTypes: [String]?, applicationActivites: [UIActivity]?, completionItemsHandler:((activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) -> ())?) {
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivites)
        activityController.excludedActivityTypes = excludedActivityTypes

        activityController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if let completionItemsHandler = completionItemsHandler {
                completionItemsHandler(activityType: activityType, completed: completed, returnedItems: returnedItems, activityError: activityError)
            }

            let sharingService = activityType ?? UIViewController.cancelledSharingService
            self.sharingCompleted?(success: (completed && activityError == nil), sharingService: sharingService)
        }

        self.presentViewController(activityController, animated: true, completion: nil)
    }

    func shareViaTextMessage(message: String?, attachments:[MessageAttachment]?) {
        if self.canShareViaText() {
            let messageController = MFMessageComposeViewController()
            messageController.messageComposeDelegate = self
            messageController.body = message

            if let attachments = attachments {
                for attachment in attachments {
                    messageController.addAttachmentData(attachment.data, typeIdentifier: attachment.attachmentType, filename: attachment.filename)
                }
            }

            if let titleTextAttributes = self.sharingTitleTextAttributes {
                messageController.navigationBar.titleTextAttributes = titleTextAttributes
            }

            if let barButtonItemTintColor = self.sharingBarButtonItemTintColor {
                messageController.navigationBar.tintColor = barButtonItemTintColor
            }

            self.presentViewController(messageController, animated: true, completion: nil)
        } else {
            self.sharingCompleted?(success: false, sharingService: UIViewController.textMessageSharingService)
        }
    }

    func shareViaEmailWithSubject(subject: String?, message: String?, isHTML: Bool, toRecepients:[String]?, ccRecepients:[String]?, bccRecepients:[String]?, attachments:[MessageAttachment]?) {
        if self.canShareViaEmail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self;
            mailController.setSubject(subject ?? "")
            mailController.setMessageBody(message ?? "", isHTML: isHTML)
            mailController.setToRecipients(toRecepients)
            mailController.setCcRecipients(ccRecepients)
            mailController.setBccRecipients(bccRecepients)

            if let attachments = attachments {
                for attachment in attachments {
                    mailController.addAttachmentData(attachment.data, mimeType: attachment.attachmentType, fileName: attachment.filename)
                }
            }

            if let titleTextAttributes = self.sharingTitleTextAttributes {
                mailController.navigationBar.titleTextAttributes = titleTextAttributes
            }

            if let barButtonItemTintColor = self.sharingBarButtonItemTintColor {
                mailController.navigationBar.tintColor = barButtonItemTintColor
            }

            self.presentViewController(mailController, animated: true, completion: nil)
        } else {
            self.sharingCompleted?(success: false, sharingService: UIViewController.emailSharingService)
        }
    }

    func shareViaFacebook(message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if self.canShareViaFacebook() {
            self.shareViaSLComposeViewController(SLServiceTypeFacebook, message: message, images: images, URLs: URLs)
        } else {
            self.sharingCompleted?(success: false, sharingService: SLServiceTypeTwitter)
        }
    }

    func shareViaTwitter(message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if self.canShareViaTwitter() {
            self.shareViaSLComposeViewController(SLServiceTypeTwitter, message: message, images: images, URLs: URLs)
        } else {
            self.sharingCompleted?(success: false, sharingService: SLServiceTypeTwitter)
        }
    }

    func shareViaSinaWeiboWithMessage(message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if self.canShareViaSinaWeibo() {
            self.shareViaSLComposeViewController(SLServiceTypeTwitter, message: message, images: images, URLs: URLs)
        } else {
            self.sharingCompleted?(success: false, sharingService: SLServiceTypeSinaWeibo)
        }
    }

    func shareViaTencentWeiboWithMessage(message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if self.canShareViaTencentWeibo() {
            self.shareViaSLComposeViewController(SLServiceTypeTwitter, message: message, images: images, URLs: URLs)
        } else {
            self.sharingCompleted?(success: false, sharingService: SLServiceTypeTencentWeibo)
        }
    }

    func shareViaCopyString(string: String?) {
        UIPasteboard.generalPasteboard().string = string
    }

    func shareViaCopyURL(URL: NSURL?) {
        UIPasteboard.generalPasteboard().URL = URL
    }

}

private extension UIViewController {

    private static let textMessageSharingService = "com.apple.UIKit.activity.Message"
    private static let emailSharingService = "com.apple.UIKit.activity.Mail"
    private static let cancelledSharingService = "com.plugin.cancelled"

    func shareViaSLComposeViewController(network: String, message: String?, images: [UIImage]?, URLs: [NSURL]?) {
        if SLComposeViewController.isAvailableForServiceType(network) {
            let composeController = SLComposeViewController(forServiceType: network)
            composeController.setInitialText(message)

            if let URLs = URLs {
                for URL in URLs {
                    composeController.addURL(URL)
                }
            }

            if let images = images {
                for image in images {
                    composeController.addImage(image)
                }
            }

            composeController.completionHandler = { result in
                if let sharingCompleted = self.sharingCompleted {
                    sharingCompleted(success: (result == SLComposeViewControllerResult.Done), sharingService: network)
                }

                self.dismissViewControllerAnimated(true, completion: nil)
            }

            self.presentViewController(composeController, animated: true, completion: nil)
        }
    }

}

extension UIViewController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)

        self.sharingCompleted?(success: (result == MFMailComposeResultSent || result == MFMailComposeResultSaved), sharingService: UIViewController.emailSharingService)
    }

}

extension UIViewController: MFMessageComposeViewControllerDelegate {

    public func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)

        self.sharingCompleted?(success: (result == MessageComposeResultSent), sharingService: UIViewController.textMessageSharingService)
    }

}


// MARK: Associated objects

extension UIViewController {

    private struct AssociatedObjectKeys {
        static var sharingBarButtonItemTintColor = "UIViewController.sharingBarButtonItemTintColor"
        static var sharingBarTintColor = "UIViewController.sharingBarTintColor"
        static var sharingTitleTextAttributes = "UIViewController.sharingTitleTextAttributes"
        static var sharingCompleted = "UIViewController.sharingCompleted"
    }

    var sharingBarButtonItemTintColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingBarButtonItemTintColor) as? UIColor
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingBarButtonItemTintColor, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    var sharingTitleTextAttributes: [ String : NSObject ]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingTitleTextAttributes) as? [ String : NSObject ]
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingTitleTextAttributes, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    var sharingCompleted: SharingCompletedEvent? {
        get {
            if let box = objc_getAssociatedObject(self, &AssociatedObjectKeys.sharingCompleted) as? SharingBox {
                return box.event
            }

            return nil;
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKeys.sharingCompleted, SharingBox(event: value), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

}


// MARK: Boxing so we can store the sharingCompleted closure on UIViewController

private class SharingBox {

    var event: SharingCompletedEvent

    init(event: SharingCompletedEvent) {
        self.event = event
    }

}