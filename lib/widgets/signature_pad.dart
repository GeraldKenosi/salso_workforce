import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/signature_service.dart';

class SignaturePad extends StatefulWidget {
  final bool requireSignature;
  final String title;
  final ValueChanged<Uint8List?> onSign;

  const SignaturePad({
    super.key,
    this.requireSignature = true,
    this.title = 'Signature',
    required this.onSign,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final _controller = SignatureController(
    penStrokeWidth: 2.5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Uint8List? _savedSignature;
  Uint8List? _currentPng;
  bool _useSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _controller.addListener(_onDraw);
  }

  void _onDraw() {
    if (_controller.points.isNotEmpty) {
      _useSaved = false;
    }
  }

  Future<void> _loadSaved() async {
    final svc = context.read<SignatureService>();
    final cached = svc.getCachedSignature();
    if (cached != null && mounted) {
      setState(() => _savedSignature = cached);
    }
  }

  Future<void> _exportPng() async {
    if (_controller.points.isEmpty) return;
    final png = await _controller.toPngBytes();
    if (png != null) {
      _currentPng = png;
      widget.onSign(png);
    }
  }

  Future<void> _useSavedSignature() async {
    if (_savedSignature == null) return;
    setState(() => _useSaved = true);
    _currentPng = _savedSignature;
    widget.onSign(_savedSignature);
  }

  Future<void> _uploadImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    Uint8List? bytes;
    if (file.bytes != null) {
      bytes = file.bytes;
    } else if (file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) return;

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final scaled = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (scaled == null) return;

    setState(() {
      _currentPng = scaled.buffer.asUint8List();
      _useSaved = false;
    });
    widget.onSign(_currentPng);
  }

  @override
  void dispose() {
    _controller.removeListener(_onDraw);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 8),
        Container(
          height: 160,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _useSaved && _savedSignature != null
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Image.memory(_savedSignature!, height: 80, fit: BoxFit.contain),
                  ),
                )
              : Signature(
                  controller: _controller,
                  height: 160,
                  backgroundColor: Colors.white,
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
              onPressed: () {
                _controller.clear();
                setState(() => _useSaved = false);
                _currentPng = null;
                widget.onSign(null);
              },
            ),
            const Spacer(),
            if (_savedSignature != null)
              TextButton.icon(
                icon: const Icon(Icons.replay, size: 16),
                label: const Text('Use Saved'),
                onPressed: _useSavedSignature,
              ),
            const SizedBox(width: 8),
            TextButton.icon(
              icon: const Icon(Icons.upload, size: 16),
              label: const Text('Upload'),
              onPressed: _uploadImage,
            ),
            if (_controller.points.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Confirm'),
                onPressed: _exportPng,
              ),
          ],
        ),
      ],
    );
  }
}
