# Auto Olinda - Sistema de Lavagem Automotiva Premium

Bem-vindo ao repositório oficial do **Auto Olinda**, uma plataforma completa de gestão e agendamento para lavagens automotivas. Este sistema foi desenhado para oferecer uma experiência premium aos clientes e controle total aos administradores.

## 🎯 Objetivo do Produto (Atividade Fim)

O **Auto Olinda** tem como objetivo modernizar o serviço de estética automotiva, permitindo que clientes assinem planos mensais de lavagem (modelo Netflix para carros) ou façam agendamentos avulsos. Para o negócio, o sistema automatiza a agenda, controla o fluxo de caixa (integração Stripe) e fideliza clientes através de assinaturas recorrentes.

## 🚀 Principais Funcionalidades

### Para o Cliente (App Mobile/PWA)
- **Assinaturas Recorrentes**: Planos mensais com renovação automática.
- **Limitador Inteligente**: Controle automático de lavagens mensais baseado no plano contratado.
- **Agendamento Fácil**: Visualização de horários disponíveis em tempo real com travas de segurança (ex: antecedência mínima).
- **Acompanhamento em Tempo Real**: Status da lavagem passo-a-passo (Fila, Lavando, Secando, Pronto).
- **Galeria de Fotos**: Registro fotográfico do "Antes e Depois" do serviço.
- **Gestão de Veículos**: Cadastro de múltiplos carros por perfil.

### Para a Administração (Painel Web/Tablet)
- **Gestão de Planos**: Criação dinâmica de planos com limites de lavagem configuráveis (ex: Básico 4x/mês, Premium Ilimitado).
- **Controle de Agenda**: Visão unificada de todos os agendamentos.
- **Financeiro**: Relatórios de receita recorrente (MRR) e pagamentos avulsos.
- **Regras de Negócio**: Travas automáticas para inadimplência, cancelamentos tardios e no-shows.

---

## 🔒 Regras de Negócio & Segurança

O sistema implementa rigorosas regras de negócio validadas no servidor (Cloud Functions) para garantir a integridade da operação:

1.  **Antecedência Mínima**: Agendamentos só podem ser criados com **2 horas** de antecedência para permitir organização da equipe.
2.  **Janela de Cancelamento**: Cancelamentos só são permitidos com até **4 horas** de antecedência.
    - *Tentativas fora da janela instruem o cliente a contatar o suporte.*
3.  **Limite de Plano**: O sistema bloqueia novos agendamentos se o cliente atingir o limite do seu plano mensal (ex: 4 lavagens).
4.  **Política de No-Show**: Clientes que não comparecem tem um contador de "faltas" incrementado automaticamente para ações de penalidade futura.
5.  **Controle de Acesso**:
    - Clientes: Apenas leitura/escrita de seus próprios dados. Criação de agendamentos via função segura.
    - Staff/Admin: Acesso total para gestão operacional.

---

## 🛠️ Stack Tecnológica

O projeto utiliza as melhores práticas de desenvolvimento moderno com Flutter:

-   **Frontend**: Flutter (Mobile Android/iOS & Web PWA).
-   **Gerenciamento de Estado**: Riverpod 2.0 (Generator & Annotations).
-   **Backend (BaaS)**: Firebase (Auth, Firestore, Storage, Cloud Functions).
-   **Pagamentos**: Stripe (Integração nativa e Web).
-   **Navegação**: GoRouter.
-   **Layout**: Responsivo (Mobile & Desktop) com suporte a temas dinâmicos.

---

## 📦 Guia de Instalação e Deploy

Este guia é destinado a desenvolvedores ou compradores do código-fonte.

### Pré-requisitos
-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (Versão 3.x ou superior)
-   Conta no [Firebase](https://firebase.google.com/) (Blaze Plan necessário para Cloud Functions)
-   Conta no [Stripe](https://stripe.com/) (Para processamento de pagamentos)

### 1. Configuração do Projeto
Clone o repositório e instale as dependências:

```bash
git clone https://github.com/seu-usuario/auto_olinda.git
cd auto_olinda
flutter pub get
```

### 2. Configuração do Firebase
1.  Crie um projeto no Firebase Console.
2.  Instale o Firebase CLI: `npm install -g firebase-tools`.
3.  Faça login: `firebase login`.
4.  Ative o **FlutterFire CLI** e configure as plataformas:
    ```bash
    dart pub global activate flutterfire_cli
    flutterfire configure
    ```
5.  Faça o deploy das Regras de Segurança e Cloud Functions:
    ```bash
    firebase deploy --only firestore:rules,functions
    ```

### 3. Configuração do Stripe
1.  Obtenha suas chaves de API (Publishable e Secret) no Dashboard do Stripe.
2.  Adicione a chave pública no arquivo `.env` ou nas configurações do app.
3.  Configure os Webhooks do Stripe para apontar para sua Cloud Function de pagamento.

### 4. Executando o App
Para rodar em modo de desenvolvimento:

```bash
# Mobile
flutter run

# Web (PWA)
flutter run -d chrome
```

### 5. Deploy para Produção (Lojas)
Gere os binários otimizados:

```bash
# Android (App Bundle)
flutter build appbundle

# iOS (IPA - Requer macOS)
flutter build ipa
```

---

## 🤝 Suporte

Para dúvidas técnicas, bugs ou sugestões de novas features, entre em contato com a equipe de desenvolvimento através das Issues deste repositório ou pelo email de suporte dedicado.

---
*Desenvolvido com ❤️ pela equipe Auto Olinda.*
