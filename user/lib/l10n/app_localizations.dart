import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PatiWorld'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @animalCare.
  ///
  /// In en, this message translates to:
  /// **'Animal Care'**
  String get animalCare;

  /// No description provided for @petAdoption.
  ///
  /// In en, this message translates to:
  /// **'Pet Adoption'**
  String get petAdoption;

  /// No description provided for @veterinaryServices.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Services'**
  String get veterinaryServices;

  /// No description provided for @petLost.
  ///
  /// In en, this message translates to:
  /// **'Lost Pet'**
  String get petLost;

  /// No description provided for @petFound.
  ///
  /// In en, this message translates to:
  /// **'Found Pet'**
  String get petFound;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @vaccinated.
  ///
  /// In en, this message translates to:
  /// **'Vaccinated'**
  String get vaccinated;

  /// No description provided for @neutered.
  ///
  /// In en, this message translates to:
  /// **'Neutered'**
  String get neutered;

  /// No description provided for @specialNeeds.
  ///
  /// In en, this message translates to:
  /// **'Special Needs'**
  String get specialNeeds;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @adoptionFee.
  ///
  /// In en, this message translates to:
  /// **'Adoption Fee'**
  String get adoptionFee;

  /// No description provided for @contactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact Owner'**
  String get contactOwner;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @reportAbuse.
  ///
  /// In en, this message translates to:
  /// **'Report Abuse'**
  String get reportAbuse;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get locationPermission;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password is too short'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselectAll;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @maybe.
  ///
  /// In en, this message translates to:
  /// **'Maybe'**
  String get maybe;

  /// No description provided for @always.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get always;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @sometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get sometimes;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYear;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get lastYear;

  /// No description provided for @nextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get nextYear;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover useful information about caring for your pets'**
  String get welcomeSubtitle;

  /// No description provided for @noPetsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No pets available at the moment'**
  String get noPetsAvailable;

  /// No description provided for @dataLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Data loading error'**
  String get dataLoadingError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @pleaseEnterEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address first'**
  String get pleaseEnterEmailFirst;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email address'**
  String get passwordResetEmailSent;

  /// No description provided for @animalFriendlyApp.
  ///
  /// In en, this message translates to:
  /// **'Animal Friendly App'**
  String get animalFriendlyApp;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailAddress;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {count} characters'**
  String passwordMinLength(int count);

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @editPersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit your personal information'**
  String get editPersonalInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @phoneNumberMinLength.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 10 digits'**
  String get phoneNumberMinLength;

  /// No description provided for @yourStatistics.
  ///
  /// In en, this message translates to:
  /// **'Your Statistics'**
  String get yourStatistics;

  /// No description provided for @activitySummary.
  ///
  /// In en, this message translates to:
  /// **'Activity summary'**
  String get activitySummary;

  /// No description provided for @lostPetListings.
  ///
  /// In en, this message translates to:
  /// **'Lost Pet Listings'**
  String get lostPetListings;

  /// No description provided for @adoptionListings.
  ///
  /// In en, this message translates to:
  /// **'Adoption Listings'**
  String get adoptionListings;

  /// No description provided for @registeredVaccinations.
  ///
  /// In en, this message translates to:
  /// **'Registered Vaccinations'**
  String get registeredVaccinations;

  /// No description provided for @daysInApp.
  ///
  /// In en, this message translates to:
  /// **'Days in App'**
  String get daysInApp;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changesSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get changesSavedSuccessfully;

  /// No description provided for @userInfoNotFound.
  ///
  /// In en, this message translates to:
  /// **'User information not found'**
  String get userInfoNotFound;

  /// No description provided for @errorSavingChanges.
  ///
  /// In en, this message translates to:
  /// **'Error saving changes'**
  String get errorSavingChanges;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @errorLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Error logging out'**
  String get errorLoggingOut;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get removeImage;

  /// No description provided for @vaccinationCalendar.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Calendar'**
  String get vaccinationCalendar;

  /// No description provided for @vaccinationStatistics.
  ///
  /// In en, this message translates to:
  /// **'Vaccination Statistics'**
  String get vaccinationStatistics;

  /// No description provided for @failedToLoadVaccinations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load vaccinations'**
  String get failedToLoadVaccinations;

  /// No description provided for @noVaccinationsRegistered.
  ///
  /// In en, this message translates to:
  /// **'No vaccinations registered'**
  String get noVaccinationsRegistered;

  /// No description provided for @addVaccinationToTrack.
  ///
  /// In en, this message translates to:
  /// **'Add vaccination to track your pets'**
  String get addVaccinationToTrack;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @vaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get vaccine;

  /// No description provided for @vaccineDate.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Date'**
  String get vaccineDate;

  /// No description provided for @nextVaccine.
  ///
  /// In en, this message translates to:
  /// **'Next Vaccine'**
  String get nextVaccine;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get deleteConfirmation;

  /// No description provided for @confirmDeleteVaccination.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {petName}\'s vaccination?'**
  String confirmDeleteVaccination(String petName);

  /// No description provided for @vaccinationDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Vaccination deleted successfully'**
  String get vaccinationDeletedSuccessfully;

  /// No description provided for @failedToDeleteVaccination.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete vaccination'**
  String get failedToDeleteVaccination;

  /// No description provided for @noLostPetListings.
  ///
  /// In en, this message translates to:
  /// **'No lost pet listings at the moment'**
  String get noLostPetListings;

  /// No description provided for @addFirstLostPetListing.
  ///
  /// In en, this message translates to:
  /// **'Add the first lost pet listing'**
  String get addFirstLostPetListing;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @whatsappAppCannotBeOpened.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp app cannot be opened'**
  String get whatsappAppCannotBeOpened;

  /// No description provided for @whatsappCannotBeOpened.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp cannot be opened'**
  String get whatsappCannotBeOpened;

  /// No description provided for @copyNumberAndCallManually.
  ///
  /// In en, this message translates to:
  /// **'You can copy the number and call manually'**
  String get copyNumberAndCallManually;

  /// No description provided for @numberCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Number copied to clipboard'**
  String get numberCopiedToClipboard;

  /// No description provided for @copyNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy Number'**
  String get copyNumber;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Pet name, type, city or description...'**
  String get searchHint;

  /// No description provided for @petType.
  ///
  /// In en, this message translates to:
  /// **'Pet Type'**
  String get petType;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @noAdoptionListings.
  ///
  /// In en, this message translates to:
  /// **'No adoption listings at the moment'**
  String get noAdoptionListings;

  /// No description provided for @addFirstAdoptionListing.
  ///
  /// In en, this message translates to:
  /// **'Add the first adoption listing'**
  String get addFirstAdoptionListing;

  /// No description provided for @adoption.
  ///
  /// In en, this message translates to:
  /// **'Adoption'**
  String get adoption;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'{count} Months'**
  String months(int count);

  /// No description provided for @addLostPetListing.
  ///
  /// In en, this message translates to:
  /// **'Add Lost Pet Listing'**
  String get addLostPetListing;

  /// No description provided for @petName.
  ///
  /// In en, this message translates to:
  /// **'Pet Name'**
  String get petName;

  /// No description provided for @enterPetName.
  ///
  /// In en, this message translates to:
  /// **'Enter pet name'**
  String get enterPetName;

  /// No description provided for @pleaseEnterPetName.
  ///
  /// In en, this message translates to:
  /// **'Please enter pet name'**
  String get pleaseEnterPetName;

  /// No description provided for @petDescription.
  ///
  /// In en, this message translates to:
  /// **'Pet Description'**
  String get petDescription;

  /// No description provided for @describePetInDetail.
  ///
  /// In en, this message translates to:
  /// **'Describe the pet in detail (color, size, features, behavior...)'**
  String get describePetInDetail;

  /// No description provided for @pleaseEnterPetDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter pet description'**
  String get pleaseEnterPetDescription;

  /// No description provided for @lostDate.
  ///
  /// In en, this message translates to:
  /// **'Lost Date'**
  String get lostDate;

  /// No description provided for @ageInMonths.
  ///
  /// In en, this message translates to:
  /// **'Age (Months)'**
  String get ageInMonths;

  /// No description provided for @enterAgeInMonthsOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter age in months (optional)'**
  String get enterAgeInMonthsOptional;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @petPhoto.
  ///
  /// In en, this message translates to:
  /// **'Pet Photo'**
  String get petPhoto;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @healthStatus.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get healthStatus;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsappNumber;

  /// No description provided for @addListing.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get addListing;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get pleaseLogin;

  /// No description provided for @imageUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully!'**
  String get imageUploadedSuccessfully;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Image upload failed'**
  String get imageUploadFailed;

  /// No description provided for @storageSettings.
  ///
  /// In en, this message translates to:
  /// **'Storage Settings'**
  String get storageSettings;

  /// No description provided for @listingAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Listing added successfully'**
  String get listingAddedSuccessfully;

  /// No description provided for @errorAddingListing.
  ///
  /// In en, this message translates to:
  /// **'Error adding listing'**
  String get errorAddingListing;

  /// No description provided for @pleaseSelectValidImageFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid image file (JPG, PNG, GIF)'**
  String get pleaseSelectValidImageFile;

  /// No description provided for @imageSizeMustBeLessThan5MB.
  ///
  /// In en, this message translates to:
  /// **'Image size must be less than 5MB'**
  String get imageSizeMustBeLessThan5MB;

  /// No description provided for @errorSelectingImage.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get errorSelectingImage;

  /// No description provided for @addAdoptionListing.
  ///
  /// In en, this message translates to:
  /// **'Add Adoption Listing'**
  String get addAdoptionListing;

  /// No description provided for @enterAgeInMonths.
  ///
  /// In en, this message translates to:
  /// **'Enter age in months'**
  String get enterAgeInMonths;

  /// No description provided for @pleaseEnterAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter age'**
  String get pleaseEnterAge;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @selectLocationFromMap.
  ///
  /// In en, this message translates to:
  /// **'Select Location from Map'**
  String get selectLocationFromMap;

  /// No description provided for @locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location selected'**
  String get locationSelected;

  /// No description provided for @addVaccination.
  ///
  /// In en, this message translates to:
  /// **'Add Vaccination'**
  String get addVaccination;

  /// No description provided for @editVaccination.
  ///
  /// In en, this message translates to:
  /// **'Edit Vaccination'**
  String get editVaccination;

  /// No description provided for @vaccineType.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Type'**
  String get vaccineType;

  /// No description provided for @vaccineNumber.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Number'**
  String get vaccineNumber;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @enterAdditionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Enter additional notes'**
  String get enterAdditionalNotes;

  /// No description provided for @updateVaccination.
  ///
  /// In en, this message translates to:
  /// **'Update Vaccination'**
  String get updateVaccination;

  /// No description provided for @nextVaccineInfo.
  ///
  /// In en, this message translates to:
  /// **'Next Vaccine Information'**
  String get nextVaccineInfo;

  /// No description provided for @nextVaccineReminderDate.
  ///
  /// In en, this message translates to:
  /// **'Next vaccine reminder date:'**
  String get nextVaccineReminderDate;

  /// No description provided for @nextVaccineNumber.
  ///
  /// In en, this message translates to:
  /// **'Next vaccine number'**
  String get nextVaccineNumber;

  /// No description provided for @nextVaccineDate.
  ///
  /// In en, this message translates to:
  /// **'Next Vaccine Date'**
  String get nextVaccineDate;

  /// No description provided for @customVaccineName.
  ///
  /// In en, this message translates to:
  /// **'Custom Vaccine Name'**
  String get customVaccineName;

  /// No description provided for @enterCustomVaccineName.
  ///
  /// In en, this message translates to:
  /// **'Enter vaccine name'**
  String get enterCustomVaccineName;

  /// No description provided for @pleaseEnterCustomVaccineName.
  ///
  /// In en, this message translates to:
  /// **'Please enter vaccine name'**
  String get pleaseEnterCustomVaccineName;

  /// No description provided for @petDetails.
  ///
  /// In en, this message translates to:
  /// **'Pet Details'**
  String get petDetails;

  /// No description provided for @careMethod.
  ///
  /// In en, this message translates to:
  /// **'Care Method'**
  String get careMethod;

  /// No description provided for @importantFeatures.
  ///
  /// In en, this message translates to:
  /// **'Important Features'**
  String get importantFeatures;

  /// No description provided for @favoriteFoods.
  ///
  /// In en, this message translates to:
  /// **'Favorite Foods'**
  String get favoriteFoods;

  /// No description provided for @commonDiseases.
  ///
  /// In en, this message translates to:
  /// **'Common Diseases'**
  String get commonDiseases;

  /// No description provided for @cute.
  ///
  /// In en, this message translates to:
  /// **'Cute'**
  String get cute;

  /// No description provided for @clean.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get clean;

  /// No description provided for @independent.
  ///
  /// In en, this message translates to:
  /// **'Independent'**
  String get independent;

  /// No description provided for @loyal.
  ///
  /// In en, this message translates to:
  /// **'Loyal'**
  String get loyal;

  /// No description provided for @intelligent.
  ///
  /// In en, this message translates to:
  /// **'Intelligent'**
  String get intelligent;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// No description provided for @meat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get meat;

  /// No description provided for @dryFood.
  ///
  /// In en, this message translates to:
  /// **'Dry Food'**
  String get dryFood;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @urinaryTractInfection.
  ///
  /// In en, this message translates to:
  /// **'Urinary Tract Infection'**
  String get urinaryTractInfection;

  /// No description provided for @kidneyDiseases.
  ///
  /// In en, this message translates to:
  /// **'Kidney Diseases'**
  String get kidneyDiseases;

  /// No description provided for @diabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get diabetes;

  /// No description provided for @rabies.
  ///
  /// In en, this message translates to:
  /// **'Rabies'**
  String get rabies;

  /// No description provided for @arthritis.
  ///
  /// In en, this message translates to:
  /// **'Arthritis'**
  String get arthritis;

  /// No description provided for @heartDiseases.
  ///
  /// In en, this message translates to:
  /// **'Heart Diseases'**
  String get heartDiseases;

  /// No description provided for @catsArePopularPets.
  ///
  /// In en, this message translates to:
  /// **'Cats are one of the most popular pets in the world'**
  String get catsArePopularPets;

  /// No description provided for @dogsAreBestFriends.
  ///
  /// In en, this message translates to:
  /// **'Dogs are man\'s best friend and most loyal animals'**
  String get dogsAreBestFriends;

  /// No description provided for @catCareInstructions.
  ///
  /// In en, this message translates to:
  /// **'Requires regular litter cleaning and vaccinations'**
  String get catCareInstructions;

  /// No description provided for @dogCareInstructions.
  ///
  /// In en, this message translates to:
  /// **'Requires daily exercise and regular training'**
  String get dogCareInstructions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
