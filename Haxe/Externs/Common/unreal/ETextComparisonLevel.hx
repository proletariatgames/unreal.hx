package unreal;

@:glueCppIncludes("Internationalization/Text.h")
@:uname("ETextComparisonLevel.Type")
@:uextern extern enum ETextComparisonLevel {
  Default;	// Locale-specific Default
  Primary;	// Base
  Secondary;	// Accent
  Tertiary;	// Case
  Quaternary;	// Punctuation
  Quinary;		// Identical
}
