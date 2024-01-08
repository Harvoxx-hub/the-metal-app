import 'package:intl/intl.dart';

const appName = 'Metal';
const baseUrl = "http://ec2-54-237-199-205.compute-1.amazonaws.com:9000";

// Errors
const kInvalidVerCodeFirebaseError = 'invalid-verification-code';
const kEmailAlreadyInUse = 'email-already-in-use';
const kUserNotFound = 'user-not-found';
const kWrongPassword = 'wrong-password';

const kMaxFieldLength = 50;
const kMaxEmailLength = 129;
const kMinPasswordLength = 8;
const kMaxPasswordLength = 50;

const kMinNameLength = 1;
const kMaxNameLength = 50;

const kMaxServiceSessionNameLength = 100;
const kMaxServiceNotesLength = 200;

const kMinCardNumberLength = 14;
const kMaxCardNumberLength = 16;

const kMinCVVLength = 3;
const kMaxCVVLength = 4;

const kDebounce50ms = 50;

const kMaxReferralCodeLength = 10;

const kMaxAge = 100;
const kMinAge = 18;

const kCropWorkerPath = 'js/crop_worker.js';

final notificationDTF = DateFormat("MMM dd, yyyy 'at' hh:mm:ss a");
const kClientDOBFormat = 'MM dd yyyy';

const kMaxPictureSizeInMb = 10.0;
const kMaxPictureWidth = 1024;
const kMaxPictureHeight = 1024;

const kPaginationLimit = 15;

const kPasswordMaxLength = 50;
const kPasswordMinLength = 8;

//final kCurrency = Currency.create('USD', 2);

const kAvatarValidationMaxSizeMb = 10 * 1024 * 1024;
const kAvatarValidationMaxDimension = 1024;
const kPhotoValidationMaxSizeMb = 5 * 1024 * 1024;
// ignore: prefer-trailing-comma
const kImageValidationAllowedFormats = ['.jpeg', '.jpg', '.png'];
const kPhotoValidationMaxDimension = 3000.0;
const kImageValidationMinDimension = 72;

const kFirstNameMaxLength = 25;
const kLastNameMaxLength = 25;
const kStateMaxLength = 25;
const kCityMaxLength = 25;
const kAddress1MaxLength = 100;
const kNamePattern = r'[\p{L}\s-]';

const kSMSCodeLength = 6;

const kTimelineWidth = 60.0;
const kTimelineHeightPerMinute = 86.0 / 60;

const kSessionNotesMaxLength = 200;
const kSessionNotesMaxLines = 6;
const kMaxZipCodeLength = 10;

const kCmInInch = 2.54;

const kLbsInKg = 2.20462262;
const kInchInFoot = 12;
const kCmInMeter = 100;
const kDefaultWeightInKg = 75.0;
const kDefaultWeightInLbs = 165.0;
const kDefaultHeightInCm = 175.0;
const kDefaultHeightInInches = 70.0;
const kMaxWeightInKg = 300;
const kMaxWeightInLbs = 650;
const kMaxHeightInCm = 260;
const kMaxHeightInInches = 100;
const kCircumferenceMaxInches = 10;
const kSkinFoldsMaxInches = 4;
const kSkinFoldsDefaultImperial = 1.0; // inches
const kClientInfoTabBarHeight = 46.0;

const kInjuryDescriptionMaxLength = 200;

const kTrainingDescriptionMaxLength = 200;
const kMaxTimeSlotCount = 3;

const kCountriesJsonFileName = 'countries.json';

const kSwitchAnimationDurationMs = 100;
const kChatDetailsMessagesPageLimit = 20;

const kInvoicesListPageLimit = 10;

const kSkinFoldsDefaultMetric = 10.0; // mm

const kInvoiceMemoMaxLines = 6;
const kInvoiceMemoMaxLength = 200;
