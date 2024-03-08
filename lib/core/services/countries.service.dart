import 'dart:convert';

import 'package:flutter/services.dart';

class CountriesService {
  Future<List<String>> getCountryNames() async {
    String jsonString = await rootBundle.loadString('assets/json/countries.json');
    List<dynamic> countriesList = json.decode(jsonString);

    List<String> countryNames = [];
    for (var country in countriesList) {
      countryNames.add(country['name']);
    }

    return countryNames;
  }

  Future<List<String>> getStateNames(String countryName) async {
    String jsonString = await rootBundle.loadString('assets/json/countries.json');
    List<dynamic> countriesList = json.decode(jsonString);

    List<String> stateNames = [];
    for (var country in countriesList) {
      if (country['name'] == countryName) {
        for (var state in country['states']) {
          stateNames.add(state['name']);
        }
        break;
      }
    }

    return stateNames;
  }
}
