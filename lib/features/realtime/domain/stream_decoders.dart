import 'dart:convert';

class IncrementalTextDecoder {
  final StringBuffer _buffer = StringBuffer();
  List<String> add(List<int> bytes) {
    _buffer.write(utf8.decode(bytes, allowMalformed: true));
    return const <String>[];
  }

  String take() {
    final value = _buffer.toString();
    _buffer.clear();
    return value;
  }
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
