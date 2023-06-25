import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:intl/intl.dart';

import '../../../constants/styles.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../../utils/utils.dart' show capitalize, showSnackBar;
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text.dart';
import '../../profile/widgets/preview_image_screen.dart';

class MessageWidget extends StatefulWidget {
  final Message message;
  final User user;
  const MessageWidget({super.key, required this.message, required this.user});

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  var isDownloading = false;
  @override
  Widget build(BuildContext context) {
    final formattedName =
        "${capitalize(widget.message.firstName)} ${capitalize(widget.message.lastName)}";
    return Wrap(
      alignment: widget.message.userId == widget.user.userId
          ? WrapAlignment.end
          : WrapAlignment.start,
      children: [
        SizedBox(
          width: widget.message.fileUrl == ''
              ? null
              : MediaQuery.of(context).size.width * 0.6,
          child: Card(
            color: widget.message.userId == widget.user.userId
                ? const Color(0xff2A813E)
                : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: widget.message.userId == widget.user.userId
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (widget.message.userId != widget.user.userId)
                    AppText(
                      textColor: primaryColor,
                      fontWeight: FontWeight.w600,
                      text: formattedName,
                    ),
                  AppText(
                    textSize: 14,
                    textColor: widget.message.userId == widget.user.userId
                        ? Colors.white
                        : Colors.black,
                    text: widget.message.message,
                  ),
                  if (widget.message.fileUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: GestureDetector(
                        onTap: _isImage(
                          widget.message.fileUrl.substring(
                            widget.message.fileUrl.indexOf('_') + 1,
                            widget.message.fileUrl.indexOf('?'),
                          ),
                        )
                            ? () async {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return PrevieImageScreen(
                                        imageUrl: widget.message.fileUrl,
                                      );
                                    },
                                  ),
                                );
                              }
                            : () async {
                                await _downloadFile(widget.message.fileUrl);
                              },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _isImage(
                            widget.message.fileUrl.substring(
                              widget.message.fileUrl.indexOf('_') + 1,
                              widget.message.fileUrl.indexOf('?'),
                            ),
                          )
                              ? GestureDetector(
                                  onLongPress: () {
                                    _showDownloadImageDialog(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.message.fileUrl,
                                      height: 200,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(8),
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  color: Colors.green.shade600,
                                  child: Row(
                                    children: [
                                      AppText(
                                        textColor: Colors.white,
                                        text: _cropFileLongFileName(
                                          widget.message.fileUrl.substring(
                                            widget.message.fileUrl
                                                    .indexOf('_') +
                                                1,
                                            widget.message.fileUrl.indexOf('?'),
                                          ),
                                        ),
                                      ),
                                      isDownloading
                                          ? const Center(
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8.0),
                                                child: SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.download,
                                              color: Colors.white,
                                            )
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  AppText(
                    textSize: 11,
                    textColor: widget.message.userId == widget.user.userId
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w300,
                    text: DateFormat('hh:mm a').format(
                      DateTime.parse(widget.message.createdAt).toLocal(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void _showDownloadImageDialog(BuildContext context) {
    var fn = _cropFileLongFileName(
      widget.message.fileUrl.substring(
        widget.message.fileUrl.indexOf('_') + 1,
        widget.message.fileUrl.indexOf('?'),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: AppText(text: 'Do you want to download $fn?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _downloadFile(widget.message.fileUrl);
                },
                height: 50,
                wrapRow: true,
                text: "Download",
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadFile(String filename) async {
    setState(() {
      isDownloading = true;
    });
    await FileDownloader.downloadFile(
        url: widget.message.fileUrl,
        name: widget.message.fileUrl.substring(
          widget.message.fileUrl.indexOf('_') + 1,
          widget.message.fileUrl.indexOf('?'),
        ),
        onProgress: (String? fileName, double progress) {
          print('FILE fileName HAS PROGRESS $progress');
        },
        onDownloadCompleted: (String path) {
          showSnackBar(context, 'File downloaded to $path');
        },
        onDownloadError: (String error) {
          showSnackBar(
            context,
            "The file could not be downloaded. Please try again later.",
          );
        });

    setState(() {
      isDownloading = false;
    });
  }

  bool _isImage(String filename) {
    final ext = filename.substring(filename.lastIndexOf('.') + 1).toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png';
  }

  String _cropFileLongFileName(String filename) {
    if (filename.length > 20) {
      return "${filename.substring(0, 5)}...${filename.substring(filename.length - 10, filename.length)}";
    }
    return filename;
  }
}
