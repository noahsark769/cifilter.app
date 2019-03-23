# CIFilter.io
CIFilter.io is a project which documents parameters and examples for every [CIFilter](https://developer.apple.com/documentation/coreimage/cifilter) available on iOS and macOS as part of [CoreImage](https://developer.apple.com/documentation/coreimage).

The project has two components:

1. A website, [CIFilter.io](https://cifilter.io) which allows searching/filtering the CIFilters and viewing their documentation. It also provides examples of inputs and outputs for commonly used filters.
2. An iOS app which allows you to apply each CIFilter with arbitrary parameters and save the output images.

The website is publically available and free, and I intend to continue to update it as new filters are added in each new iOS and macOS release. The iOS app is available in this repo as an open source project as well. If you'd like to support this project and others like it, you can download the app from the app store 🙏

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
The website lives in the `web` folder of this repo. To start a local [Gatsby](https://www.gatsbyjs.org/) server:

```
cd web
npm install
make develop
```

## Questions?
Don't hesitate to reach out [on Twitter](https://twitter.com/noahsark769) 👋
