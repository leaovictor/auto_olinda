/// Configuração centralizada de SEO para Auto Olinda
///
/// Este arquivo contém todas as configurações de SEO usadas no aplicativo.
/// Facilita a manutenção e atualização de meta tags e informações de SEO.

class SEOConfig {
  /// Informações básicas do site
  static const String siteName = 'Auto Olinda';
  static const String baseUrl = 'https://autoolinda.com.br';
  static const String businessName = 'Auto Olinda - Estética Automotiva';

  /// Localização
  static const String city = 'Olinda';
  static const String state = 'PE';
  static const String country = 'Brasil';
  static const String fullLocation = 'Olinda/PE';

  /// Coordenadas GPS (substituir com coordenadas reais)
  static const double latitude = -8.0089;
  static const double longitude = -34.8553;

  /// Contato (substituir com informações reais)
  static const String phoneNumber = '+55 81 99731-6643';
  static const String email = 'contato@autoolinda.com.br';

  /// Palavras-chave principais
  static const List<String> primaryKeywords = [
    'lava-jato olinda',
    'estética automotiva olinda',
    'lavagem de carro olinda',
    'polimento automotivo olinda',
    'higienização automotiva',
    'detailing olinda',
  ];

  /// Palavras-chave secundárias
  static const List<String> secondaryKeywords = [
    'lava-jato recife',
    'lavagem premium',
    'car detailing',
    'estética veicular',
    'polimento técnico',
    'cristalização pintura',
  ];
}

/// Metadata de SEO para páginas específicas
class SEOMetadata {
  final String title;
  final String description;
  final List<String> keywords;
  final String? canonicalUrl;
  final String? ogImage;

  const SEOMetadata({
    required this.title,
    required this.description,
    required this.keywords,
    this.canonicalUrl,
    this.ogImage,
  });

  /// Título completo com nome do site
  String get fullTitle => '$title | ${SEOConfig.siteName}';

  /// Keywords como string separada por vírgulas
  String get keywordsString => keywords.join(', ');
}

/// Configurações de SEO por rota
class SEORoutes {
  /// Home / Landing Page
  static const home = SEOMetadata(
    title: 'Auto Olinda - Estética Automotiva Premium em Olinda/PE',
    description:
        '🚗 Lavagem premium, polimento profissional e higienização '
        'automotiva em Olinda/PE. Transforme seu carro com serviços de qualidade. '
        'Agende agora!',
    keywords: [
      'lava-jato olinda',
      'estética automotiva olinda',
      'lavagem premium olinda',
      'polimento carro olinda',
      'auto olinda',
      'detailing olinda pe',
    ],
    canonicalUrl: 'https://autoolinda.com.br/',
  );

  /// Página de Login
  static const signIn = SEOMetadata(
    title: 'Login - Área do Cliente',
    description:
        'Acesse sua conta Auto Olinda para agendar lavagens, '
        'acompanhar histórico de serviços e gerenciar seus veículos.',
    keywords: ['login auto olinda', 'área do cliente', 'agendar lavagem'],
    canonicalUrl: 'https://autoolinda.com.br/sign-in',
  );

  /// Página de Cadastro
  static const signUp = SEOMetadata(
    title: 'Cadastro - Crie sua Conta',
    description:
        'Crie sua conta na Auto Olinda e aproveite agendamento online, '
        'histórico de serviços e promoções exclusivas!',
    keywords: ['cadastro auto olinda', 'criar conta', 'agendar online'],
    canonicalUrl: 'https://autoolinda.com.br/sign-up',
  );

  /// Mapa de rotas para SEO metadata
  static const Map<String, SEOMetadata> routes = {
    '/': home,
    '/sign-in': signIn,
    '/sign-up': signUp,
  };

  /// Obter metadata para uma rota específica
  static SEOMetadata? getMetadata(String route) {
    return routes[route];
  }
}

/// Estrutura de Schema.org para diferentes tipos de conteúdo
class SchemaOrg {
  /// Schema para LocalBusiness / AutoRepair
  static Map<String, dynamic> get localBusiness => {
    '@context': 'https://schema.org',
    '@type': 'AutoRepair',
    'name': SEOConfig.businessName,
    'description':
        'Estética automotiva e lava-jato premium em ${SEOConfig.fullLocation}',
    'url': SEOConfig.baseUrl,
    'telephone': SEOConfig.phoneNumber,
    'email': SEOConfig.email,
    'address': {
      '@type': 'PostalAddress',
      'streetAddress': 'R. Santa Teresinha, 440, Jardim Atlântico, Olinda/PE',
      'addressLocality': SEOConfig.city,
      'addressRegion': SEOConfig.state,
      'postalCode': '53140-170',
      'addressCountry': 'BR',
    },
    'geo': {
      '@type': 'GeoCoordinates',
      'latitude': SEOConfig.latitude,
      'longitude': SEOConfig.longitude,
    },
    'openingHoursSpecification': [
      {
        '@type': 'OpeningHoursSpecification',
        'dayOfWeek': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        'opens': '08:00',
        'closes': '17:00',
      },
      {
        '@type': 'OpeningHoursSpecification',
        'dayOfWeek': 'Saturday',
        'opens': '08:00',
        'closes': '15:00',
      },
    ],
    'priceRange': r'$$',
    'image': '${SEOConfig.baseUrl}/og-image.png',
  };

  /// Schema para Service (serviços oferecidos)
  static List<Map<String, dynamic>> get services => [
    {
      '@type': 'Service',
      'serviceType': 'Lavagem Premium',
      'description': 'Lavagem completa externa e interna com produtos premium',
      'provider': {'@type': 'AutoRepair', 'name': SEOConfig.businessName},
    },
    {
      '@type': 'Service',
      'serviceType': 'Polimento Profissional',
      'description':
          'Polimento técnico para remoção de riscos e restauração do brilho',
      'provider': {'@type': 'AutoRepair', 'name': SEOConfig.businessName},
    },
    {
      '@type': 'Service',
      'serviceType': 'Higienização Interna',
      'description':
          'Limpeza profunda de estofados, carpetes e ar-condicionado',
      'provider': {'@type': 'AutoRepair', 'name': SEOConfig.businessName},
    },
  ];
}
