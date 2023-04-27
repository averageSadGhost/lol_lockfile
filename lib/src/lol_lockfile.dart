import 'dart:io';
import 'package:logger/logger.dart';

// commands to get the path from the running process "League of legends client" on diffrent operating systems.

// Mac commands:
const _macCommand = 'ps';
const _macCommandArgs = ["aux", "-o", "args | grep 'LeagueClientUx'"];

//______________________________________________________________________________

// Windows commands:
const _winCommand =
    "WMIC PROCESS WHERE name='LeagueClientUx.exe' GET commandline";

//______________________________________________________________________________

class Creds {
  final String processName;
  final String processId;
  final String port;
  final String password;
  final String protocol;

  Creds({
    required this.processName,
    required this.processId,
    required this.port,
    required this.password,
    required this.protocol,
  });
}

class ClientCredentials {
  //do a regex search, for more info visit: https://hextechdocs.dev/getting-started-with-the-lcu-api/

  final _regexMAC = RegExp(r'--install-directory=(.*?)( --|\n|$)');

  final _regexWin = RegExp(r'--install-directory=(.*?)"');

  Future<String?> _getLCUPathFromProcess() async {
    if (Platform.isMacOS) {
      final result = await Process.run(_macCommand, _macCommandArgs);

      final match = _regexMAC.firstMatch(result.stdout);
      final matchedText = match?.group(1);

      return matchedText;
    } else if (Platform.isWindows) {
      final result = await Process.run(
        _winCommand,
        [],
        runInShell: true,
      );

      final match = _regexWin.firstMatch(result.stdout);
      final matchedText = match?.group(1);

      return matchedText;
    }
    return null;
  }

  Creds _parseCredentials(String data) {
    //example of unsplited data LeagueClient:33668:59541:kNtVjjh-s-EC9vtAKz7l7g:https
    List<String> splitedData = data.split(":");
    //example of spilted data ["LeagueClient","33668","59541","kNtVjjh-s-EC9vtAKz7l7g","https"]
    return Creds(
        processName: splitedData[0],
        processId: splitedData[1],
        port: splitedData[2],
        password: splitedData[3],
        protocol: splitedData[4]);
  }

  Future<Creds?> getCredentials() async {
    try {
      Creds data = _parseCredentials(
          File('${await _getLCUPathFromProcess()}/lockfile')
              .readAsStringSync());
      return data;
    } catch (error) {
      var logger = Logger(
        filter: null, // Use the default LogFilter (-> only log in debug mode)
        printer:
            PrettyPrinter(), // Use the PrettyPrinter to format and print log
        output:
            null, // Use the default LogOutput (-> send everything to console)
      );
      logger.e("lol_lockfile: error in getting credentials, $error");
      return null;
    }
  }
}
