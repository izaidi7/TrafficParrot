set -xe
helm init --service-account tiller \
	--history-max 200 \
	--override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' \
	--output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -
