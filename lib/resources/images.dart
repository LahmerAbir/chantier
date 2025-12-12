enum DeliveryImage {
  logo,
  background,

}

extension DeliveryImageName on DeliveryImage {
  String get name {
    switch (this) {
      case DeliveryImage.logo:
        return 'logo';
      case DeliveryImage.background:
        return 'background';
    }
  }
}
