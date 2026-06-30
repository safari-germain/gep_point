import 'package:flutter/material.dart';

const baseURL = "http://10.142.247.157:8000/api";
const baseUrlForLink = "http://10.142.247.157:8000";
const baseURlForImages = "http://10.142.247.157:8000/storage";

/// Construit l'URL complète pour une image provenant du stockage Laravel
String getFullImageUrl(String? path, {String defaultImage = "assets/images/saf.jpg"}) {
  if (path == null || path.isEmpty) return defaultImage;
  if (path.startsWith('assets/')) return path;

  String url = path;

  // Si le path contient "http" mais pas au début (ex: concatenation baseUrl + url absolue)
  if (url.contains('http') && !url.startsWith('http')) {
    int httpIndex = url.indexOf('http');
    url = url.substring(httpIndex);
  }

  // Si l'URL est absolue, nettoyer les hôtes locaux ou obsolètes
  if (url.startsWith('http')) {
    String cleanedUrl = url;
    cleanedUrl = cleanedUrl.replaceAll('localhost:8000', '10.192.57.157:8000');
    cleanedUrl = cleanedUrl.replaceAll('localhost', '10.192.57.157:8000');
    cleanedUrl = cleanedUrl.replaceAll('127.0.0.1:8000', '10.192.57.157:8000');
    cleanedUrl = cleanedUrl.replaceAll('127.0.0.1', '10.192.57.157:8000');
    cleanedUrl = cleanedUrl.replaceAll('10.198.48.157:8000', '10.192.57.157:8000');
    cleanedUrl = cleanedUrl.replaceAll('10.198.48.157', '10.192.57.157');
    return cleanedUrl;
  }

  // Chemin relatif
  String cleanPath = url;
  if (cleanPath.startsWith('/')) {
    cleanPath = cleanPath.substring(1);
  }
  if (cleanPath.startsWith('storage/')) {
    cleanPath = cleanPath.substring(8);
  }

  return "$baseURlForImages/$cleanPath";
}

/// Retourne l'ImageProvider approprié (NetworkImage ou AssetImage)
ImageProvider getImageProvider(String? path, {String defaultImage = "assets/images/saf.jpg"}) {
  String url = getFullImageUrl(path, defaultImage: defaultImage);
  if (url.startsWith('http')) {
    return NetworkImage(url);
  } else {
    return AssetImage(url);
  }
}

// APP INFO
const appName = "GEP POINT";

// AUTH
const loginURL = '$baseURL/login';
const registerURL = '$baseURL/register';
const logoutURL = '$baseURL/logout';
const userURL = '$baseURL/user';
const profileURL = '$baseURL/profile';
const competencesURL = '$baseURL/profile/competences';
const configsURL = '$baseURL/profile/configs';
const upgradeProfileURL = '$baseURL/profile/upgrade';
const specializedDetailsURL = '$baseURL/profile/specialized-details';
const portfolioURL = '$baseURL/portfolio';
String userPortfolioURL(int userId) => '$baseURL/users/$userId/portfolio';
const certificationURL = '$baseURL/certifications';
String userCertificationURL(int userId) => '$baseURL/users/$userId/certifications';

// WALLETS
const walletsURL = '$baseURL/wallets'; // GET

// TRANSACTIONS
const transactionsURL = '$baseURL/transactions'; // GET
const transferURL = '$baseURL/transactions/transfer'; // POST
const convertURL = '$baseURL/transactions/convert'; // POST

// ORGANISATIONS
const organisationsURL = '$baseURL/organisations';
const organisationCreateURL = '$baseURL/createOrganisation';

const distributeURL = '$baseURL/organisations/distribute'; // POST

// ORGANISATION CONTACTS (MEMBERS)
const orgContactsURL = '$baseURL/organisation-contacts'; // GET, POST, DELETE

// POINT SALES
const buyPointsURL = '$baseURL/point-sales/buy'; // POST
const pointSalesURL = '$baseURL/point-sales'; // GET

// POINT RATES
const pointRatesURL = '$baseURL/point-rates'; // GET, POST

// ADMIN
const adminStatsURL = '$baseURL/admin/gep-stats'; // GET

// ERRORS
const serverErrorL = 'Erreur du serveur';
const unauthorized = 'non connecté';
const somethingwentwrong = 'Quelque chose ne va pas';
