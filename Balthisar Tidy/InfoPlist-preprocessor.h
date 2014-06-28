/*
	Targets macros are defined in Target Settings -> Packaging -> Info.plist Preprocessor Definitions
	Note: you CANNOT indent any of the stuff below for legibility. Linker throws a fit.
 */
#if defined TARGET_WEB
#define TIDY_BUNDLE_IDENTIFIER com.balthisar.web.free.balthisar-tidy
#define TIDY_HELP_BOOK_FOLDER Balthisar Tidy (web).help
#define TIDY_HELP_BOOK_KEY com.balthisar.web.free.balthisar-tidy.help
#elif defined TARGET_APP
#define TIDY_BUNDLE_IDENTIFIER com.balthisar.Balthisar-Tidy
#define TIDY_HELP_BOOK_FOLDER Balthisar Tidy (app).help
#define TIDY_HELP_BOOK_KEY com.balthisar.Balthisar-Tidy.help
#elif defined TARGET_PRO
#define TIDY_BUNDLE_IDENTIFIER com.balthisar.Balthisar-Tidy.pro
#define TIDY_HELP_BOOK_FOLDER Balthisar Tidy (pro).help
#define TIDY_HELP_BOOK_KEY com.balthisar.Balthisar-Tidy.pro.help
#endif
