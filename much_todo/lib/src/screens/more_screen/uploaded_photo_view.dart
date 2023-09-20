import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/uploaded_photo.dart';
import 'package:much_todo/src/services/photo_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:photo_view/photo_view.dart';

class UploadedPhotoView extends StatefulWidget {
  final UploadedPhoto photo;

  const UploadedPhotoView({super.key, required this.photo});

  @override
  State<UploadedPhotoView> createState() => _UploadedPhotoViewState();
}

class _UploadedPhotoViewState extends State<UploadedPhotoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: AutoSizeText(
            '${(widget.photo.bytes / 1000000).toStringAsFixed(2)} MB',
            minFontSize: 10,
            maxLines: 1,
          ),
          subtitle: Text('Uploaded ${DateFormat.yMd().format(widget.photo.uploadDate)}'),
          contentPadding: EdgeInsets.zero,
        ),
        actions: [
          TextButton.icon(
            onPressed: promptDelete,
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onBackground),
            label: Text(
              'DELETE',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          heroAttributes: PhotoViewHeroAttributes(tag: widget.photo.hashCode),
          backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
          imageProvider: NetworkImage(widget.photo.publicUrl),
        ),
      ),
    );
  }

  void promptDelete() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog.adaptive(
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deletePhoto();
              },
              child: const Text('DELETE'),
            )
          ],
          title: const Text('Delete Photo'),
          content: const Text(
              'Are you sure you wish to delete this photo?\n\nThis photo will be permanently removed and no longer visible on any tasks.'),
        );
      },
    );
  }

  Future<void> deletePhoto() async {
    showLoadingDialog(msg: 'Deleting...', context);
    var result = await PhotoService.deleteUploadedPhoto(widget.photo.path);

    if (result.success && context.mounted) {
      closePopup(context);
      Navigator.pop(context, true);
    } else if (result.failure && context.mounted) {
      closePopup(context);
      showSnackbar(result.errorMessage!, context);
    }
  }
}
