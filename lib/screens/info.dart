import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'footer.dart';
import 'package:provider/provider.dart';
import '../language.dart';
import '../image.dart';
import '../bluetooth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final List<Map<String, dynamic>> contents = [
    {
      "title": "Toplantı Gündemi",
      "startTime": "00:13:00",
      "endTime": "00:14:30",
      "type": "document",
    },
    {
      "title": "Proje Değerlendirme",
      "startTime": "00:15:00",
      "endTime": "00:15:45",
      "type": "document",
    },
    {
      "title": "Bütçe Planlaması",
      "startTime": "00:16:00",
      "endTime": "00:17:45",
      "type": "document",
    },
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  File? _selectedFile;
  String? _selectedFileName;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Color _getGreyColor(int shade) {
    return Colors.grey[shade] ?? _getFallbackGreyColor(shade);
  }

  Color _getFallbackGreyColor(int shade) {
    switch (shade) {
      case 100:
        return const Color(0xFFF5F5F5);
      case 300:
        return const Color(0xFFE0E0E0);
      case 400:
        return const Color(0xFFBDBDBD);
      case 600:
        return const Color(0xFF757575);
      case 700:
        return const Color(0xFF616161);
      default:
        return Colors.grey;
    }
  }

  Future<void> _pickFile() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: Text(languageProvider.getTranslation('select_photo')),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedFile = File(image.path);
                      _selectedFileName = image.name;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: Text(languageProvider.getTranslation('select_video')),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? video =
                  await _picker.pickVideo(source: ImageSource.gallery);
                  if (video != null) {
                    setState(() {
                      _selectedFile = File(video.path);
                      _selectedFileName = video.name;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(languageProvider.getTranslation('select_document')),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickDocument();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      print("Dosya seçme hatası: $e");
    }
  }

  void _showAddContentDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    _titleController.clear();
    _startTimeController.text = '00:15:00';
    _endTimeController.text = '00:30:00';
    _selectedFile = null;
    _selectedFileName = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4DB6AC), width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve Kapatma Butonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(languageProvider.getTranslation('meeting_topic'),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      IconButton(
                        icon: Icon(Icons.close, color: _getGreyColor(600)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: languageProvider.getTranslation('meeting_topic'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF4DB6AC), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dosya Seçme Butonu
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DB6AC),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.attach_file, size: 20),
                        const SizedBox(width: 8),
                        Text(_selectedFile == null
                            ? languageProvider.getTranslation('select_file')
                            : languageProvider.getTranslation('file_selected')),
                      ],
                    ),
                  ),

                  // Seçilen Dosya Bilgisi - DOSYA ADI GÖSTERİMİ
                  if (_selectedFile != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getGreyColor(100),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getGreyColor(300)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getFileTypeIcon(_selectedFile!.path),
                            color: _getFileTypeColor(_selectedFile!.path),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dosya: ${_selectedFileName ?? _selectedFile!.path.split('/').last}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _getGreyColor(700),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getFileTypeText(_selectedFile!.path),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getGreyColor(600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.close, size: 20, color: _getGreyColor(600)),
                            onPressed: () {
                              setState(() {
                                _selectedFile = null;
                                _selectedFileName = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Zaman Alanları
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(languageProvider.getTranslation('start'),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _startTimeController,
                              decoration: InputDecoration(
                                hintText: '00:15:00',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4DB6AC), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(languageProvider.getTranslation('end'),
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _endTimeController,
                              decoration: InputDecoration(
                                hintText: '00:30:00',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF4DB6AC), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Kaydet ve İptal Butonları
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getGreyColor(400),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(languageProvider.getTranslation('cancel')),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _saveContent(context);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DB6AC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(languageProvider.getTranslation('save')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dosya tipine göre icon belirleme
  IconData _getFileTypeIcon(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    if (["jpg", "jpeg", "png", "gif", "bmp"].contains(ext)) {
      return Icons.photo;
    } else if (["mp4", "mov", "avi", "mkv", "wmv"].contains(ext)) {
      return Icons.videocam;
    } else if (["pdf"].contains(ext)) {
      return Icons.picture_as_pdf;
    } else if (["doc", "docx"].contains(ext)) {
      return Icons.description;
    } else if (["xls", "xlsx"].contains(ext)) {
      return Icons.table_chart;
    } else if (["ppt", "pptx"].contains(ext)) {
      return Icons.slideshow;
    } else if (["txt"].contains(ext)) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // Dosya tipine göre renk belirleme
  Color _getFileTypeColor(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    if (["jpg", "jpeg", "png", "gif", "bmp"].contains(ext)) {
      return Colors.amber;
    } else if (["mp4", "mov", "avi", "mkv", "wmv"].contains(ext)) {
      return Colors.red;
    } else if (["pdf"].contains(ext)) {
      return Colors.redAccent;
    } else {
      return Colors.blue;
    }
  }

  // Dosya tipine göre metin belirleme
  String _getFileTypeText(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    if (["jpg", "jpeg", "png", "gif", "bmp"].contains(ext)) {
      return "Fotoğraf";
    } else if (["mp4", "mov", "avi", "mkv", "wmv"].contains(ext)) {
      return "Video";
    } else if (["pdf"].contains(ext)) {
      return "PDF Dokümanı";
    } else if (["doc", "docx"].contains(ext)) {
      return "Word Dokümanı";
    } else if (["xls", "xlsx"].contains(ext)) {
      return "Excel Tablosu";
    } else if (["ppt", "pptx"].contains(ext)) {
      return "PowerPoint Sunumu";
    } else if (["txt"].contains(ext)) {
      return "Metin Dosyası";
    } else {
      return "Dosya";
    }
  }

  void _saveContent(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final bluetoothProvider = Provider.of<BluetoothProvider>(context, listen: false);

    if (_titleController.text.trim().isEmpty ||
        _startTimeController.text.trim().isEmpty ||
        _endTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(languageProvider.getTranslation('fill_all_fields')),
        backgroundColor: Colors.red,
      ));
      return;
    }

    String startTimeText = _startTimeController.text.trim();
    String endTimeText = _endTimeController.text.trim();
    RegExp timeRegex =
    RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])$');

    if (!timeRegex.hasMatch(startTimeText) ||
        !timeRegex.hasMatch(endTimeText)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(languageProvider.getTranslation('invalid_time_format')),
        backgroundColor: Colors.red,
      ));
      return;
    }

    String fileType = "document";
    if (_selectedFile != null) {
      final ext = _selectedFile!.path.split('.').last.toLowerCase();
      if (["jpg", "jpeg", "png"].contains(ext)) {
        fileType = "photo";
      } else if (["mp4", "mov", "avi"].contains(ext)) {
        fileType = "video";
      } else if (["pdf", "doc", "docx", "txt", "ppt", 'pptx', 'xls', 'xlsx'].contains(ext)) {
        fileType = "document";
      }
    }

    String title = _titleController.text.trim();

    setState(() {
      contents.add({
        "title": title,
        "startTime": startTimeText,
        "endTime": endTimeText,
        "type": fileType,
      });

      // Seçilen dosya bilgilerini sıfırla
      _selectedFile = null;
      _selectedFileName = null;
    });

    // JSON verisini hazırla ve gönder (operation: 1 - İçerik ekleme)
    Map<String, dynamic> jsonData = {
      "operation": 1, // 1: İçerik ekleme işlemi
      "title": title,
      "startTime": startTimeText,
      "endTime": endTimeText,
      "fileType": fileType,
      "fileName": _selectedFileName ?? (_selectedFile != null ? _selectedFile!.path.split('/').last : "")
    };

    // Bluetooth'a JSON verisini gönder
    bluetoothProvider.sendJsonData(jsonData, context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(languageProvider.getTranslation('content_added_success')),
      backgroundColor: Colors.green,
    ));
  }

  void _deleteContent(int index) {
    setState(() {
      contents.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: screenHeight * 0.10,
        flexibleSpace: Container(
          width: double.infinity,
          height: double.infinity,
          child: ImageWidget(
            fit: BoxFit.cover,
            showBluetoothStatus: true,
            connection: bluetoothProvider.connection,
            connectedDevice: bluetoothProvider.connectedDevice,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF4DB6AC), width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.04,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4DB6AC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Container(
                                  width: screenWidth * 0.15,
                                  height: screenWidth * 0.08,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00695C),
                                    borderRadius:
                                    BorderRadius.circular(screenWidth * 0.1),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Expanded(
                                  child: Text(
                                    languageProvider.getTranslation('info_screen_'),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF00695C),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showAddContentDialog(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.005,
                                  vertical: screenHeight * 0.005),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 1.5)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    languageProvider.getTranslation('add_content'),
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.032,
                                        color: const Color(0xFF00695C),
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Icon(
                                    Icons.image,
                                    size: screenWidth * 0.04,
                                    color: const Color(0xFF00695C),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                        child: ListView.builder(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.005,
                            bottom: screenHeight * 0.02,
                          ),
                          itemCount: contents.length,
                          itemBuilder: (context, index) {
                            final content = contents[index];
                            return ContentCard(
                              title: content['title'], // Dil çevirisi olmadan direkt göster
                              startTime: content['startTime']!,
                              endTime: content['endTime']!,
                              type: content['type']!,
                              onDelete: () => _deleteContent(index),
                              getGreyColor: _getGreyColor,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            AppFooter(activeTab: "management"),
          ],
        ),
      ),
    );
  }
}

class ContentCard extends StatefulWidget {
  final String title;
  final String startTime;
  final String endTime;
  final String type;
  final VoidCallback onDelete;
  final Color Function(int) getGreyColor;

  const ContentCard({
    Key? key,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.onDelete,
    required this.getGreyColor,
  }) : super(key: key);

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  bool _isPlaying = false;

  void _togglePlay() {
    setState(() {
      _isPlaying  = !_isPlaying;
    });
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case "photo":
        return Icons.photo;
      case "video":
        return Icons.videocam;
      case "document":
        return Icons.description;
      default:
        return Icons.description;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case "photo":
        return Colors.amber;
      case "video":
        return Colors.red;
      case "document":
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4DB6AC), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForType(widget.type),
                        color: _getColorForType(widget.type),
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: screenWidth * 0.035, color: widget.getGreyColor(600)),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "${widget.startTime} - ${widget.endTime}",
                        style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: widget.getGreyColor(600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: _togglePlay,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.grey[700],
                    size: screenWidth * 0.055,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: screenWidth * 0.02),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: screenWidth * 0.055,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}