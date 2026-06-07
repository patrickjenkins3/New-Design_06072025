import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfilePhotoWidget extends StatefulWidget {
  final String? currentPhotoUrl;
  final Function(String?) onPhotoChanged;

  const ProfilePhotoWidget({
    Key? key,
    this.currentPhotoUrl,
    required this.onPhotoChanged,
  }) : super(key: key);

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  XFile? _capturedImage;
  bool _isCameraInitialized = false;
  bool _showCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        final camera = kIsWeb
            ? _cameras!.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.front,
                orElse: () => _cameras!.first)
            : _cameras!.firstWhere(
                (c) => c.lensDirection == CameraLensDirection.back,
                orElse: () => _cameras!.first);

        _cameraController = CameraController(
            camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);
        await _cameraController!.initialize();
        await _applySettings();
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      // Handle camera initialization error silently
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {}
    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {}
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
        _showCamera = false;
      });
      widget.onPhotoChanged(photo.path);
    } catch (e) {
      // Handle capture error silently
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _capturedImage = image);
        widget.onPhotoChanged(image.path);
      }
    } catch (e) {
      // Handle gallery error silently
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Update Profile Photo',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Take Photo',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () async {
                Navigator.pop(context);
                if (await _requestCameraPermission()) {
                  setState(() => _showCamera = true);
                }
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Choose from Gallery',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            if (widget.currentPhotoUrl != null || _capturedImage != null)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 24,
                ),
                title: Text(
                  'Remove Photo',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _capturedImage = null);
                  widget.onPhotoChanged(null);
                },
              ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoDisplay() {
    if (_capturedImage != null) {
      return kIsWeb
          ? Image.network(_capturedImage!.path, fit: BoxFit.cover)
          : CustomImageWidget(
              imageUrl: _capturedImage!.path,
              width: 20.w,
              height: 20.w,
              fit: BoxFit.cover,
            );
    } else if (widget.currentPhotoUrl != null) {
      return CustomImageWidget(
        imageUrl: widget.currentPhotoUrl!,
        width: 20.w,
        height: 20.w,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: 'person',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 10.w,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showCamera && _isCameraInitialized && _cameraController != null) {
      return Container(
        height: 60.h,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _showCamera = false),
                    child: Text('Cancel'),
                  ),
                  Text(
                    'Take Photo',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  SizedBox(width: 15.w),
                ],
              ),
            ),
            Expanded(
              child: CameraPreview(_cameraController!),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _capturePhoto,
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Container(
                        margin: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _showPhotoOptions,
      child: Stack(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: ClipOval(child: _buildPhotoDisplay()),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  width: 2,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'camera_alt',
                color: Colors.white,
                size: 3.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
