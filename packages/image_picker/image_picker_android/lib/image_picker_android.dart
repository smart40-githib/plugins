// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/image_picker_android');

/// An Android implementation of [ImagePickerPlatform].
class ImagePickerAndroid extends ImagePickerPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  /// Registers this class as the default platform implementation.
  static void registerWith() {
    ImagePickerPlatform.instance = ImagePickerAndroid();
  }

  @override
  Future<PickedFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final String? path = await _getImagePath(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? PickedFile(path) : null;
  }

  @override
  Future<List<PickedFile>?> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final List<dynamic>? paths = await _getMultiImagePath(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (paths == null) {
      return null;
    }

    return paths.map((dynamic path) => PickedFile(path as String)).toList();
  }

  Future<List<dynamic>?> _getMultiImagePath({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) {
    if (imageQuality != null && (imageQuality < 0 || imageQuality > 100)) {
      throw ArgumentError.value(
          imageQuality, 'imageQuality', 'must be between 0 and 100');
    }

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth', 'cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight', 'cannot be negative');
    }

    return _channel.invokeMethod<List<dynamic>?>(
      'pickMultiImage',
      <String, dynamic>{
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality,
      },
    );
  }

  Future<String?> _getImagePath({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) {
    if (imageQuality != null && (imageQuality < 0 || imageQuality > 100)) {
      throw ArgumentError.value(
          imageQuality, 'imageQuality', 'must be between 0 and 100');
    }

    if (maxWidth != null && maxWidth < 0) {
      throw ArgumentError.value(maxWidth, 'maxWidth', 'cannot be negative');
    }

    if (maxHeight != null && maxHeight < 0) {
      throw ArgumentError.value(maxHeight, 'maxHeight', 'cannot be negative');
    }

    return _channel.invokeMethod<String>(
      'pickImage',
      <String, dynamic>{
        'source': source.index,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
        'imageQuality': imageQuality,
        'cameraDevice': preferredCameraDevice.index,
        'requestFullMetadata': requestFullMetadata,
      },
    );
  }

  @override
  Future<PickedFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final String? path = await _getVideoPath(
      source: source,
      maxDuration: maxDuration,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? PickedFile(path) : null;
  }

  Future<String?> _getVideoPath({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) {
    return _channel.invokeMethod<String>(
      'pickVideo',
      <String, dynamic>{
        'source': source.index,
        'maxDuration': maxDuration?.inSeconds,
        'cameraDevice': preferredCameraDevice.index
      },
    );
  }

  Future<String?> _getAudioPath({
    required AudioSource source
  }) {
    return _channel.invokeMethod<String>(
      'pickAudio',
      <String, dynamic>{
        'source': source.index,
      },
    );
  }
  @override
  Future<XFile?> getImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    final String? path = await _getImagePath(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? XFile(path) : null;
  }

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    final String? path = await _getImagePath(
      source: source,
      maxHeight: options.maxHeight,
      maxWidth: options.maxWidth,
      imageQuality: options.imageQuality,
      preferredCameraDevice: options.preferredCameraDevice,
      requestFullMetadata: options.requestFullMetadata,
    );
    return path != null ? XFile(path) : null;
  }

  @override
  Future<List<XFile>?> getMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    final List<dynamic>? paths = await _getMultiImagePath(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
    if (paths == null) {
      return null;
    }

    return paths.map((dynamic path) => XFile(path as String)).toList();
  }

  @override
  Future<XFile?> getVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) async {
    final String? path = await _getVideoPath(
      source: source,
      maxDuration: maxDuration,
      preferredCameraDevice: preferredCameraDevice,
    );
    return path != null ? XFile(path) : null;
  }

  @override
  Future<XFile?> getAudio({
    required AudioSource source,
  }) async {
    final String? path = await _getAudioPath(
      source: source
    );
    return path != null ? XFile(path) : null;
  }

  @override
  Future<LostData> retrieveLostData() async {
    final LostDataResponse result = await getLostData();

    if (result.isEmpty) {
      return LostData.empty();
    }

    return LostData(
      file: result.file != null ? PickedFile(result.file!.path) : null,
      exception: result.exception,
      type: result.type,
    );
  }

  @override
  Future<LostDataResponse> getLostData() async {
    List<XFile>? pickedFileList;

    final Map<String, dynamic>? result =
        await _channel.invokeMapMethod<String, dynamic>('retrieve');

    if (result == null) {
      return LostDataResponse.empty();
    }

    assert(result.containsKey('path') != result.containsKey('errorCode'));

    final String? type = result['type'] as String?;
    assert(type == kTypeImage || type == kTypeVideo);

    RetrieveType? retrieveType;
    if (type == kTypeImage) {
      retrieveType = RetrieveType.image;
    } else if (type == kTypeVideo) {
      retrieveType = RetrieveType.video;
    }

    PlatformException? exception;
    if (result.containsKey('errorCode')) {
      exception = PlatformException(
          code: result['errorCode']! as String,
          message: result['errorMessage'] as String?);
    }

    final String? path = result['path'] as String?;

    final List<String>? pathList =
        (result['pathList'] as List<dynamic>?)?.cast<String>();
    if (pathList != null) {
      pickedFileList = <XFile>[];
      for (final String path in pathList) {
        pickedFileList.add(XFile(path));
      }
    }

    return LostDataResponse(
      file: path != null ? XFile(path) : null,
      exception: exception,
      type: retrieveType,
      files: pickedFileList,
    );
  }
}
