import 'package:thae_nge_lay/features/gifting/domain/models/gift_package.dart';

/// Predefined romantic couple gift packages
const List<GiftPackage> kDefaultGiftPackages = [
  GiftPackage(
    id: 'pkg_10k',
    title: 'Pocket Blessing',
    description: 'Morning coffee & sweet treat',
    amountMmK: 10000,
    iconEmoji: '☕',
    categoryTag: 'Monetary',
  ),
  GiftPackage(
    id: 'pkg_30k',
    title: 'Darling Care Package',
    description: 'Snacks and love essentials',
    amountMmK: 30000,
    iconEmoji: '🍰',
    categoryTag: 'Monetary',
  ),
  GiftPackage(
    id: 'pkg_roses',
    title: '99 Red Roses Bouquet',
    description: 'Everlasting romance across distance',
    amountMmK: 35000,
    iconEmoji: '🌹',
    categoryTag: 'Virtual Bouquet',
  ),
  GiftPackage(
    id: 'pkg_50k',
    title: 'Golden Love Blessing',
    description: 'Generous couple gift',
    amountMmK: 50000,
    iconEmoji: '🎁',
    categoryTag: 'Monetary',
  ),
  GiftPackage(
    id: 'pkg_dinner',
    title: 'Candlelight Date Feast',
    description: 'Luxury dinner treat for two',
    amountMmK: 80000,
    iconEmoji: '🍷',
    categoryTag: 'Virtual Date',
  ),
  GiftPackage(
    id: 'pkg_flight',
    title: 'Reunion Flight Ticket',
    description: 'Bridging the distance to hold you',
    amountMmK: 150000,
    iconEmoji: '✈️',
    categoryTag: 'Reunion Fund',
  ),
];
