 Gemini
New chat
Search chats
Images
Library
New notebook
Geração de README.md em Português
Erro MinIO: Caracteres Inválidos no Objeto
API Endpoints e Guia de Integração
Script PostgreSQL sem Docker
Alternativas Go para API de Autenticação
Jeans Azul e Sapato Social Preto
Gestão de Frota Mototáxi com API
Sistema de Acionamento Mecatrónico Descentralizado
PayPay África: Função Internacional Explicada
Solicitação Bolsa Estudo CNJ Jean Piaget
Catálogo de Serviços de TI
Rendimento de Dividendos com $500
Ciência de Dados, Análises e IA
Quadro Elétrico Industrial: Dispositivos e Funções
Servoconversores Beckhoff na Automação Industrial
Solucionar Erro de Cartucho HP 3525
Concurso MININT: Melhores Opções
Cálculo de Queda de Tensão e Corrente
Perigo de Arco Elétrico e Prevenção
Avaliação de Nova Receita Médica
Instalação Ar-Condicionado 100 Metros
Antigrippine Trieffect: Quando Tomar
O que é nebulização?
Metafísica e Fenômenos Sobrenaturais
SAP para Gerência de Supermercado
Dimensionamento Elétrico Predial de 3 Andares
Identificação de Teclado Francês AZERTY
Desmame Noturno: Firmeza Afetiva vs. Palmadas
Arduino vs. Raspberry Pi: Escolha Certa
Modelos de Placas Gráficas para Portáteis
Polícia Nacional e Intervenção Rápida
Carreira Naval: Automação e Eletromecânica
Softwares Gratuitos para Automação Industrial
Reconhecimento Internacional de Certificados Angolanos
Conversation with Gemini

faça tradução para portugues e gera um arquivo readme.md para baixar

A API estará rodando em http://localhost:8080

Documentação Swagger em http://localhost:8080/swagger/index.html

Todas as requisições para a API exigem o cabeçalho X-App-ID. O ID de aplicação padrão 00000000-0000-0000-0000-000000000001 é criado automaticamente.
Bash

curl -X POST http://localhost:8080/auth/register \\
  -H "X-App-ID: 00000000-0000-0000-0000-000000000001" \\
  -H "Content-Type: application/json" \\
  -d '{"email":"usuario@exemplo.com","password":"Pass123!@#"}'

Para instruções detalhadas de instalação e configuração, consulte Primeiros Passos.
Documentação
Documento	Descrição
Primeiros Passos	Instalação, configuração e primeiros passos
Configuração	Variáveis de ambiente e configuração de OAuth
Endpoints da API	Referência completa dos endpoints e fluxos de autenticação
Multi-Tenancy	Gestão de inquilinos/aplicações e isolamento de dados
Painel Administrativo	Configuração e uso do painel admin integrado
Registro de Atividades	Logs inteligentes, detecção de anomalias e retenção
Migrações do Banco de Dados	Sistema de migração e comandos
Testes	Execução de testes e cobertura de código
Estrutura do Projeto	Organização do código-fonte e arquitetura
Referência do Makefile	Todos os comandos make disponíveis
Arquitetura	Design do sistema e padrões utilizados
Referência da API (detalhada)	Documentação completa de requisições e respostas
Histórico de Alterações	Histórico de versões e notas de lançamento

Para usuários antigos que estão atualizando a partir de versões anteriores à adição do suporte multi-tenancy, consulte a Referência de Migração Pré-Lançamento.
Stack Tecnológica
Categoria	Tecnologia
Linguagem	Go 1.23+
Framework Web	Gin
Banco de Dados	PostgreSQL 13+ com GORM
Cache / Sessões	Redis 6+ com go-redis
Autenticação	JWT (golang-jwt), OAuth2
WebAuthn	go-webauthn
2FA	TOTP (pquerna/otp), SMS (Twilio)
OIDC	Provedor OpenID Connect integrado (RS256, PKCE, JWKS)
GeoIP	MaxMind GeoLite2
Métricas	Prometheus
Doc. da API	Swagger/Swaggo
Painel Admin	Go Templates, HTMX, Bootstrap 5
Conteinerização	Docker, Docker Compose
Contribuição

Contribuições são muito bem-vindas! Por favor, leia CONTRIBUTING.md e CODE_OF_CONDUCT.md antes de abrir um pull request.
Bash

# Fluxo de desenvolvimento
make dev              # Inicia com hot reload
make test             # Executa os testes
make fmt && make lint # Formata e analisa o código
make security         # Verificações de segurança

Segurança

