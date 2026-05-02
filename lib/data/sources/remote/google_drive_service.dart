import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  Future<void> uploadBackup() async {
    try {
      final googleSignInAccount = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (googleSignInAccount == null) return;

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return;

      final driveApi = drive.DriveApi(httpClient);

      // Get the database path
      String dbPath = await getDatabasesPath();
      String path = p.join(dbPath, 'borrow_manager.db'); // Change this to your actual DB name
      File file = File(path);

      if (!await file.exists()) {
        print('Database file not found at $path');
        return;
      }

      // Check if file already exists on Drive
      final query = "name = 'borrow_manager_backup.db' and trashed = false";
      final fileList = await driveApi.files.list(q: query);
      
      final driveFile = drive.File();
      driveFile.name = 'borrow_manager_backup.db';

      final media = drive.Media(file.openRead(), await file.length());

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Update existing file
        final fileId = fileList.files!.first.id!;
        await driveApi.files.update(driveFile, fileId, uploadMedia: media);
        print('Backup updated on Google Drive');
      } else {
        // Create new file
        await driveApi.files.create(driveFile, uploadMedia: media);
        print('New backup created on Google Drive');
      }
    } catch (e) {
      print('Error uploading to Google Drive: $e');
    }
  }

  Future<void> restoreBackup() async {
    try {
      final googleSignInAccount = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      if (googleSignInAccount == null) return;

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) return;

      final driveApi = drive.DriveApi(httpClient);

      final query = "name = 'borrow_manager_backup.db' and trashed = false";
      final fileList = await driveApi.files.list(q: query);

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final fileId = fileList.files!.first.id!;
        drive.Media response = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

        String dbPath = await getDatabasesPath();
        String path = p.join(dbPath, 'borrow_manager.db');
        File file = File(path);

        final List<int> dataStore = [];
        await for (final data in response.stream) {
          dataStore.addAll(data);
        }
        await file.writeAsBytes(dataStore);
        print('Backup restored from Google Drive');
      } else {
        print('No backup found on Google Drive');
      }
    } catch (e) {
      print('Error restoring from Google Drive: $e');
    }
  }
}
