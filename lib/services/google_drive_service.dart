import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'database_helper.dart';

class GoogleDriveService {
  // On Android, the Client ID should NOT be passed in the code.
  // It is automatically picked up from the Package Name and SHA-1 fingerprint 
  // configured in your Google Cloud Console.
  // We only provide a clientId here if we are running on the Web.
  static final _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '655690713664-740dkm368pcte674u26td5kiar3fqto1.apps.googleusercontent.com' : null,
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      debugPrint('GoogleDriveService: Starting sign-in...');
      // Sign out first to ensure the account picker always appears if there was an error
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      final account = await _googleSignIn.signIn();
      debugPrint('GoogleDriveService: Sign-in result: ${account?.email}');
      return account;
    } catch (e) {
      debugPrint('GoogleDriveService: Sign-in error: $e');
      rethrow;
    }
  }

  static Future<GoogleSignInAccount?> signInSilently() async {
    return await _googleSignIn.signInSilently();
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static Future<drive.DriveApi?> _getDriveApi() async {
    GoogleSignInAccount? account = _googleSignIn.currentUser;
    account ??= await _googleSignIn.signInSilently();
    
    if (account == null) return null;

    final authClient = await _googleSignIn.authenticatedClient();
    if (authClient == null) return null;

    return drive.DriveApi(authClient);
  }

  static Future<bool> backupDatabase() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      final dbPath = await DatabaseHelper().getDatabasePath();
      final file = File(dbPath);

      final query = "name = 'borrow_manager_backup.db' and 'appDataFolder' in parents";
      final fileList = await driveApi.files.list(q: query, spaces: 'appDataFolder');

      final driveFile = drive.File()
        ..name = 'borrow_manager_backup.db'
        ..parents = ['appDataFolder'];

      final media = drive.Media(file.openRead(), file.lengthSync());

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        await driveApi.files.update(driveFile, fileList.files!.first.id!, uploadMedia: media);
      } else {
        await driveApi.files.create(driveFile, uploadMedia: media);
      }
      return true;
    } catch (e) {
      debugPrint('Backup error: $e');
      return false;
    }
  }

  static Future<bool> restoreDatabase() async {
    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      final query = "name = 'borrow_manager_backup.db' and 'appDataFolder' in parents";
      final fileList = await driveApi.files.list(q: query, spaces: 'appDataFolder');

      if (fileList.files == null || fileList.files!.isEmpty) return false;

      final fileId = fileList.files!.first.id!;
      final response = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
      
      final dbPath = await DatabaseHelper().getDatabasePath();
      final file = File(dbPath);
      
      final List<int> dataStore = [];
      await response.stream.listen((data) {
        dataStore.addAll(data);
      }).asFuture();

      if (dataStore.isEmpty) return false;

      await file.writeAsBytes(dataStore);
      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }
}
