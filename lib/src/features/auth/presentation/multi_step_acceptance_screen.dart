import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'privacy_policy_screen.dart';
import '../domain/nda_content.dart';

/// Fluxo de aceite em múltiplas etapas para NDA e Termos de Uso/Política de Privacidade.
///
/// Etapa 1: Acordo de Confidencialidade (NDA)
/// Etapa 2: Termos de Uso e Política de Privacidade
class MultiStepAcceptanceScreen extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final DateTime acceptanceDate;

  const MultiStepAcceptanceScreen({
    super.key,
    required this.onAccept,
    required this.onDecline,
    required this.acceptanceDate,
  });

  @override
  State<MultiStepAcceptanceScreen> createState() =>
      _MultiStepAcceptanceScreenState();
}

class _MultiStepAcceptanceScreenState extends State<MultiStepAcceptanceScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Etapa 1: NDA
  final ScrollController _ndaScrollController = ScrollController();
  bool _ndaScrolledToEnd = false;
  bool _ndaAccepted = false;

  // Etapa 2: ToU/PP
  final ScrollController _touScrollController = ScrollController();
  bool _touScrolledToEnd = false;
  bool _touAccepted = false;

  @override
  void initState() {
    super.initState();
    _ndaScrollController.addListener(_checkNdaScroll);
    _touScrollController.addListener(_checkTouScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ndaScrollController.dispose();
    _touScrollController.dispose();
    super.dispose();
  }

  void _checkNdaScroll() {
    if (_ndaScrollController.position.pixels >=
        _ndaScrollController.position.maxScrollExtent - 50) {
      if (!_ndaScrolledToEnd) {
        setState(() => _ndaScrolledToEnd = true);
      }
    }
  }

  void _checkTouScroll() {
    if (_touScrollController.position.pixels >=
        _touScrollController.position.maxScrollExtent - 50) {
      if (!_touScrolledToEnd) {
        setState(() => _touScrolledToEnd = true);
      }
    }
  }

  void _goToNextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = 1);
  }

  void _goToPreviousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = 0);
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Header com indicador de etapas
          _buildHeader(theme),

          // Conteúdo das etapas
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildNdaStep(theme), _buildTouStep(theme)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _currentStep == 0
                        ? Icons.security_rounded
                        : Icons.description_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      _currentStep == 0
                          ? 'Acordo de Confidencialidade'
                          : 'Termos de Uso',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 16),
              // Indicador de progresso
              _buildStepIndicator(theme),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot(theme, 0, 'NDA'),
        Container(
          width: 60,
          height: 2,
          color: _currentStep >= 1
              ? Colors.white
              : Colors.white.withOpacity(0.3),
        ),
        _buildStepDot(theme, 1, 'Termos'),
      ],
    );
  }

  Widget _buildStepDot(ThemeData theme, int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrentStep = _currentStep == step;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrentStep ? 32 : 24,
          height: isCurrentStep ? 32 : 24,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: isActive && step < _currentStep
                ? Icon(Icons.check, size: 16, color: theme.colorScheme.primary)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive
                          ? theme.colorScheme.primary
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  // ==================== ETAPA 1: NDA ====================
  Widget _buildNdaStep(ThemeData theme) {
    return Column(
      children: [
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
              controller: _ndaScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _ndaScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildNdaContent(theme),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Indicador de scroll
        if (!_ndaScrolledToEnd) _buildScrollIndicator(theme),

        // Ações
        _buildNdaActions(theme),
      ],
    );
  }

  List<Widget> _buildNdaContent(ThemeData theme) {
    final sections = NdaContent.getSections(widget.acceptanceDate.year);

    return [
      _buildSection(
        theme,
        'TERMOS DE CONFIDENCIALIDADE (NDA)',
        NdaContent.getHeader(widget.acceptanceDate),
      ),
      ...sections.map(
        (section) => _buildSection(theme, section.title, section.content),
      ),
      _buildWarningBox(
        theme,
        'Ao clicar em "Continuar", você declara ter lido, compreendido e concordado integralmente com este Acordo de Confidencialidade.',
      ),
    ];
  }

  Widget _buildNdaActions(ThemeData theme) {
    return Container(
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
          CheckboxListTile(
            value: _ndaAccepted,
            onChanged: _ndaScrolledToEnd
                ? (value) => setState(() => _ndaAccepted = value!)
                : null,
            title: Text(
              'Li e compreendi o Acordo de Confidencialidade',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _ndaScrolledToEnd
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
                  onPressed: _ndaScrolledToEnd && _ndaAccepted
                      ? _goToNextStep
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Continuar'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== ETAPA 2: ToU/PP ====================
  Widget _buildTouStep(ThemeData theme) {
    return Column(
      children: [
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
              controller: _touScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _touScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildTouContent(theme),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Indicador de scroll
        if (!_touScrolledToEnd) _buildScrollIndicator(theme),

        // Ações
        _buildTouActions(theme),
      ],
    );
  }

  List<Widget> _buildTouContent(ThemeData theme) {
    final currentYear = DateTime.now().year;

    return [
      _buildSection(theme, 'TERMOS DE USO DO APLICATIVO', '''
Estes Termos de Uso ("Termos") regem o uso do aplicativo "Auto Olinda - Sistema de Gestão de Lava-Jato" ("Aplicativo").

Ao utilizar este Aplicativo, você concorda com estes Termos.

Data: ${DateTime.now().day}/${DateTime.now().month}/$currentYear
'''),
      _buildSection(theme, '1. OBJETO', '''
O Aplicativo oferece uma plataforma digital para agendamento e gestão de serviços de lavagem automotiva, conectando usuários a prestadores de serviços parceiros.
'''),
      _buildSection(
        theme,
        '2. EXCLUSÃO DE RESPONSABILIDADE POR SERVIÇOS FÍSICOS',
        '''
**CLÁUSULA CRÍTICA - LEIA COM ATENÇÃO**

O USUÁRIO declara estar ciente e de acordo que:

a) O Aplicativo atua **exclusivamente como intermediário tecnológico**, facilitando a conexão entre usuários e prestadores de serviços de lavagem automotiva;

b) **O DESENVOLVEDOR NÃO É RESPONSÁVEL** pela qualidade, execução, prazo ou resultado dos serviços físicos de lavagem prestados por terceiros;

c) Quaisquer danos, perdas, avarias ou problemas decorrentes da execução do serviço físico de lavagem são de **responsabilidade exclusiva do prestador de serviço** contratado;

d) O Aplicativo não possui controle sobre as instalações, equipamentos, produtos ou métodos utilizados pelos prestadores de serviços parceiros;

e) Reclamações sobre a qualidade do serviço físico devem ser direcionadas **diretamente ao prestador de serviço**, cabendo ao Desenvolvedor apenas facilitar o contato entre as partes, quando possível;

f) O USUÁRIO assume integralmente os riscos inerentes à contratação de serviços de terceiros por meio do Aplicativo.
''',
      ),
      _buildSection(theme, '3. CADASTRO E CONTA', '''
a) O cadastro é pessoal e intransferível;
b) O USUÁRIO é responsável pela veracidade das informações fornecidas;
c) O USUÁRIO é responsável por manter suas credenciais em sigilo;
d) O uso indevido da conta é de responsabilidade exclusiva do USUÁRIO.
'''),
      _buildSection(theme, '4. PAGAMENTOS', '''
a) Os valores dos serviços são definidos pelos prestadores parceiros;
b) O Aplicativo processa pagamentos com segurança através de parceiros homologados;
c) Políticas de cancelamento e reembolso seguem as regras de cada prestador.
'''),
      _buildSection(theme, '5. PROPRIEDADE INTELECTUAL', '''
Todo o conteúdo do Aplicativo (código, design, marca, textos) é de propriedade exclusiva do Desenvolvedor, protegido pelas leis de propriedade intelectual vigentes.
'''),
      _buildSection(theme, '6. ALTERAÇÕES', '''
O Desenvolvedor reserva-se o direito de modificar estes Termos a qualquer momento, notificando os usuários através do Aplicativo.
'''),
      _buildSection(theme, '7. FORO', '''
Fica eleito o **Foro da Comarca de Olinda/PE** para dirimir quaisquer controvérsias decorrentes destes Termos.
'''),
      const SizedBox(height: 16),
      // Link para Política de Privacidade
      InkWell(
        onTap: _openPrivacyPolicy,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Leia a Política de Privacidade',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _buildWarningBox(
        theme,
        'Ao clicar em "Finalizar Cadastro", você declara ter lido, compreendido e concordado com os Termos de Uso e a Política de Privacidade.',
      ),
    ];
  }

  Widget _buildTouActions(ThemeData theme) {
    return Container(
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
          CheckboxListTile(
            value: _touAccepted,
            onChanged: _touScrolledToEnd
                ? (value) => setState(() => _touAccepted = value!)
                : null,
            title: Text(
              'Li e concordo com os Termos de Uso e Política de Privacidade',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _touScrolledToEnd
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
                  onPressed: _goToPreviousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 18),
                      const SizedBox(width: 8),
                      const Text('Voltar'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _touScrolledToEnd && _touAccepted
                      ? widget.onAccept
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 18),
                      const SizedBox(width: 8),
                      const Text('Finalizar Cadastro'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== WIDGETS AUXILIARES ====================
  Widget _buildScrollIndicator(ThemeData theme) {
    return Container(
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
    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn();
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

  Widget _buildWarningBox(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber[800],
                fontWeight: FontWeight.w500,
              ),
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
      // Adiciona texto antes do match
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      // Adiciona texto em negrito (sem os asteriscos)
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

    // Adiciona texto restante após o último match
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans.isEmpty ? [TextSpan(text: text)] : spans;
  }
}
