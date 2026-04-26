const baseURL = "http://10.82.130.157:8000/api";
const baseUrlForLink = "http://10.65.116.157:8000";
const baseURlForImages = "http://10.82.130.157:8000/storage";

/// Construit l'URL complète pour une image provenant du stockage Laravel
String getFullImageUrl(String? path, {String defaultImage = "assets/images/saf.jpg"}) {
  if (path == null || path.isEmpty) return defaultImage;
  if (path.startsWith('http')) return path;
  if (path.startsWith('assets/')) return path;
  return "$baseURlForImages/$path";
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
