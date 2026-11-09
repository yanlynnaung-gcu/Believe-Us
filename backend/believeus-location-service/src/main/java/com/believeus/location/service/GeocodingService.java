package com.believeus.location.service;

import org.springframework.stereotype.Service;

@Service
public class GeocodingService {

    public String reverseGeocode(double latitude, double longitude) {
        // Reverse geocoding logic with fallback
        if (Math.abs(latitude - 16.8295) < 0.02 && Math.abs(longitude - 96.1305) < 0.02) {
            return "No. 42, Pyay Road, Kamayut Township, Yangon";
        }
        if (Math.abs(latitude - 16.8271) < 0.02 && Math.abs(longitude - 96.1284) < 0.02) {
            return "Hledan Center, Insein Road, Kamayut, Yangon";
        }
        if (Math.abs(latitude - 16.7795) < 0.02 && Math.abs(longitude - 96.1603) < 0.02) {
            return "Sule Square, Kyauktada Township, Yangon";
        }
        if (Math.abs(latitude - 16.8053) < 0.02 && Math.abs(longitude - 96.1558) < 0.02) {
            return "Shwedagon Pagoda Road, Dagon Township, Yangon";
        }
        return String.format("Lat: %.4f, Lng: %.4f", latitude, longitude);
    }
}
