class NdaSection {
  final String title;
  final String content;

  const NdaSection(this.title, this.content);
}

class NdaContent {
  static List<NdaSection> getSections(int currentYear) {
    return [
      const NdaSection('1. OBJETO', '''
Este Acordo tem por objeto estabelecer as condições de confidencialidade aplicáveis ao acesso e uso do software "Auto Olinda - Sistema de Gestão de Lava-Jato" em sua versão ALFA de testes, protegendo toda a Propriedade Intelectual e segredos de negócio a ele relacionados.
'''),
      const NdaSection('2. INFORMAÇÕES CONFIDENCIAIS', '''
São consideradas INFORMAÇÕES CONFIDENCIAIS (IC), sem limitação:

a) Todo o código-fonte, **algoritmos**, design e **arquitetura** do software;
b) Funcionalidades, fluxos e interfaces do aplicativo (existentes ou planejadas);
c) Documentação técnica, planos de desenvolvimento e estratégias de negócio;
d) Dados de outros usuários, incluindo dados pessoais, processados pelo sistema;
e) Bugs, vulnerabilidades, falhas e problemas de segurança identificados;
f) Qualquer informação técnica, comercial, financeira ou de PI não disponível publicamente.
'''),
      const NdaSection('3. OBRIGAÇÕES DO USUÁRIO', '''
O USUÁRIO compromete-se, em caráter irrevogável, a:

a) NÃO divulgar, compartilhar, reproduzir ou tornar públicas as Informações Confidenciais por qualquer meio;
b) NÃO realizar capturas de tela, gravações (áudio/vídeo) ou cópias para compartilhamento ou uso próprio;
c) NÃO discutir funcionalidades, performance ou problemas do aplicativo em redes sociais, fóruns públicos ou mídias de imprensa;
d) **NÃO compartilhar as credenciais de acesso** nem permitir acesso de terceiros à sua conta ou ao aplicativo;
e) NÃO realizar engenharia reversa, desmontagem, descompilação ou qualquer tentativa de obter o código-fonte ou a lógica de negócio subjacente;
f) Reportar bugs e problemas exclusivamente ao Desenvolvedor, pelos canais oficiais;
g) Utilizar o sistema apenas para fins de teste e avaliação autorizados.
'''),
      const NdaSection('4. DURAÇÃO', '''
Este Acordo entra em vigor na data do aceite. A obrigação de confidencialidade do USUÁRIO permanecerá válida por um período de **5 (cinco) anos** a contar desta data, mesmo após o encerramento do período de testes ou exclusão da conta.
'''),
      const NdaSection('5. PENALIDADES', '''
A violação de qualquer cláusula deste Acordo constitui quebra contratual grave e poderá resultar em:

a) Rescisão imediata e permanente do acesso do USUÁRIO ao sistema, sem aviso prévio;
b) **Cláusula Penal (Multa Contratual)**: Pagamento de uma indenização mínima e **não compensatória** de **R\$ 10.000,00 (dez mil reais)**, a ser paga no prazo de 15 dias após a notificação da violação;
c) Esta multa será aplicada sem prejuízo da responsabilidade civil do USUÁRIO por **Perdas e Danos** apurados em valor superior, e das medidas judiciais cabíveis para cessar a violação (Ação de Obrigação de Não Fazer).

O USUÁRIO reconhece que a divulgação não autorizada das ICs causará danos financeiros e à reputação do Desenvolvedor, sendo a multa uma estimativa prévia de parte desses prejuízos.
'''),
      const NdaSection('6. VERSÃO ALFA', '''
O USUÁRIO está ciente de que:

a) Esta é uma versão ALFA em desenvolvimento ativo e restrito;
b) O sistema pode conter bugs, erros, instabilidades e vulnerabilidades;
c) Funcionalidades, design e dados podem ser alterados ou removidos sem aviso;
d) Não há garantias de disponibilidade ou performance;
e) O acesso e uso são por conta e risco exclusivo do USUÁRIO para fins de teste.
'''),
      const NdaSection('7. JURISDIÇÃO', '''
Este Acordo é regido e interpretado de acordo com as leis da República Federativa do Brasil. As partes elegem o **Foro da Comarca de Olinda/PE** como o único competente para dirimir quaisquer dúvidas ou conflitos decorrentes deste Acordo, renunciando a qualquer outro, por mais privilegiado que seja.
'''),
    ];
  }

  static String getHeader(DateTime date) {
    return '''
Este Acordo de Confidencialidade ("Acordo") é celebrado entre:

DESENVOLVEDOR: Victor Leão
Email: contato@victorleao.dev.br

USUÁRIO: A pessoa física que está realizando este cadastro.

Data de Aceite: ${date.day}/${date.month}/${date.year}
''';
  }

  /// Gera o texto completo do NDA para ser assinado (hash) e exibido
  static String generateFullText(DateTime date) {
    final buffer = StringBuffer();
    buffer.write('TERMOS DE CONFIDENCIALIDADE (NDA)\n\n');
    buffer.write(getHeader(date));
    buffer.write('\n');

    final sections = getSections(date.year);
    for (var section in sections) {
      buffer.write('${section.title}\n');
      buffer.write(section.content);
      buffer.write('\n');
    }

    return buffer.toString().trim();
  }
}
