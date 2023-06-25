import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:intl/intl.dart';

import '../../../constants/styles.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../../utils/utils.dart' show capitalize, showSnackBar;
import '../../../widgets/app_text.dart';

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
          width: MediaQuery.of(context).size.width * 0.6,
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
                        onTap: () async {
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
                                showSnackBar(
                                  context,
                                  'File downloaded to $path',
                                );
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
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.green.shade600,
                            child: Row(
                              children: [
                                AppText(
                                  textColor: Colors.white,
                                  text: _cropFileLongFileName(
                                    widget.message.fileUrl.substring(
                                      widget.message.fileUrl.indexOf('_') + 1,
                                      widget.message.fileUrl.indexOf('?'),
                                    ),
                                  ),
                                ),
                                isDownloading
                                    ? const Center(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: CircularProgressIndicator(
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

  String _cropFileLongFileName(String filename) {
    if (filename.length > 20) {
      return "${filename.substring(0, 5)}...${filename.substring(filename.length - 10, filename.length)}";
    }
    return filename;
  }
}
