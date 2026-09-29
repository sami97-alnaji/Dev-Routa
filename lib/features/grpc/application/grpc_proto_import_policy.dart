import 'package:path/path.dart' as path;

import '../domain/grpc_descriptor_models.dart';

/// Validates source selection before a separate compiler process receives fixed
/// argument arrays. This class never parses or executes imported source text.
class GrpcProtoImportPolicy {
  const GrpcProtoImportPolicy({
    this.maximumIncludeRoots = 8,
    this.maximumImportDepth = 32,
    this.maximumSourceBytes = 1024 * 1024,
  });

  final int maximumIncludeRoots;
  final int maximumImportDepth;
  final int maximumSourceBytes;

  String resolveRootSource({
    required String sourcePath,
    required String sourceRoot,
  }) {
    _validateSourcePath(sourcePath, 'root source');
    if (!_isWithin(sourcePath, sourceRoot)) {
      throw const GrpcDescriptorException(
        'Root source is outside its allowed root.',
      );
    }
    return path.normalize(sourcePath);
  }

  String resolveImport({
    required String importPath,
    required List<String> allowedRoots,
  }) {
    if (allowedRoots.isEmpty || allowedRoots.length > maximumIncludeRoots) {
      throw const GrpcDescriptorException(
        'Invalid number of selected include roots.',
      );
    }
    _rejectUnsafeImport(importPath);
    final normalized = importPath.replaceAll('\\', '/');
    final segments = path.posix.split(normalized);
    if (segments.length > maximumImportDepth ||
        segments.any(
          (segment) => segment.isEmpty || segment == '.' || segment == '..',
        )) {
      throw GrpcDescriptorException(
        'Import path traversal is not allowed.',
        path: importPath,
      );
    }
    for (final root in allowedRoots) {
      _validateRoot(root);
      final candidate = path.normalize(
        path.joinAll(<String>[root, ...segments]),
      );
      if (_isWithin(candidate, root)) return candidate;
    }
    throw GrpcDescriptorException(
      'Import is outside the explicitly selected include roots.',
      path: importPath,
    );
  }

  void validateSourceBytes(int length) {
    if (length < 0 || length > maximumSourceBytes) {
      throw const GrpcDescriptorException(
        'Proto source exceeds the allowed size.',
      );
    }
  }

  void _rejectUnsafeImport(String importPath) {
    final lower = importPath.toLowerCase();
    if (importPath.isEmpty ||
        importPath.contains('\u0000') ||
        importPath.startsWith('\\') ||
        importPath.startsWith('//') ||
        RegExp(r'^[a-zA-Z]:').hasMatch(importPath) ||
        RegExp(r'^(file|http|https):').hasMatch(lower) ||
        !lower.endsWith('.proto')) {
      throw GrpcDescriptorException(
        'Imports must be safe relative .proto paths.',
        path: importPath,
      );
    }
  }

  void _validateSourcePath(String value, String label) {
    if (!path.isAbsolute(value) ||
        value.contains('\u0000') ||
        !value.toLowerCase().endsWith('.proto')) {
      throw GrpcDescriptorException('$label must be an absolute .proto path.');
    }
  }

  void _validateRoot(String value) {
    if (!path.isAbsolute(value) || value.contains('\u0000')) {
      throw const GrpcDescriptorException(
        'Include roots must be absolute local paths.',
      );
    }
  }

  bool _isWithin(String candidate, String root) {
    final relative = path.relative(
      path.normalize(candidate),
      from: path.normalize(root),
    );
    return relative.isNotEmpty &&
        !path.isAbsolute(relative) &&
        relative != '..' &&
        !relative.startsWith('..${path.separator}');
  }
}
