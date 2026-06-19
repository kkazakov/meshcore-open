import 'dart:typed_data';

import '../models/contact.dart';
import '../connector/meshcore_protocol.dart';

class PathHelper {
  static String formatPathHex(List<int> pathBytes) {
    return pathBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(',');
  }

  static String hopHex(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();
  }

  static String? hopName(
    List<int> prefix,
    List<Contact> allContacts,
  ) {
    final matches = allContacts
        .where(
          (c) =>
              c.publicKey.length >= prefix.length &&
              _prefixEquals(c.publicKey, prefix) &&
              (c.type == advTypeRepeater || c.type == advTypeRoom),
        )
        .toList();
    if (matches.isEmpty) return null;
    if (matches.length == 1) return matches.first.name;
    return matches.map((c) => c.name).join(' | ');
  }

  static bool _prefixEquals(Uint8List publicKey, List<int> prefix) {
    for (var i = 0; i < prefix.length; i++) {
      if (publicKey[i] != prefix[i]) return false;
    }
    return true;
  }

  static String resolvePathNames(
    List<int> pathBytes,
    List<Contact> allContacts, {
    int hashByteWidth = pathHashSize,
  }) {
    final w = hashByteWidth.clamp(1, pubKeySize);
    final hops = <String>[];
    for (var i = 0; i + w <= pathBytes.length; i += w) {
      final prefix = pathBytes.sublist(i, i + w);
      hops.add(hopName(prefix, allContacts) ?? hopHex(prefix));
    }
    return hops.join(' \u2192 ');
  }
}
