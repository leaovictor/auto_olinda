import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NdaScreen extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const NdaScreen({super.key, required this.onAccept, required this.onDecline});

  @override
  State<NdaScreen> createState() => _NdaScreenState();
}

class _NdaScreenState extends State<NdaScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;
  bool _hasAccepted = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToEnd) {
        setState(() => _hasScrolledToEnd = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.security_rounded, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    'Acordo de Confidencialidade',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'VERSÃO ALFA - TESTE RESTRITO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            // NDA Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          theme,
                          'TERMOS DE CONFIDENCIALIDADE (NDA)',
                          '''
Este Acordo de Confidencialidade ("Acordo") é celebrado entre:

DESENVOLVEDOR: Victor Leão
Email: contato@victorleao.dev.br

USUÁRIO: A pessoa física que está realizando este cadastro.

Data de Aceite: ${DateTime.now().day}/${DateTime.now().month}/$currentYear
''',
                        ),
                        _buildSection(theme, '1. OBJETO', '''
Este Acordo tem por objeto estabelecer as condições de confidencialidade aplicáveis ao acesso e uso do software "Auto Olinda - Sistema de Gestão de Lava-Jato" em sua versão ALFA de testes, protegendo toda a Propriedade Intelectual e segredos de negócio a ele relacionados.
'''),
                        _buildSection(theme, '2. INFORMAÇÕES CONFIDENCIAIS', '''
São consideradas INFORMAÇÕES CONFIDENCIAIS (IC), sem limitação:

a) Todo o código-fonte, **algoritmos**, design e **arquitetura** do software;
b) Funcionalidades, fluxos e interfaces do aplicativo (existentes ou planejadas);
c) Documentação técnica, planos de desenvolvimento e estratégias de negócio;
d) Dados de outros usuários, incluindo dados pessoais, processados pelo sistema;
e) Bugs, vulnerabilidades, falhas e problemas de segurança identificados;
f) Qualquer informação técnica, comercial, financeira ou de PI não disponível publicamente.
'''),
                        _buildSection(theme, '3. OBRIGAÇÕES DO USUÁRIO', '''
O USUÁRIO compromete-se, em caráter irrevogável, a:

a) NÃO divulgar, compartilhar, reproduzir ou tornar públicas as Informações Confidenciais por qualquer meio;
b) NÃO realizar capturas de tela, gravações (áudio/vídeo) ou cópias para compartilhamento ou uso próprio;
c) NÃO discutir funcionalidades, performance ou problemas do aplicativo em redes sociais, fóruns públicos ou mídias de imprensa;
d) **NÃO compartilhar as credenciais de acesso** nem permitir acesso de terceiros à sua conta ou ao aplicativo;
e) NÃO realizar engenharia reversa, desmontagem, descompilação ou qualquer tentativa de obter o código-fonte ou a lógica de negócio subjacente;
f) Reportar bugs e problemas exclusivamente ao Desenvolvedor, pelos canais oficiais;
g) Utilizar o sistema apenas para fins de teste e avaliação autorizados.
'''),
                        _buildSection(theme, '4. DURAÇÃO', '''
Este Acordo entra em vigor na data do aceite. A obrigação de confidencialidade do USUÁRIO permanecerá válida por um período de **5 (cinco) anos** a contar desta data, mesmo após o encerramento do período de testes ou exclusão da conta.
'''),
                        _buildSection(theme, '5. PENALIDADES', '''
A violação de qualquer cláusula deste Acordo constitui quebra contratual grave e poderá resultar em:

a) Rescisão imediata e permanente do acesso do USUÁRIO ao sistema, sem aviso prévio;
b) **Cláusula Penal (Multa Contratual)**: Pagamento de uma indenização mínima e **não compensatória** de **R\$ 10.000,00 (dez mil reais)**, a ser paga no prazo de 15 dias após a notificação da violação;
c) Esta multa será aplicada sem prejuízo da responsabilidade civil do USUÁRIO por **Perdas e Danos** apurados em valor superior, e das medidas judiciais cabíveis para cessar a violação (Ação de Obrigação de Não Fazer).

O USUÁRIO reconhece que a divulgação não autorizada das ICs causará danos financeiros e à reputação do Desenvolvedor, sendo a multa uma estimativa prévia de parte desses prejuízos.
'''),
                        _buildSection(theme, '6. VERSÃO ALFA', '''
O USUÁRIO está ciente de que:

a) Esta é uma versão ALFA em desenvolvimento ativo e restrito;
b) O sistema pode conter bugs, erros, instabilidades e vulnerabilidades;
c) Funcionalidades, design e dados podem ser alterados ou removidos sem aviso;
d) Não há garantias de disponibilidade ou performance;
e) O acesso e uso são por conta e risco exclusivo do USUÁRIO para fins de teste.
'''),
                        _buildSection(theme, '7. JURISDIÇÃO', '''
Este Acordo é regido e interpretado de acordo com as leis da República Federativa do Brasil. As partes elegem o **Foro da Comarca de Olinda/PE** como o único competente para dirimir quaisquer dúvidas ou conflitos decorrentes deste Acordo, renunciando a qualquer outro, por mais privilegiado que seja.
'''),
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.amber[700],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ao clicar em "Aceito os Termos", você declara ter lido, compreendido e concordado integralmente com este Acordo.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.amber[800],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Scroll indicator
            if (!_hasScrolledToEnd)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Role até o final para aceitar',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Checkbox
                  CheckboxListTile(
                    value: _hasAccepted,
                    onChanged: _hasScrolledToEnd
                        ? (value) => setState(() => _hasAccepted = value!)
                        : null,
                    title: Text(
                      'Li e compreendi todos os termos acima',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _hasScrolledToEnd
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onDecline,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(color: theme.colorScheme.error),
                          ),
                          child: const Text('Recusar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _hasScrolledToEnd && _hasAccepted
                              ? widget.onAccept
                              : null,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Aceito os Termos'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
          Text(
            content.trim(),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
