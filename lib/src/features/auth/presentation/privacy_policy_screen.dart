import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Tela de Política de Privacidade (LGPD)
/// Exibe o texto completo da política de privacidade do aplicativo.
class PrivacyPolicyScreen extends StatelessWidget {
  final bool showBackButton;

  const PrivacyPolicyScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (showBackButton)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Colors.white,
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.privacy_tip_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  'Política de Privacidade',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lei Geral de Proteção de Dados (LGPD)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showBackButton) const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(theme, 'POLÍTICA DE PRIVACIDADE', '''
Esta Política de Privacidade descreve como o aplicativo "CleanFlow - Sistema de Gestão de Lava-Jato" ("Aplicativo") coleta, usa, armazena e protege seus dados pessoais, em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018 - LGPD).

**Controlador dos Dados:**
Victor Leão
Email: contato@victorleao.dev.br

Última atualização: ${DateTime.now().day}/${DateTime.now().month}/$currentYear
'''),
                      _buildSection(theme, '1. DADOS COLETADOS', '''
Coletamos os seguintes dados pessoais:

**1.1. Dados fornecidos por você:**
• Nome completo
• Endereço de e-mail
• Número de telefone
• Endereço (para serviços de coleta/entrega)
• Dados de veículo (placa, modelo, cor)
• Foto de perfil (opcional)

**1.2. Dados coletados automaticamente:**
• Endereço IP
• Identificador do dispositivo
• Sistema operacional e versão
• Data e hora de acesso
• Localização (quando autorizado)
• Registros de uso do aplicativo

**1.3. Dados de pagamento:**
Os dados de cartão de crédito são processados diretamente por nossos parceiros de pagamento (Stripe) e **não são armazenados** em nossos servidores.
'''),
                      _buildSection(theme, '2. FINALIDADE DO USO DOS DADOS', '''
Utilizamos seus dados para as seguintes finalidades:

**2.1. Prestação do Serviço:**
• Criar e gerenciar sua conta
• Processar agendamentos de serviços
• Comunicar-se sobre seus pedidos
• Processar pagamentos

**2.2. Melhoria do Serviço:**
• Analisar padrões de uso do aplicativo
• Desenvolver novos recursos
• Corrigir bugs e melhorar a performance

**2.3. Comunicação:**
• Enviar notificações sobre seus agendamentos
• Informar sobre atualizações do aplicativo
• Enviar comunicações de marketing (com seu consentimento)

**2.4. Segurança:**
• Prevenir fraudes e atividades suspeitas
• Garantir a integridade do sistema
• Cumprir obrigações legais
'''),
                      _buildSection(theme, '3. COMPARTILHAMENTO DE DADOS', '''
Podemos compartilhar seus dados nas seguintes situações:

**3.1. Prestadores de Serviço Parceiros:**
Compartilhamos dados necessários (nome, telefone, dados do veículo, localização) com os lava-jatos parceiros para execução do serviço contratado.

**3.2. Processadores de Pagamento:**
Dados de transação são compartilhados com o Stripe para processamento seguro de pagamentos.

**3.3. Serviços de Infraestrutura:**
• Firebase (Google) - autenticação e banco de dados
• Google Cloud Platform - hospedagem

**3.4. Obrigações Legais:**
Podemos divulgar dados quando exigido por lei, ordem judicial ou autoridade competente.

**NÃO vendemos, alugamos ou comercializamos seus dados pessoais.**
'''),
                      _buildSection(theme, '4. ARMAZENAMENTO E SEGURANÇA', '''
**4.1. Onde armazenamos:**
Seus dados são armazenados em servidores seguros do Google Cloud Platform, localizados nos Estados Unidos, com proteções adequadas conforme a LGPD.

**4.2. Por quanto tempo:**
• Dados de conta: enquanto sua conta estiver ativa
• Dados de agendamentos: 5 anos (obrigação fiscal)
• Dados de aceite do NDA: 5 anos (conforme contrato)
• Logs de acesso: 6 meses

**4.3. Medidas de Segurança:**
• Criptografia de dados em trânsito (TLS/SSL)
• Criptografia de dados em repouso
• Controle de acesso restrito
• Monitoramento de segurança
• Backups regulares
'''),
                      _buildSection(theme, '5. SEUS DIREITOS (LGPD)', '''
Conforme a LGPD, você tem os seguintes direitos:

**a) Confirmação e Acesso:**
Solicitar confirmação de que tratamos seus dados e obter cópia dos mesmos.

**b) Correção:**
Solicitar a correção de dados incompletos, inexatos ou desatualizados.

**c) Anonimização, Bloqueio ou Eliminação:**
Solicitar a anonimização, bloqueio ou eliminação de dados desnecessários ou tratados em desconformidade.

**d) Portabilidade:**
Solicitar a portabilidade dos dados a outro fornecedor de serviço.

**e) Eliminação:**
Solicitar a eliminação dos dados tratados com seu consentimento.

**f) Revogação do Consentimento:**
Revogar o consentimento a qualquer momento.

**g) Oposição:**
Opor-se a tratamento que viole a LGPD.

Para exercer seus direitos, entre em contato pelo e-mail: **contato@victorleao.dev.br**
'''),
                      _buildSection(
                        theme,
                        '6. COOKIES E TECNOLOGIAS SIMILARES',
                        '''
Utilizamos cookies e tecnologias similares para:

• Manter você logado no aplicativo
• Lembrar suas preferências
• Analisar o uso do aplicativo
• Melhorar a experiência do usuário

Você pode gerenciar as preferências de cookies nas configurações do seu navegador ou dispositivo.
''',
                      ),
                      _buildSection(theme, '7. MENORES DE IDADE', '''
O Aplicativo não é destinado a menores de 18 anos. Não coletamos intencionalmente dados de menores de idade. Se tomarmos conhecimento de que coletamos dados de um menor, tomaremos medidas para excluí-los.
'''),
                      _buildSection(theme, '8. ALTERAÇÕES NESTA POLÍTICA', '''
Podemos atualizar esta Política de Privacidade periodicamente. Notificaremos você sobre alterações significativas através do aplicativo ou por e-mail.

Recomendamos que você revise esta política regularmente.
'''),
                      _buildSection(theme, '9. CONTATO', '''
Para dúvidas, solicitações ou reclamações relacionadas a esta Política de Privacidade ou ao tratamento de seus dados pessoais, entre em contato:

**Encarregado de Proteção de Dados (DPO):**
Victor Leão
E-mail: contato@victorleao.dev.br

**Autoridade Nacional de Proteção de Dados (ANPD):**
Caso não esteja satisfeito com nossa resposta, você pode apresentar reclamação à ANPD.
Website: https://www.gov.br/anpd
'''),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              children: _parseMarkdownBold(content.trim(), theme),
            ),
          ),
        ],
      ),
    );
  }

  /// Parser simples que converte **texto** em negrito
  List<TextSpan> _parseMarkdownBold(String text, ThemeData theme) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans.isEmpty ? [TextSpan(text: text)] : spans;
  }
}
