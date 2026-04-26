class OnboardingPage {
  final String title;
  final String description;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });
}

final List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    title: "Bienvenue sur V-GEP",
    description: "La solution innovante pour valoriser l'engagement et le mérite au sein de votre organisation.",
    image: "assets/images/board_1.jpg",
  ),
  OnboardingPage(
    title: "Gagnez des Points",
    description: "Recevez des points GEP pour chaque contribution, mission ou performance réalisée avec succès.",
    image: "assets/images/board_2.jpg",
  ),
  OnboardingPage(
    title: "Distribution Transparente",
    description: "Un système de redistribution équitable et traçable en temps réel pour tous les membres.",
    image: "assets/images/board_3.jpg",
  ),
  OnboardingPage(
    title: "Valeur et Flexibilité",
    description: "Échangez, transférez ou convertissez vos points selon vos besoins et les opportunités.",
    image: "assets/images/board_4.jpg",
  ),
  OnboardingPage(
    title: "Prêt à rayonner ?",
    description: "Rejoignez l'écosystème GEP POINT et donnez une nouvelle dimension à votre travail.",
    image: "assets/images/board_5.jpg",
  ),
];
