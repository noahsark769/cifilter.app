<img src="https://github.com/noahsark769/cifilter.io/raw/master/iOS/CIFilter.io/Resources/AppIcon/icon_60pt%403x.png" height="200">

# CIFilter.app
CIFilter.app is a project which documents parameters and examples for every [CIFilter](https://developer.apple.com/documentation/coreimage/cifilter) available on iOS and macOS as part of [CoreImage](https://developer.apple.com/documentation/coreimage).

> This project used to be called cifilter.io, but due to some shennanigans with the domain registration I had to change the URL 😅

The project has two components:

1. A website, [CIFilter.app](https://cifilter.app), which allows searching/filtering the CIFilters and viewing their documentation. It also provides examples of inputs and outputs for commonly used filters.
2. An iOS app which allows you to apply each CIFilter with arbitrary parameters and save the output images.

The website is publically available and free, and I intend to continue to update it as new filters are added in each new iOS and macOS release. The iOS app is available in this repo as an open source project as well. If you'd like to support this project and others like it, you can download the app from the app store 🙏

More information about the project is available in [this blog post](https://noahgilmore.com/blog/cifilterio/).

## Reporting issues
If you find something wrong with the website or app, please report an issue via GitHub.

## Contributing
If you'd like to implement a new feature, please open an issue first so we can discuss it. I'm happy to accept pull requests which improve the quality of this project 💪

## Developing

### iOS
The iOS app lives in the `iOS` folder of this repo. To build:

```
cd iOS
virtualenv venv
source venv/bin/activate
pre-commit install
make bundle
make pods
bundle exec pod keys set "SentryAuthToken" ""
bundle exec pod keys set "SENTRY_DSN" ""
bundle exec pod keys set "MixpanelToken" ""
```

You'll then need to open the Xcode workspace and set the signing team to your personal team. After that, you should be able to build the app.

### Web
The website lives in the `web` folder of this repo. To start a local [Gatsby](https://www.gatsbyjs.org/) server (needs Node 14):

```
cd web
npm install
npm start
```

### Building for older devices
The CIFilter.io app intends to support only the current version of iOS. However, if you'd like to build the app yourself using the commit compatible with a given iOS version, you can use the following branches:

- iOS 12: `compatibility/ios-12`

## Questions?
Don't hesitate to reach out [on Twitter](https://twitter.com/noahsark769) 👋
