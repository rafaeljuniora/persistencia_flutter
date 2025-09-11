# Estrutura do Projeto
## Componentes Principais
### **1. Camada de Dados**
- **database_helper.dart:** Manipula todas as operações do banco de dados SQLite
    - Inicialização e gerenciamento do banco de dado
    - Operações CRUD (Criar, Ler, Atualizar, Excluir)
    - Padrão singleton para acesso ao banco de dados

### **2. Camada de Modelo**
- **pessoa.dart:** Modelo de dados representando uma Pessoa
    - Propriedades: id, nome, idade
    - Métodos toMap() e fromMap() para serialização do banco de dados

### **3. Camada de UI**
- **pessoas_app.dart:** Wrapper principal da aplicação
- **pessoas_page.dart:** Tela principal que coordena formulário e lista
- **pessoa_form.dart:** Componente de formulário para adicionar/editar pessoas
- **pessoa_list.dart:** Componente de lista para exibir pessoas

### **4. Integração com Plataforma**
- **main.dart:** Ponto de entrada com inicialização do banco de dados específica por plataforma

## Padrões de Arquitetura
### **1. Padrão Repository**
O DatabaseHelper atua como um repositório, abstraindo as operações do banco de dados da camada de UI.

### **2. Padrão Singleton**
DatabaseHelper usa um padrão singleton para garantir que apenas uma instância do banco de dados exista.

### **3. Influência do MVVM (Model-View-ViewModel)**
- **Model:** Classe Pessoa
- **View:** Componentes de UI (PessoaForm, PessoaList)
- **Model:** Gerenciamento de estado do PessoasPage

### **4. Separação de Responsabilidades**
- Lógica de persistência de dados isolada no DatabaseHelper
- Componentes de UI focados na apresentação e interação do usuário
- Lógica de negócio tratada no gerenciamento de estado da página

## Fluxo de Dados
1. **Inicialização:** Banco de dados é inicializado em main.dart com configuração específica da plataforma

2. **Leitura:** PessoasPage solicita dados -> DatabaseHelper consulta banco de dados -> retorna Future<List<Pessoa>>

3. **Criação:** PessoaForm envia dados -> DatabaseHelper insere -> PessoasPage atualiza lista

4. **Atualização:** Usuário seleciona item -> PessoaForm carrega dados -> DatabaseHelper atualiza -> Atualiza lista

5. **Exclusão:** Usuário desliza para excluir -> DatabaseHelper exclui -> Atualiza lista

## Funcionalidades Principais
### **Suporte Multiplataforma para Banco de Dados**
- Web: Usa sqflite_ffi_web
- Desktop (Windows/Linux/Mac): Usa sqflite_ffi
- Mobile: Usa sqflite padrão

### **Gerenciamento de Estado**
- Usa gerenciamento de estado built-in do Flutter (setState)
- FutureBuilder para carregamento assíncrono de dados
- GlobalKey para validação de formulários

### **Experiência do Usuário**
- Validação de formulário com mensagens personalizadas
- Estados de carregamento e indicadores de progresso
- Operações de exclusão com confirmação
- Notificações SnackBar para feedback do usuário

### **Dependências**
- sqflite: Operações de banco de dados SQLite
- sqflite_common_ffi: Suporte para plataforma desktop
- sqflite_common_ffi_web : Suporte para plataforma web
- flutter/material: Componentes de UI

### **Considerações de Escalabilidade**
- DatabaseHelper pode ser extendido com consultas adicionais
- Modelo Pessoa pode ser expandido com novos campos
- Componentes de UI são modulares e reutilizáveis
- Abstração de plataforma permite fácil adição de novas plataformas

### **Estratégia de Testes**
- DatabaseHelper pode ser mockado para testes unitários
- Componentes de UI podem ser testados com dados mockados
- Lógica de validação de formulários é testável
- Código específico de plataforma é isolado para facilitar testes