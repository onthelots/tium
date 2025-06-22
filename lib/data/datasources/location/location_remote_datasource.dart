import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tium/core/dio/api_client.dart';
import 'package:tium/data/models/location/location_dto.dart';

abstract class LocationRemoteDataSource {
  Future<LatLng> geocode(String query); // 주소 -> 행정동 코드
  Future<ReverseGeocodingResult> reverseGeocode(double lat, double lng);  // 좌표 -> 행정동 코드
}

class NaverLocationRemote implements LocationRemoteDataSource {
  final ApiClient client;
  NaverLocationRemote({required this.client});

  @override
  Future<LatLng> geocode(String query) async {
    final res = await client.get('/map-geocode/v2/geocode', query: {'query': query});
    final data = GeocodingResult.fromJson(jsonDecode(res.data));
    return data.latLng;
  }

  @override
  Future<ReverseGeocodingResult> reverseGeocode(double lat, double lng) async {
    final res = await client.get(
      '/map-reversegeocode/v2/gc',
      query: {
        'coords': '$lng,$lat',
        'output': 'json',
        'orders': 'admcode',
      },
    );
    debugPrint(res.data);
    final locationInformation = ReverseGeocodingResult.fromJson(jsonDecode(res.data));
    return locationInformation;
  }
}
