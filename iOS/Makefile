.PHONY: bundle
bundle:
	bundle install --path vendor/bundle

.PHONY: pods
pods:
	bundle exec pod install

.PHONY: pods-update
pods:
	bundle exec pod install --repo-update

.PHONY: clean
clean:
	rm -rf Pods
