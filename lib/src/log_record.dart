// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';

import 'level.dart';
import 'logger.dart';

/// A log entry representation used to propagate information from [Logger] to
/// individual handlers.
class LogRecord {
  final Level level;
  final String message;

  /// Non-string message passed to Logger.
  final Map<String, dynamic>? object;

  /// Logger where this record is stored.
  final String loggerName;

  /// Time when this record was created.
  final DateTime time;

  /// Unique sequence number greater than all log records created before it.
  final int sequenceNumber;

  static int _nextNumber = 0;

  /// Associated error (if any) when recording errors messages.
  final Object? error;

  /// Associated stackTrace (if any) when recording errors messages.
  final StackTrace? stackTrace;

  /// Zone of the calling code which resulted in this LogRecord.
  final Zone? zone;

  final Duration? duration;

  final String host = Platform.localHostname;

  String environment = const bool.fromEnvironment('dart.vm.product') ? 'production' : 'debug';

  LogRecord(
    this.level,
    this.message,
    this.loggerName, [
    this.error,
    this.stackTrace,
    this.zone,
    this.object,
    this.duration,
  ])  : time = DateTime.now(),
        sequenceNumber = LogRecord._nextNumber++;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'time': time.toIso8601String(),
        'level': level.name,
        if (duration != null) 'duration_ms': duration?.inMilliseconds,
        'message': message,
        if (object != null) 'payload': object,
        'host': host,
        'environment': environment,
        'name': loggerName,
        if (error != null) 'error': error,
        if (stackTrace != null) 'stack_trace': stackTrace,
      };

  @override
  String toString() {
    final nf = NumberFormat('##0.000', 'en_US');

    var localDuration = duration != null ? 'z(${nf.format(duration!.inMicroseconds / 1000).padLeft(10)}ms)' : null;
    var localObject = object != null ? const JsonEncoder.withIndent('  ').convert(object) : '';

    return [
      time.toIso8601String(),
      level.name.substring(0, 1),
      if (localDuration != null) localDuration,
      loggerName,
      '-- $message --',
      localObject,
    ].join(' ');
  }
}
