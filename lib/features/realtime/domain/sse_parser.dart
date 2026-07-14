import 'dart:convert';

class SseEvent {
  const SseEvent({
    this.event = 'message',
    this.data = '',
    this.id,
    this.retry,
    this.comment,
  });
  final String event;
  final String data;
  final String? id;
  final int? retry;
  final String? comment;
}

/// Incremental SSE parser. It accepts arbitrary UTF-8 chunk boundaries and
/// emits comments separately so callers can expose heartbeat diagnostics.
class SseParser {
  final StringBuffer _lineBuffer = StringBuffer();
  final List<String> _data = <String>[];
  String _event = 'message';
  String? _id;
  int? _retry;
  final List<String> _comments = <String>[];

  List<SseEvent> add(List<int> chunk) =>
      addText(utf8.decode(chunk, allowMalformed: true));
  List<SseEvent> addText(String text) {
    final events = <SseEvent>[];
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == '\n') {
        final line = _lineBuffer.toString().replaceFirst(RegExp(r'\r$'), '');
        _lineBuffer.clear();
        final event = _consumeLine(line);
        if (event != null) events.add(event);
      } else {
        _lineBuffer.write(char);
      }
    }
    return events;
  }

  List<SseEvent> close() {
    final result = <SseEvent>[];
    if (_lineBuffer.isNotEmpty) {
      final event = _consumeLine(_lineBuffer.toString());
      if (event != null) result.add(event);
    }
    final finalEvent = _emit();
    if (finalEvent != null) result.add(finalEvent);
    return result;
  }

  SseEvent? _consumeLine(String line) {
    if (line.isEmpty) return _emit();
    if (line.startsWith(':')) {
      _comments.add(line.substring(1).trim());
      return null;
    }
    final colon = line.indexOf(':');
    final field = colon < 0 ? line : line.substring(0, colon);
    var value = colon < 0 ? '' : line.substring(colon + 1);
    if (value.startsWith(' ')) value = value.substring(1);
    switch (field) {
      case 'event':
        _event = value;
      case 'data':
        _data.add(value);
      case 'id':
        if (!value.contains('\u0000')) _id = value;
      case 'retry':
        final parsed = int.tryParse(value);
        if (parsed != null && parsed >= 0) _retry = parsed;
    }
    return null;
  }

  SseEvent? _emit() {
    if (_data.isEmpty && _comments.isEmpty) return null;
    final event = SseEvent(
      event: _event,
      data: _data.join('\n'),
      id: _id,
      retry: _retry,
      comment: _comments.isEmpty ? null : _comments.join('\n'),
    );
    _data.clear();
    _comments.clear();
    _event = 'message';
    _retry = null;
    return event;
  }
}
