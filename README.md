# Auto Olinda SaaS - Manual Técnico

Este documento contém as instruções técnicas para configuração, desenvolvimento e deploy da plataforma SaaS Auto Olinda.

## 🛠 Tech Stack

- **Frontend**: Flutter (Mobile & Web)
- **Backend / Serverless**: Firebase (Auth, Firestore, Functions, Storage)
- **Pagamentos**: Stripe
- **Gerenciamento de Estado**: Riverpod
- **Navegação**: GoRouter

---

## 1. Configuração do Firebase

O projeto depende fortemente do ecosistema Firebase. Siga os passos abaixo para configurar um novo ambiente:

### 1.1 Criação do Projeto
1. Acesse o [Console do Firebase](https://console.firebase.google.com/).
2. Crie um novo projeto (ex: `auto-olinda-prod`).
3. Instale o FlutterFire CLI se ainda não tiver:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Na raiz do projeto, configure o app:
   ```bash
   flutterfire configure --project=seu-projeto-id
   ```
   *Isso atualizará o arquivo `lib/firebase_options.dart`.*

### 1.2 Habilitar Serviços
No console do Firebase, ative os seguintes serviços:
- **Authentication**: Habilite "Email/Password".
- **Firestore Database**: Crie o banco em modo de produção.
- **Storage**: Para upload de fotos de veículos/perfil.
- **Functions**: Necessário plano Blaze (Pay-as-you-go) para deploy de funções Node.js.

### 1.3 Regras de Segurança
O arquivo `firestore.rules` na raiz do projeto contém as regras de segurança multitenancy.
```bash
firebase deploy --only firestore:rules
```

### 1.4 Cloud Functions (Backend)
As funções ficam na pasta `functions`. Elas gerenciam os webhooks do Stripe e triggers do banco.
1. Navegue até a pasta: `cd functions`
2. Instale dependências: `npm install`
3. Configure as variáveis de ambiente do Firebase (ver seção Stripe).
4. Deploy:
   ```bash
   firebase deploy --only functions
   ```

---

## 2. Configuração do Stripe

A integração de pagamentos e assinaturas é feita via Stripe.

### 2.1 API Keys
Obtenha suas chaves no [Dashboard do Stripe](https://dashboard.stripe.com/apikeys).
- **Publishable Key**: Usada no App Flutter.
- **Secret Key**: Usada nas Cloud Functions.

### 2.2 Configurar Webhooks
Webhooks são vitais para confirmar pagamentos e renovações.
1. No Dashboard do Stripe, vá em **Developers > Webhooks**.
2. Adicione um endpoint apontando para sua Cloud Function:
   `https://us-central1-seu-projeto.cloudfunctions.net/handleStripeWebhook`
3. Selecione os eventos:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.paid`
   - `invoice.payment_failed`

### 2.3 Variáveis no Firebase Functions
Configure as chaves do Stripe no ambiente das Cloud Functions:

```bash
firebase functions:config:set stripe.secret="sk_live_..." stripe.webhook_secret="whsec_..."
```
*Após configurar, faça o deploy das funções novamente.*

---

## 3. Variáveis de Ambiente & Build

O projeto utiliza configurações baseadas em arquivos para separar ambientes (Dev vs Prod).

### 3.1 Chaves do Stripe no App
As chaves públicas do Stripe devem ser configuradas no painel Admin do SaaS (armazenadas no Firestore em `config/stripe`) ou via `dart-define` se preferir hardcoded para builds específicos (não recomendado para SaaS White-label).

### 3.2 Comandos de Build

#### Rodar Localmente
```bash
flutter run
```

#### Build Android (App Bundle)
Para publicar na Play Store:
```bash
flutter build appbundle --release
```

#### Build iOS (IPA)
Requer macOS e Xcode configurado:
```bash
flutter build ipa --release
```

#### Build Web (Painel Admin/Cliente)
```bash
flutter build web --release --renderer kanvaskit
```

---

## 4. Estrutura de Pastas Importante

- `lib/features/`: Funcionalidades divididas por domínio (auth, billing, booking, etc).
- `lib/core/`: Componentes base, tema e utilitários.
- `functions/`: Código Backend (Node.js/TypeScript).
- `firestore.rules`: Regras de segurança do banco.
