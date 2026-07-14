import 'dart:convert';

import '../../shared/models/api_models.dart';
import '../security/secret_masker.dart';

class TokenCandidateService {
  static const _names = <String>{
    'access_token',
    'accessToken',
    'token',
    'refresh_token',
    'refreshToken',
  };

  List<TokenCandidate> find(String body) {
    try {
      final result = <TokenCandidate>[];
      void visit(Object? value, String path) {
        if (value is Map) {
          for (final entry in value.entries) {
            final key = entry.key.toString();
            final childPath = path.isEmpty ? key : '$path.$key';
            if (_names.contains(key) &&
                entry.value is String &&
                (entry.value as String).isNotEmpty) {
              result.add(
                TokenCandidate(
                  jsonPath: childPath,
                  maskedValue: SecretMasker.mask(entry.value as String),
                ),
              );
            }
            visit(entry.value, childPath);
          }
        } else if (value is List) {
          for (var index = 0; index < value.length; index++) {
            visit(value[index], '$path[$index]');
          }
        }
      }

      visit(jsonDecode(body), '');
      return result;
    } on FormatException {
      return const <TokenCandidate>[];
    }
  }

  Map<String, String> extract(String body) {
    try {
      final result = <String, String>{};
      void visit(Object? value, String path) {
        if (value is Map) {
          for (final entry in value.entries) {
            final key = entry.key.toString();
            final childPath = path.isEmpty ? key : '$path.$key';
            if (_names.contains(key) &&
                entry.value is String &&
                (entry.value as String).isNotEmpty) {
              result[childPath] = entry.value as String;
            }
            visit(entry.value, childPath);
          }
        } else if (value is List) {
          for (var index = 0; index < value.length; index++) {
            visit(value[index], '$path[$index]');
          }
        }
      }

      visit(jsonDecode(body), '');
      return result;
    } on FormatException {
      return const <String, String>{};
    }
  }
}
