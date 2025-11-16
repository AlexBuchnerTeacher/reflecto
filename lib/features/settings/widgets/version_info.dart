import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';

import '../../../utils/build_info.dart';

/// Versions- und Build-Informationen
class VersionInfo extends StatefulWidget {
  const VersionInfo({super.key});

  @override
  State<VersionInfo> createState() => _VersionInfoState();
}

class _VersionInfoState extends State<VersionInfo> {
  String? _version;
  String? _buildInfo;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;

    // Semantische Version aus pubspec
    final version = info.version;
    String displayTime = kBuildTime;
    if (displayTime.isEmpty) {
      displayTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    }

    // Build-String zusammensetzen: buildNumber + channel + shortSha + time
    final buildParts = <String>[
      if (info.buildNumber.isNotEmpty && info.buildNumber != '0')
        info.buildNumber,
      if ((kBuildChannel).isNotEmpty) kBuildChannel else 'local',
      if (shortGitSha().isNotEmpty) shortGitSha(),
      displayTime,
    ];
    final build = buildParts.where((e) => e.isNotEmpty).join(' ');

    setState(() {
      _version = version;
      _buildInfo = build;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text('Version'), Text(_version ?? '…')],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [const Text('Build'), Text(_buildInfo ?? '')],
        ),
      ],
    );
  }
}
