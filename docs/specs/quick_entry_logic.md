# Especificação Lógica: Módulo de Entrada Rápida e Conversão

Este documento detalha a arquitetura de dados e fluxos de automação para o recurso de "Entrada Rápida" (Staff) e "Conversão de Cliente" (WebApp), desenhado para ser implementado via Antigravity/Firebase.

## 1. Estrutura de Dados Firestore

Para suportar o fluxo híbrido (Lead -> Usuário), utilizaremos duas coleções principais conforme solicitado, com referências cruzadas.

### A. Coleção `leads_clients`
Armazena potenciais clientes identificados pela placa. É o "CRM leve" antes do cadastro completo.

*   **Document ID**: `[PLACA_DO_VEICULO]` (Ex: `ABC1D23` - sanitizado, uppercase)
*   **Campos**:
    *   `plate` (string): Placa do veículo (Chave de busca).
    *   `phoneNumber` (string): WhatsApp formatado (E.164, ex: `+5581999999999`).
    *   `vehicleModel` (string): Modelo (Ex: "Fiat Toro").
    *   `status` (enum):
        *   `lead_nao_cadastrado`: Apenas telefone/placa.
        *   `converted`: Já criou conta (possui `uid`).
    *   `uid` (string, nullable): ID do Firebase Auth (preenchido após conversão).
    *   `fcmToken` (string, nullable): Token para Push Notifications.
    *   `createdAt` (timestamp).
    *   `lastServiceAt` (timestamp).

### B. Coleção `servicos_ativos`
Representa a execução do serviço atual. Desacoplado da collection `bookings` tradicional para permitir input sem `uid`, mas estruturado para migração futura.

*   **Document ID**: Auto-generated (será o `{docID}` do link).
*   **Campos**:
    *   `plate` (string): FK para `leads_clients`.
    *   `status` (enum): `fila`, `lavando`, `pronto`, `entregue`.
    *   `startedAt` (timestamp).
    *   `finishedAt` (timestamp, nullable).
    *   `staffId` (string): ID do funcionário que deu entrada.
    *   `serviceType` (string): Ex: "Lavagem Simples" (pode ser select no futuro, default inicial).
    *   `photos` (array of strings): URLs das fotos do "Antes/Depois".
    *   `clientLink` (string): URL gerada (ex: `app.lavagem.com/check-in?id={DOC_ID}`).

---

## 2. Esquema do Formulário Rápido (Staff)

Interface minimalista para agilidade operacional.

**Campos:**
1.  **Placa do Veículo**
    *   *Tipo*: Input Texto (Máscara de Placa Mercosul/Antiga).
    *   *Validação*: Obrigatório, Regex Placa.
    *   *Ação (OnBlur)*: Buscar na coleção `leads_clients`. Se existir, auto-preencher Modelo e WhatsApp.
2.  **Modelo do Carro**
    *   *Tipo*: Input Texto (ou Dropdown com autocomplete se houver base).
    *   *Validação*: Obrigatório.
3.  **WhatsApp do Cliente**
    *   *Tipo*: Input Tel (Máscara Celular BR).
    *   *Validação*: Obrigatório.

**Botão de Ação:** "Iniciar Serviço"

**Lógica de Submissão (Backend/Function):**
1.  Verificar se `leads_clients/[PLACA]` existe.
    *   *Não*: Criar doc com `status: lead_nao_cadastrado`.
    *   *Sim*: Atualizar `lastServiceAt`.
2.  Criar documento em `servicos_ativos`.
3.  Gerar Link Único: `https://app.lavagem.com/check-in?id=[SERVICO_ID]`.
4.  Disparar mensagem inicial WhatsApp (via API/Link): *"Olá! Seu [MODELO] deu entrada na Lavagem. Acompanhe aqui: [LINK]"*.

---

## 3. Fluxo de Conversão (Cliente)

Ocorre quando o cliente acessa o WebApp pelo link e decide se cadastrar.

**Cenário:** Cliente acessa `app.lavagem.com/check-in?id=XYZ`.
**Tela:** Mostra status atual ("LAVANDO") e fotos.

**Gatilho de Conversão:**
*   Botão: "Receber aviso quando ficar pronto" ou "Ver fotos em alta resolução".
*   Popup/Modal: "Crie sua senha para acessar histórico e descontos".

**Ação de Cadastro:**
1.  Cliente insere **E-mail** e **Senha**.
2.  **Firebase Auth**: Cria usuário (`UserCredential`).
3.  **Vínculo (Backend Antigravity):**
    *   Recupera o `serviceId` da URL.
    *   Lê a `plate` do `servicos_ativos`.
    *   Atualiza `leads_clients/[PLACA]`:
        *   Define `uid` = Novo Auth UID.
        *   Define `status` = `converted`.
        *   Salva `email`.
        *   (Opcional) Cria doc na collection principal `users` para compatibilidade total.
4.  **Upgrade**: Exibir modal de oferta "Assinatura" imediatamente após o sucesso.

---

## 4. Fluxo de Notificação Inteligente (Webhook de Status)

Monitora mudanças no campo `status` da coleção `servicos_ativos`.

**Gatilho:** Staff altera status de `lavando` para `pronto`.

**Árvore de Decisão:**
1.  Buscar documento do cliente em `leads_clients` usando a `plate` do serviço.
2.  Verificar campo `status` (ou `uid`):
    *   **CASO A: Cliente Convertido (`status == converted` E `fcmToken != null`)**
        *   *Ação*: Disparar **FCM Push Notification**.
        *   *Mensagem*: "Seu [MODELO] está pronto! ✨ Toque para ver as fotos."
        *   *Destino*: Abre o App/WebApp logado.
    *   **CASO B: Lead Não Cadastrado (`status == lead_nao_cadastrado`)**
        *   *Ação*: Disparar **Mensagem WhatsApp** (Integração API ou Link WA).
        *   *Mensagem*: "Seu carro está quase pronto! 🚗 Cadastre-se agora para ver as fotos e liberar seu desconto: [LINK_DO_SERVICO]"