Para relatar vulnerabilidades, não crie issues públicas. Leia SECURITY.md para obter instruções sobre divulgação responsável.
Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo LICENSE para mais detalhes.
"""

file_path = "README.md"
with open(file_path, "w", encoding="utf-8") as f:
f.write(readme_pt)

print(f"File saved successfully as {file_path}")


```text?code_stdout&code_event_index=1
File saved successfully as README.md

O arquivo README.md traduzido para português foi gerado e está pronto para download.
MD icon
README
 MD 
placeholder

Temporary skill placeholder.
Instructions
Placeholder


Gemini is AI and can make mistakes.
Analyzing

<p align="center">
  <img src="banner.png" alt="Auth API - Autenticação e Autorização Pronta para Produção" width="100%" />
</p>

<div align="center">

Um sistema completo de autenticação e autorização com suporte a multi-tenancy (múltiplos inquilinos), login social, WebAuthn/passkeys, login por magic link, controle de acesso baseado em funções (RBAC), autenticação de dois fatores (2FA), gestão de sessões, verificação de e-mail, tokens JWT, painel administrativo (GUI) e registro de atividades (logs).

[![Versão Go](https://img.shields.io/badge/Go-1.23+-00ADD8?style=flat&logo=go)](https://golang.org)
[![Licença](https://img.shields.io/badge/Licen%C3%A7a-MIT-green.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Suportado-2496ED?style=flat&logo=docker)](https://www.docker.com/)
[![Swagger](https://img.shields.io/badge/API-Swagger-85EA2D?style=flat&logo=swagger)](http://localhost:8080/swagger/index.html)

[Início Rápido](#in%C3%ADcio-r%C3%A1pido) · [Documentação](#documenta%C3%A7%C3%A3o) · [Contribuição](#contribui%C3%A7%C3%A3o)

</div>

---

## Funcionalidades

- **Multi-Tenancy** -- Atenda a múltiplas organizações e aplicações a partir de uma única implantação com isolamento completo de dados.
- **Grupos de Sessão** -- Vincule aplicações em grupos nomeados com estado de autenticação compartilhado e logout global configurável (SSO entre aplicações dentro do mesmo inquilino/tenant).
- **Autenticação** -- Cadastro, login, tokens de acesso/atualização JWT, lista negra de tokens, redefinição de senha, verificação de e-mail e reenvio de verificação.
- **WebAuthn/Passkeys** -- Registro de passkeys FIDO2, passkey como método 2FA e login totalmente sem senha por meio de credenciais descobertas (*discoverable credentials*).
- **Login por Magic Link** -- Autenticação sem senha via links mágicos por e-mail, tanto para usuários quanto para contas de administrador.
- **Autenticação de Dois Fatores (2FA)** -- TOTP com aplicativos autenticadores, 2FA via SMS, 2FA via e-mail, 2FA via passkey, e-mail de recuperação de emergência, códigos de recuperação e dispositivos confiáveis.
- **Login Social** -- OAuth2 com Google, Facebook e GitHub, incluindo vinculação e desvinculação de contas.
- **Provedor OIDC** -- Cada aplicação pode atuar como um emissor OpenID Connect em conformidade com os padrões (Código de Autorização + PKCE, tokens ID RS256, JWKS, introspecção e revogação de tokens).
- **Sistema de Webhooks** -- Registre endpoints HTTP para receber notificações de eventos assinadas por HMAC, com rastreamento de entrega e tentativas automáticas.
- **Proteção Contra Força Bruta** -- Bloqueio de conta por aplicação, atrasos progressivos de login e limites de ativação de CAPTCHA.
- **GeoIP e Regras de IP** -- Regras de acesso a IP baseadas em MaxMind GeoLite2 com listas de permissão/bloqueio por CIDR/país por aplicação.
- **Escopos e Uso de Chaves de API** -- Permissões granulares em chaves de API com métricas diárias de uso por chave e notificações de expiração.
- **Saúde e Métricas** -- Verificação de integridade `GET /health` e endpoint Prometheus `GET /metrics` com métricas de requisições e do sistema.
- **Controle de Acesso Baseado em Funções (RBAC)** -- Funções e permissões por aplicação, com gestão administrativa e atribuição automática de função padrão (*self-healing*).
- **Gestão de Sessões** -- Listagem de sessões ativas entre dispositivos, revogação de sessões individuais e encerramento de todas as outras sessões.
- **Painel Administrativo (GUI)** -- Painel web integrado para gerenciar inquilinos (tenants), aplicações, usuários, configurações de OAuth, chaves de API, funções, permissões, sessões, webhooks, clientes OIDC, regras de IP, monitoramento e configurações.
- **Registro de Atividades (Logs)** -- Categorização inteligente de eventos, detecção de anomalias, exportação para CSV e limpeza automática por retenção.
- **Importação/Exportação de Usuários** -- Exportação e importação em massa de contas de usuários em formato CSV pelo painel administrativo.
- **Endurecimento de Segurança (Security Hardening)** -- Limitador de taxa (*rate limiting*), cabeçalhos de segurança, CSRF seguro contra ataques de tempo, imposição de tipos de token JWT e validação de sessão via Redis.
- **Documentação da API** -- Interface interativa do Swagger UI.

---

## Início Rápido

**Pré-requisitos:** Docker & Docker Compose (recomendado), ou Go 1.23+, PostgreSQL 13+, Redis 6+

```bash
# Clonar e configurar
git clone <url-do-repositorio>
cd <diretorio-do-projeto>
cp .env.example .env        # Edite com suas configurações

# Iniciar os serviços
./setup-network.sh create   # Apenas na primeira vez
make docker-dev              # Inicia PostgreSQL, Redis e a API
make migrate-up              # Aplica as migrações do banco de dados
```

A API estará rodando em `http://localhost:8080`  
Documentação Swagger em `http://localhost:8080/swagger/index.html`

Todas as requisições para a API exigem o cabeçalho `X-App-ID`. O ID de aplicação padrão `00000000-0000-0000-0000-000000000001` é criado automaticamente.

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "X-App-ID: 00000000-0000-0000-0000-000000000001" \
  -H "Content-Type: application/json" \
  -d '{"email":"usuario@exemplo.com","password":"Pass123!@#"}'
```

Para instruções detalhadas de instalação e configuração, consulte [Primeiros Passos](docs/getting-started.md).

---

## Documentação

| Documento | Descrição |
|-----------|-----------|
| **[Primeiros Passos](docs/getting-started.md)** | Instalação, configuração e primeiros passos |
| **[Configuração](docs/configuration.md)** | Variáveis de ambiente e configuração de OAuth |
| **[Endpoints da API](docs/api-endpoints.md)** | Referência completa dos endpoints e fluxos de autenticação |
| **[Multi-Tenancy](docs/multi-tenancy.md)** | Gestão de inquilinos/aplicações e isolamento de dados |
| **[Painel Administrativo](docs/admin-gui.md)** | Configuração e uso do painel admin integrado |
| **[Registro de Atividades](docs/activity-logging.md)** | Logs inteligentes, detecção de anomalias e retenção |
| **[Migrações do Banco de Dados](docs/database-migrations.md)** | Sistema de migração e comandos |
| **[Testes](docs/testing.md)** | Execução de testes e cobertura de código |
| **[Estrutura do Projeto](docs/project-structure.md)** | Organização do código-fonte e arquitetura |
| **[Referência do Makefile](docs/makefile-reference.md)** | Todos os comandos `make` disponíveis |
| **[Arquitetura](docs/ARCHITECTURE.md)** | Design do sistema e padrões utilizados |
| **[Referência da API (detalhada)](docs/API.md)** | Documentação completa de requisições e respostas |
| **[Histórico de Alterações](CHANGELOG.md)** | Histórico de versões e notas de lançamento |

Para usuários antigos que estão atualizando a partir de versões anteriores à adição do suporte multi-tenancy, consulte a [Referência de Migração Pré-Lançamento](docs/BREAKING_CHANGES.md).

---

## Stack Tecnológica

| Categoria | Tecnologia |
|-----------|------------|
| Linguagem | Go 1.23+ |
| Framework Web | [Gin](https://github.com/gin-gonic/gin) |
| Banco de Dados | PostgreSQL 13+ com [GORM](https://gorm.io/) |
| Cache / Sessões | Redis 6+ com [go-redis](https://github.com/redis/go-redis) |
| Autenticação | JWT ([golang-jwt](https://github.com/golang-jwt/jwt)), OAuth2 |
| WebAuthn | [go-webauthn](https://github.com/go-webauthn/webauthn) |
| 2FA | TOTP ([pquerna/otp](https://github.com/pquerna/otp)), SMS (Twilio) |
| OIDC | Provedor OpenID Connect integrado (RS256, PKCE, JWKS) |
| GeoIP | MaxMind GeoLite2 |
| Métricas | Prometheus |
| Doc. da API | [Swagger/Swaggo](https://github.com/swaggo/swag) |
| Painel Admin | Go Templates, HTMX, Bootstrap 5 |
| Conteinerização | Docker, Docker Compose |

---

## Contribuição

Contribuições são muito bem-vindas! Por favor, leia [CONTRIBUTING.md](CONTRIBUTING.md) e [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) antes de abrir um pull request.

```bash
# Fluxo de desenvolvimento
make dev              # Inicia com hot reload
make test             # Executa os testes
make fmt && make lint # Formata e analisa o código
make security         # Verificações de segurança
```

---

## Segurança

Para relatar vulnerabilidades, **não crie issues públicas**. Leia [SECURITY.md](SECURITY.md) para obter instruções sobre divulgação responsável.

---

## Licença

Este projeto está licenciado sob a Licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

README.md
Displaying README.md.
