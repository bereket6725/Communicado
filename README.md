# Communicado

#### Are you tired of rewriting the same sharing code over and over again?

![](gifs/cartman.gif)

#### So am I!

![](gifs/homer.gif)

#### That's why I wrote Communicado!

Communicado is the simplest way to share using iOS built in methods. If you use this correctly, you'll end up with a whole lot more time to sleep.

![](gifs/kitty.gif)

#### Let's show you how it's done.

The first thing to know is the available methods for sharing.

```swift
public enum ShareDestination {

    case text(parameters: TextShareParameters)
    case email(parameters: MailShareParameters)
    case twitter(parameters: SocialShareParameters)
    case facebook(parameters: SocialShareParameters)
    case sinaWeibo(parameters: SocialShareParameters)
    case tencentWeibo(parameters: SocialShareParameters)
    case pasteboard(parameters: PasteboardShareParameters)
    case photos(parameters: PhotosShareParameters)
    case activityController(parameters: ActivityShareParameters)

}
```

Each sharing destination takes in parameters. Let's try a simple example.

```swift
let attachment = MessageAttachment(attachmentType: "image/png", filename: "heart.png", data: heartImageData)
let textParameters = TextShareParameters(message: "I love my users.", attachments: [ attachment ])
let textDestination = ShareDestination.text(parameters: textParameters)
```

Now let's call the **ONLY** method that's even available to you.

```swift
self.share(destination: textDestination)
```

And we're done! If everything went well, you can send a text with that wonderful heart image to all your favorite users.

Now all you can try this for all the kinds of sharing that you'd like to use in your app!

![](gifs/yay.gif)

## Installation
You can use CocoaPods to install Anchorman by adding it to your Podfile:

```swift
platform :ios, '9.0'
pod 'Communicado'
```

Or install it manually by downloading Anchorman.swift and dropping it in your project.


## About me

Hi, I'm [Joe](http://fabisevi.ch) everywhere on the web, but especially on [Twitter](https://twitter.com/mergesort).

## License

See the [license](LICENSE) for more information about how you can use Anchorman. I promise it's not GPL, because I am not "that guy".

## The end?

Yes, this is the end. Hopefully Communicado makes your life easier. It probably won't help you pay your rent, but it might make it easier to share in your app.
