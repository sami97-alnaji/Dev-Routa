import 'dart:convert';

class IncrementalTextDecoder {
  final StringBuffer _buffer = StringBuffer();
  late final ByteConversionSink _sink = const Utf8Decoder(
    allowMalformed: true,
  ).startChunkedConversion(StringConversionSink.fromStringSink(_buffer));
  List<String> add(List<int> bytes) {
    _sink.add(bytes);
    return const <String>[];
  }

  String take() {
    final value = _buffer.toString();
    _buffer.clear();
    return value;
  }
}

/// Preserves UTF-8 code points split across arbitrary network chunks and emits
/// decoded text synchronously to protocol parsers.
class IncrementalUtf8Decoder {
  IncrementalUtf8Decoder() {
    _sink = const Utf8Decoder(allowMalformed: true).startChunkedConversion(
      StringConversionSink.fromStringSink(_DecodedStringSink(_decoded)),
    );
  }
  final List<String> _decoded = <String>[];
  late final ByteConversionSink _sink;
  String add(List<int> bytes) {
    _sink.add(bytes);
    final value = _decoded.join();
    _decoded.clear();
    return value;
  }

  String close() {
    _sink.close();
    final value = _decoded.join();
    _decoded.clear();
    return value;
  }
}

class _DecodedStringSink implements StringSink {
  _DecodedStringSink(this.values);
  final List<String> values;
  @override
  void write(Object? object) => values.add(object?.toString() ?? '');
  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) =>
      values.add(objects.join(separator));
  @override
  void writeCharCode(int charCode) => values.add(String.fromCharCode(charCode));
  @override
  void writeln([Object? object = '']) => values.add('${object ?? ''}\n');
}

class NdjsonDecoder {
  String _pending = '';
  List<NdjsonRecord> addText(String chunk) {
    final lines = ('$_pending$chunk').split('\n');
    _pending = lines.removeLast();
    return lines.map(_record).toList();
  }

  List<NdjsonRecord> close() => _pending.isEmpty
      ? const <NdjsonRecord>[]
      : <NdjsonRecord>[_record(_pending)];
  NdjsonRecord _record(String line) {
    try {
      return NdjsonRecord(line, jsonDecode(line));
    } catch (_) {
      return NdjsonRecord(line, null);
    }
  }
}

class NdjsonRecord {
  const NdjsonRecord(this.raw, this.value);
  final String raw;
  final Object? value;
  bool get isValid => value != null;
}
