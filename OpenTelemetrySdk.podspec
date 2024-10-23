Pod::Spec.new do |spec|
  spec.name = "OpenTelemetrySdk"
  spec.version = "1.10.1"
  spec.summary = "Swift OpenTelemetrySDK"

  spec.homepage = "https://github.com/open-telemetry/opentelemetry-swift"
  spec.documentation_url = "https://opentelemetry.io/docs/languages/swift"
  spec.license = { :type => "Apache 2.0", :file => "LICENSE" }
  spec.authors = "OpenTelemetry Authors"

  spec.source = { :git => "https://github.com/open-telemetry/opentelemetry-swift.git", :tag => spec.version.to_s }
  spec.source_files = "Sources/OpenTelemetrySdk/**/*.swift"

  spec.swift_version = "5.9"
  spec.ios.deployment_target = "13.0"
  spec.tvos.deployment_target = "13.0"
  spec.watchos.deployment_target = "6.0"

  spec.dependency 'OpenTelemetryApi', spec.version.to_s
end