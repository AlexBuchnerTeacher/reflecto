const String kBuildChannel = String.fromEnvironment(
  'BUILD_CHANNEL',
  defaultValue: 'local',
);
const String kGitSha = String.fromEnvironment('GIT_SHA', defaultValue: 'dev');
const String kBuildTime = String.fromEnvironment(
  'BUILD_TIME',
  defaultValue: '',
);

String shortGitSha([int length = 7]) {
  final s = kGitSha;
  if (s.isEmpty || s == 'dev') return s;
  return s.length <= length ? s : s.substring(0, length);
}
