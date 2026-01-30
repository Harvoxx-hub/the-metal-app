import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/config/map_config.dart';
import 'package:metal/data/datasources/remote/google_places_data_source.dart';
import 'package:metal/data/datasources/remote/place_remote_data_source.dart';
import 'package:metal/data/repositories/place/place_repository.dart';

final placeRemoteDataSourceProvider = Provider<PlaceRemoteDataSource>((ref) {
  return PlaceRemoteDataSource();
});

final googlePlacesDataSourceProvider = Provider<GooglePlacesDataSource?>((ref) {
  return MapConfig.hasGoogleMapsKey ? GooglePlacesDataSource() : null;
});

final placeRepositoryProvider = Provider<PlaceRepository>((ref) {
  return PlaceRepository(
    nominatim: ref.read(placeRemoteDataSourceProvider),
    google: ref.read(googlePlacesDataSourceProvider),
  );
});
