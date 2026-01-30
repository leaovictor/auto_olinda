# 🚗 Auto Olinda
**A Revolução Digital para Estéticas Automotivas de Alto Padrão.**

> *Mais que um app de lavagem. Uma plataforma completa de recorrência, fidelização e gestão inteligente.*

---

## 💼 Por Que Este App é um Game-Changer? (O Pitch)

O mercado de estética automotiva evoluiu. Clientes premium exigem conveniência, transparência e exclusividade. O **Auto Olinda** foi desenvolvido para transformar lavajatos tradicionais em **negócios de assinatura escaláveis**.

### 🚀 1. Receita Recorrente (MRR)
Abandone a incerteza do "dia de chuva".
Com o modelo de **Clubes de Assinatura** (ex: *Plano Hatch Premium*), você garante faturamento mensal fixo debitado automaticamente no cartão do cliente. É o modelo "Netflix" aplicado ao seu negócio.

### 💎 2. Experiência "Uau"
Seu cliente merece um app à altura do carro dele.
- **Design Premium**: Interface moderna, fluida e intuitiva.
- **Transparência Total**: O cliente acompanha o carro na fila, na lavagem e na secagem em tempo real pelo app.
- **Garagem Virtual**: Gestão simples de múltiplos veículos (o carro da esposa, o do filho, o de lazer).

### 🤖 3. Automação Inteligente
Menos ZAP, mais produtividade.
- **Agenda Blindada**: O sistema impede conflitos de horário e respeita o tempo de cada serviço (lavagem simples vs polimento).
- **Adeus Calote**: Travas automáticas para inadimplentes e controle rigoroso de *No-Show*.
- **PDFs Automáticos**: Comprovantes detalhados e profissionais gerados em um clique.

---

## 📱 Funcionalidades Principais

### Para Seu Cliente (O App)
* **Dashboard Vip**: Visão clara das próximas lavagens e status da assinatura.
* **Agendamento em 3 Cliques**: Escolha o carro, o serviço e o horário. Simples.
* **Smart Map**: Integração direta com Waze/Maps para chegar ao estabelecimento.
* **Notificações Push**: "Seu carro está pronto!" (Fidelização garantida).
* **Histórico Financeiro**: Transparência total de gastos e serviços realizados.

### Para Sua Gestão (O Painel Admin)
* **Controle de Assinaturas**: Crie planos (Ex: 4 lavagens/mês), defina preços e regras de renovação.
* **Gestão de Serviços Avulsos**: Venda serviços extras (Polimento, Higienização) com preços dinâmicos.
* **Raio-X do Negócio**: Métricas de ocupação, faturamento e novos clientes.
* **Controle de Staff**: Saiba exatamente quem lavou qual carro.

---

## 🛠️ Por Baixo do Capô (Tech Stack)

Construído com o que há de mais moderno no mercado de desenvolvimento de software, garantindo performance, escalabilidade e manutenibilidade.

| Tecnologia | Função | Benefício |
|------------|--------|-----------|
| **Flutter 3.x** | Frontend Mobile & Web | App nativo para iOS/Android e Painel Web com um único código. |
| **Firebase** | Backend Serverless | Escalabilidade infinita. Zero custo com servidores ociosos. |
| **Riverpod 2.0** | Gerência de Estado | Código limpo, testável e livre de bugs de estado. |
| **Cloud Functions** | Regras de Negócio | Segurança total. As regras rodam no servidor, não no celular do cliente. |
| **Stripe** | Pagamentos | O gateway de pagamento mais robusto do mundo para assinaturas. |
| **Pdf & Printing** | Geração de Docs | Criação de documentos profissionais direto no device. |

---

## 📦 Guia de Instalação (Para Desenvolvedores)

Se você adquiriu o código-fonte, siga os passos abaixo para colocar sua operação no ar.

### Pré-requisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado.
- Conta no [Firebase](https://console.firebase.google.com/).
- Conta no [Stripe](https://stripe.com/).

### 1. Configuração Inicial
```bash
# Clone o repositório
git clone https://github.com/seu-usuario/auto_olinda.git
cd auto_olinda

# Instale as dependências
flutter pub get
```

### 2. Conectando ao Firebase
1. Instale o CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Configure o projeto:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
4. Faça o deploy das regras de segurança e funções:
```bash
firebase deploy --only firestore:rules,functions
```

### 3. Rodando o Projeto
```bash
# Para Mobile
flutter run

# Para Painel Web
flutter run -d chrome
```

### 4. Deploy para Lojas
```bash
# Android
flutter build appbundle

# iOS (Requer macOS)
flutter build ipa
```

---

## 🤝 Suporte e Customização

Precisa adaptar o app para sua marca?
Entre em contato para serviços de *White Label*, customização de cores, logo e regras de negócio específicas.

---
*Auto Olinda © 2024 - Transformando Estética Automotiva em Tecnologia.*
