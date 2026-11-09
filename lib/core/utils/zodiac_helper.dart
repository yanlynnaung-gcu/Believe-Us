class ZodiacHelper {
  static ({String name, String symbol, String emoji}) getZodiac(DateTime date) {
    final day = date.day;
    final month = date.month;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return (name: 'Aries', symbol: '♈', emoji: '🔥');
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return (name: 'Taurus', symbol: '♉', emoji: '🌸');
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return (name: 'Gemini', symbol: '♊', emoji: '✨');
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return (name: 'Cancer', symbol: '♋', emoji: '🌙');
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return (name: 'Leo', symbol: '♌', emoji: '☀️');
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return (name: 'Virgo', symbol: '♍', emoji: '🌿');
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return (name: 'Libra', symbol: '♎', emoji: '⚖️');
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return (name: 'Scorpio', symbol: '♏', emoji: '🌹');
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return (name: 'Sagittarius', symbol: '♐', emoji: '🏹');
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return (name: 'Capricorn', symbol: '♑', emoji: '🪐');
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return (name: 'Aquarius', symbol: '♒', emoji: '🌊');
    } else {
      return (name: 'Pisces', symbol: '♓', emoji: '💫');
    }
  }

  static int getDaysUntilBirthday(DateTime birthday) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var nextBirthday = DateTime(today.year, birthday.month, birthday.day);

    if (nextBirthday.isBefore(today)) {
      nextBirthday = DateTime(today.year + 1, birthday.month, birthday.day);
    }
    return nextBirthday.difference(today).inDays;
  }
}
