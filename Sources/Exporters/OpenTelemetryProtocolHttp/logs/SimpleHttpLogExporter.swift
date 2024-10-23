//
// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0
// 

import Foundation
import OpenTelemetryProtocolExporterCommon
import OpenTelemetrySdk
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Simple Otlp Http log exporter that exports logs synchrously. Exports the given log records and returns export status after the network call is complete.
public class SimpleHttpLogExporter: OtlpHttpExporterBase, LogRecordExporter {
    override public init(endpoint: URL = defaultOltpHttpLoggingEndpoint(),
                         config: OtlpConfiguration = OtlpConfiguration(),
                         useSession: URLSession? = nil,
                         envVarHeaders: [(String, String)]? = EnvVarHeaders.attributes) {
        super.init(endpoint: endpoint, config: config, useSession: useSession, envVarHeaders: envVarHeaders)
    }

    public func export(logRecords: [OpenTelemetrySdk.ReadableLogRecord], explicitTimeout: TimeInterval? = nil) -> OpenTelemetrySdk.ExportResult {
        let sendingLogRecords: [ReadableLogRecord] = logRecords

        let body = Opentelemetry_Proto_Collector_Logs_V1_ExportLogsServiceRequest.with { request in
            request.resourceLogs = LogRecordAdapter.toProtoResourceRecordLog(logRecordList: sendingLogRecords)
        }

        var exportResult: ExportResult = .success
        let semaphore = DispatchSemaphore(value: 0)
        var request = createRequest(body: body, endpoint: endpoint)
        if let headers = envVarHeaders {
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }

        } else if let headers = config.headers {
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        request.timeoutInterval = min(explicitTimeout ?? TimeInterval.greatestFiniteMagnitude, config.timeout)
        httpClient.send(request: request) { result in
            switch result {
            case .success:
                exportResult = .success
            case let .failure(error):
                print(error)
                exportResult = .failure
            }
            semaphore.signal()
        }
        semaphore.wait()

        return exportResult
    }

    public func forceFlush(explicitTimeout: TimeInterval? = nil) -> ExportResult {
        flush(explicitTimeout: explicitTimeout)
    }

    public func flush(explicitTimeout: TimeInterval? = nil) -> ExportResult {
        return .success
    }
}

