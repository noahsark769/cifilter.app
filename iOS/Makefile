.PHONY: bundle
bundle: Gemfile Gemfile.lock
	bundle install --path vendor/bundle

.PHONY: pods
pods: bundle Podfile Podfile.lock
	bundle exec pod install

.PHONY: pods-update
pods-update:
	bundle exec pod install --repo-update

.PHONY: clean
clean:
	rm -rf Pods

.PHONY:
testflight:
	bundle exec fastlane testflight
