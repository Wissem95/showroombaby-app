const checkPermissions = async () => {
  // Vérifier si on a déjà fait une vérification récemment
  const now = Date.now();
  if (now - lastLocationCheck < LOCATION_CHECK_INTERVAL) {
    return;
  }

  const { status } = await Location.requestForegroundPermissionsAsync();
  setLocationPermission(status === 'granted');

  if (status === 'granted') {
    try {
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.Balanced
      });
      const { latitude, longitude } = location.coords;

      // Mettre à jour le timestamp de la dernière vérification
      setLastLocationCheck(now);

      const response = await Location.reverseGeocodeAsync({
        latitude,
        longitude
      });

      if (response[0]) {
        const { city, region, postalCode } = response[0];
        const locationString = `${city || ''}, ${postalCode || ''} ${region || ''}`.trim();
        setUserLocation(locationString);
        setProductData(prev => ({ ...prev, location: locationString }));
      }
    } catch (error) {
      console.error('Erreur de localisation:', error);
    }
  }
};
