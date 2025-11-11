import 'package:cloud_firestore/cloud_firestore.dart';

class FakeSnapshotMetadata implements SnapshotMetadata {
  @override
  final bool hasPendingWrites;
  @override
  final bool isFromCache;
  FakeSnapshotMetadata({
    this.hasPendingWrites = false,
    this.isFromCache = false,
  });
}

class FakeDocumentReference<T extends Object?> implements DocumentReference<T> {
  final String _path;
  FakeDocumentReference(this._path);

  @override
  String get id => _path.split('/').last;

  // The following members are not needed for our tests and throw if used.
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeDocumentSnapshot<T extends Object?> implements DocumentSnapshot<T> {
  final String _id;
  final T? _data;
  final SnapshotMetadata _metadata;
  final DocumentReference<T> _ref;

  FakeDocumentSnapshot({
    required String id,
    required T? data,
    SnapshotMetadata? metadata,
    DocumentReference<T>? reference,
  }) : _id = id,
       _data = data,
       _metadata = metadata ?? FakeSnapshotMetadata(),
       _ref = reference ?? FakeDocumentReference<T>('tests/$id');

  @override
  String get id => _id;

  @override
  T? data() => _data;

  @override
  bool get exists => _data != null;

  @override
  SnapshotMetadata get metadata => _metadata;

  @override
  DocumentReference<T> get reference => _ref;

  // The rest of the API surface is not used in our tests.
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
