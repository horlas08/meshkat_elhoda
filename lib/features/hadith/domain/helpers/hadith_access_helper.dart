/// Helper class to manage Hadith access permissions based on subscription
class HadithAccessHelper {
  // Free books (available for all users)
  static const List<String> freeBooks = ['bukhari', 'muslim'];

  // Premium books (requires premium subscription)
  static const List<String> premiumBooks = [
    'abudawud',
    'ibnmajah',
    'tirmidhi',
    'nasai',
    'malik',
    'nawawi',
    'qudsi',
    'dehlawi',
  ];

  /// Check if user has premium subscription
  static bool isPremium(String subscriptionType) {
    return subscriptionType == 'premium';
  }

  /// Check if a book is accessible by the user
  static bool canAccessBook(String bookId, String subscriptionType) {
    // Free books are accessible to everyone
    if (freeBooks.contains(bookId)) {
      return true;
    }

    // Premium books require premium subscription
    if (premiumBooks.contains(bookId)) {
      return isPremium(subscriptionType);
    }

    // Unknown books default to premium-only
    return isPremium(subscriptionType);
  }

  /// Get list of accessible books for user
  static List<String> getAccessibleBooks(String subscriptionType) {
    if (isPremium(subscriptionType)) {
      return [...freeBooks, ...premiumBooks];
    }
    return freeBooks;
  }

  /// Check if user can use translations
  static bool canUseTranslation(
    String subscriptionType,
    bool translationEnabled,
  ) {
    return isPremium(subscriptionType) && translationEnabled;
  }

  /// Get book display name
  static String getBookDisplayName(String bookId) {
    switch (bookId) {
      case 'bukhari':
        return 'صحيح البخاري';
      case 'muslim':
        return 'صحيح مسلم';
      case 'abudawud':
        return 'سنن أبي داود';
      case 'ibnmajah':
        return 'سنن ابن ماجه';
      case 'tirmidhi':
        return 'جامع الترمذي';
      case 'nasai':
        return 'سنن النسائي';
      case 'malik':
        return 'موطأ مالك';
      case 'nawawi':
        return 'الأربعون النووية';
      case 'qudsi':
        return 'الأحاديث القدسية';
      case 'dehlawi':
        return 'أربعون حديث للدهلوي';
      default:
        return bookId;
    }
  }

  /// Check if book is premium
  static bool isBookPremium(String bookId) {
    return premiumBooks.contains(bookId);
  }
}
