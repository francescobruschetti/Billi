import 'package:Billy/enums/category_enum.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';

extension CategoryEnumParsing on String {
  CategoryEnum toCategoryEnum() {
    switch (toUpperCase()) {
      case 'BILLS':
        return CategoryEnum.BILLS;
      case 'CLOTHES':
        return CategoryEnum.CLOTHES;
      case 'DONATIONS':
        return CategoryEnum.DONATIONS;
      case 'EDUCATION':
        return CategoryEnum.EDUCATION;
      case 'ENSURANCE':
        return CategoryEnum.ENSURANCE;
      case 'ENTERTAINMENT':
        return CategoryEnum.ENTERTAINMENT;
      case 'FOOD_AND_DRINK':
        return CategoryEnum.FOOD_AND_DRINK;
      case 'GIFT':
        return CategoryEnum.GIFT;
      case 'GROCERIES':
        return CategoryEnum.GROCERIES;
      case 'HOME':
        return CategoryEnum.HOME;
      case 'HEALTH':
        return CategoryEnum.HEALTH;
      case 'INCOME':
        return CategoryEnum.INCOME;
      case 'OTHER':
        return CategoryEnum.OTHER;
      case 'PENSION':
        return CategoryEnum.PENSION;
      case 'PHONE':
        return CategoryEnum.PHONE;
      case 'SERVICES':
        return CategoryEnum.SERVICES;
      case 'SHOPPING':
        return CategoryEnum.SHOPPING;
      case 'SPORT':
        return CategoryEnum.SPORT;
      case 'SUBSCRIPTION':
        return CategoryEnum.SUBSCRIPTION;
      case 'TAXES':
        return CategoryEnum.TAXES;
      case 'TRANSPORTATION':
        return CategoryEnum.TRANSPORTATION;
      case 'TRAVEL':
        return CategoryEnum.TRAVEL;
      
      default:
        return CategoryEnum.OTHER;
    }
  }
}

extension CategoryEnumIcon on CategoryEnum {
  Widget toIcon() {
    switch (this) {
      case CategoryEnum.BILLS:
        return Icon(Icons.receipt);
      case CategoryEnum.CLOTHES:
        return Icon(Icons.shopping_bag);
      case CategoryEnum.DONATIONS:
        return Icon(Icons.favorite);
      case CategoryEnum.EDUCATION:
        return Icon(Icons.school);
      case CategoryEnum.ENSURANCE:
        return Icon(Icons.security);
      case CategoryEnum.ENTERTAINMENT:
        return Icon(Icons.movie);
      case CategoryEnum.FOOD_AND_DRINK:
        return Icon(Icons.restaurant);
      case CategoryEnum.GIFT:
        return Icon(Icons.card_giftcard);
      case CategoryEnum.GROCERIES:
        return Icon(Icons.local_grocery_store);
      case CategoryEnum.HOME:
        return Icon(Icons.home);
      case CategoryEnum.HEALTH:
        return Icon(Icons.local_hospital);
      case CategoryEnum.INCOME:
        return Icon(Icons.attach_money);
      case CategoryEnum.PENSION:
        return Icon(Icons.account_balance);
      case CategoryEnum.PHONE:
        return Icon(Icons.phone);
      case CategoryEnum.SERVICES:
        return Icon(Icons.build);
      case CategoryEnum.SHOPPING:
        return Icon(Icons.shopping_cart);
      case CategoryEnum.SPORT:
        return Icon(Icons.sports_soccer);
      case CategoryEnum.SUBSCRIPTION:
        return Icon(Icons.subscriptions);
      case CategoryEnum.TAXES:
        return Icon(Icons.receipt_long);
      case CategoryEnum.TRANSPORTATION:
        return Icon(Icons.directions_car);
      case CategoryEnum.TRAVEL:
        return Icon(Icons.flight);
      
      case CategoryEnum.OTHER:
        return CustomIconWidget(assetPath: 'assets/images/icons/sell-filled.PNG', color: Colors.orange);
    }
  }
}

// --- Add here other enum parsing extensions if needed ---
