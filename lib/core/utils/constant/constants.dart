import 'package:intl/intl.dart';

const appName = 'Metal';
const baseUrl = "http://ec2-54-237-199-205.compute-1.amazonaws.com:9000";

const kCountriesJsonFileName = 'countries.json';

const appSignKey =
    "4cc22b7da37ea92abd74fe90b0a6d87fd897d4f33696169242eddd05b160680a";
const appIDKey = 873617975;

const resourceID = "metal_call";

// Development environment URLs
const String devBaseUrl =
    'https://dev-api.metal.com'; // Update with your actual dev API URL
const String liveBaseUrl =
    'https://api.metal.com'; // Update with your actual prod API URL

// Package names for different environments
const String kPackageNameDev = 'com.bwh.metal.dev';
const String kPackageName = 'com.bwh.metal';


// class AppConstants {
//   static const String devBaseUrl = 'https://dev.example.com';
//   static const String liveBaseUrl = 'https://live.example.com';
//   static const String kAppName = 'MyApp';
//   static const String kPackageNameDev = 'com.example.myapp.dev';
//   static const String kPackageName = 'com.example.myapp';
// }