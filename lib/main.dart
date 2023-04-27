import 'lol_lockfile.dart';

void main(List<String> args) async {
  Creds? creds = await ClientCredentials().getCredentials();
}
