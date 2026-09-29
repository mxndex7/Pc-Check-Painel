# PC Check Painel

Painel de diagnóstico, reparo e utilitários para Windows em **um único arquivo `.bat`**.
Sem instalação, sem dependências e sem páginas HTML: tudo roda e aparece na própria janela do console.

Feito para técnicos de suporte, mas simples o bastante para o usuário final abrir e usar.

```
  ■ PC CHECK PAINEL  v1.0

  Computador  DESKTOP-EXEMPLO      Usuário  TI
  Permissão   ■ ADMINISTRADOR
  ──────────────────────────────────────────────────────────────────
  ► MENU PRINCIPAL

   [1]  Diagnóstico                 saúde, segurança, identificação
   [2]  Reparos                     Windows, rede, update, impressão
   [3]  Utilitários                 rede, processos, programas, hash
   [4]  Ferramentas do Windows      atalhos para consoles e painéis

   [5]  Reabrir como administrador
   [0]  Sair
```

## Destaques

- **Um arquivo só.** Copie o `.bat` para o computador e execute. O módulo PowerShell vai embutido no fim do arquivo.
- **Resultados na janela.** Listagens longas são paginadas (ENTER continua, Q para). No fim de cada relatório
  você pode copiar o resultado (**C**) ou salvar em `.txt` (**S**).
- **Resumo de alertas.** Os relatórios de saúde e segurança terminam com a contagem de itens
  *Críticos* e de *Atenção*.
- **Seguro por padrão.** Diagnósticos e utilitários só leem informações. Todo reparo exige administrador
  e pede confirmação antes de mexer no sistema.
- **Funciona com usuário padrão.** Sem privilégio de administrador, os itens que dependem dele aparecem
  marcados como "requer administrador", e o painel oferece reabrir com elevação quando necessário.

## Requisitos

- Windows 10 ou 11 (também funciona em Windows Server 2016 ou superior).
- Windows PowerShell 5.1, que já vem com o Windows.
- Para as cores: Windows Terminal, ou Windows 10 versão 2004 (build 19041) ou superior.
  Em consoles antigos o painel funciona sem cores.

Windows 7 e 8 não são suportados, porque vários comandos usados (`Get-NetTCPConnection`, `Get-PhysicalDisk`,
`Get-LocalUser` e outros) não existem nessas versões.

## Como usar

1. Baixe o arquivo [`PC_Check_Painel.bat`](PC_Check_Painel.bat) e salve em uma pasta **local** (por exemplo, a Área de Trabalho).
2. Se o Windows marcou o arquivo como baixado da internet: clique com o botão direito, **Propriedades** e marque **Desbloquear**.
3. Dê dois cliques. Para os reparos e para os itens de segurança mais completos, use **Executar como administrador**
   ou a opção **[5] Reabrir como administrador** do menu.

## O que cada menu faz

### 1. Diagnóstico

| Opção | O que mostra |
|---|---|
| Saúde do PC | Sistema e tempo ligado, RAM, reinício pendente, discos e espaço livre, saúde dos discos físicos, rede em camadas (gateway, internet, DNS), bateria, últimas atualizações e eventos críticos das últimas 24 h |
| Segurança | Antivírus e Defender, firewall, UAC, RDP e NLA, SMBv1, BitLocker, Secure Boot, TPM, logon automático, contas locais, grupo Administradores, compartilhamentos, portas TCP em escuta com o processo dono, conexões com endereços públicos, itens de inicialização, tarefas agendadas fora do padrão Microsoft, falhas de logon e criação de contas |
| Completo | Saúde + segurança em um único relatório |
| Identificação do PC | Nome, usuário, domínio, modelo, número de série, Windows, IP e MAC: os dados para abrir um chamado |

Itens de segurança que dependem de administrador (SMBv1, BitLocker, Secure Boot, TPM, permissões dos
compartilhamentos e log de Segurança) aparecem como "requer administrador" quando o painel roda como usuário padrão.

### 2. Reparos

Todos exigem administrador e confirmação.

| Opção | Ação |
|---|---|
| Ponto de restauração | Cria um ponto de restauração antes de mexer no sistema |
| Reparar arquivos do Windows | `DISM /RestoreHealth` seguido de `sfc /scannow` |
| Verificar disco | `chkdsk /scan` online; oferece agendar reparo completo no próximo boot |
| Resetar o Windows Update | Para os serviços, renomeia `SoftwareDistribution` e `catroot2` e reinicia os serviços |
| Resetar a rede | Limpa DNS, ARP e NetBIOS; opcionalmente renova o IP e reseta Winsock e TCP/IP |
| Limpar fila de impressão | Reinicia o spooler e apaga os trabalhos travados |
| Limpar temporários | Temp, caches, relatórios de erro, dumps e cache do Windows Update, com lixeira opcional |
| Reparar a Microsoft Store | `wsreset` |
| Explorer e cache de ícones | Reinicia o Explorer e recria o cache de ícones e miniaturas |
| Ressincronizar o relógio | Inicia o serviço de hora e força a sincronização |
| Atualizar políticas de grupo | `gpupdate /force` |

### 3. Utilitários

IP, DNS e IP público · Teste de host (DNS, ping e rota) · Teste de portas TCP · Wi-Fi (conexão atual e redes salvas) ·
Processos com maior uso de CPU e memória · Programas instalados · Serviços automáticos parados ·
Maiores arquivos de uma pasta · Hash de arquivo (SHA-256, SHA-1 e MD5, com comparação) · Impressoras e fila ·
Reinícios inesperados dos últimos 30 dias.

### 4. Ferramentas do Windows

Atalhos para Gerenciador de Tarefas, Gerenciador de Dispositivos, Gerenciamento de Disco, Serviços,
Visualizador de Eventos, Informações do Sistema, Conexões de Rede, Programas e Recursos, Monitor de Recursos,
Usuários e Grupos Locais, Agendador de Tarefas e Limpeza de Disco.

## Privacidade e segurança

- O painel **não envia dados para lugar nenhum** e não tem telemetria.
- Acessos de rede que ele faz, sempre por ação sua:
  - **IP, DNS e IP público** consulta `api.ipify.org` para descobrir o IP público.
  - **Saúde do PC** faz ping em `1.1.1.1` e resolve `www.microsoft.com` para testar a conectividade.
  - **Teste de host e de portas** falam apenas com o host que você digitar.
  - **Reparar arquivos do Windows** (DISM) pode baixar componentes do Windows Update ou do WSUS.
- A opção Wi-Fi lista os nomes das redes salvas. **Não exibe senhas.**
- Os relatórios salvos ficam em `Área de Trabalho\Relatorios_PC` e contêm nome do computador, usuário, IPs e
  lista de programas. Trate-os como informação interna.
- Como o arquivo mistura batch e PowerShell embutido (executado via `Invoke-Expression`), **alguns antivírus e EDRs
  podem sinalizá-lo por heurística**. O código está todo aberto neste repositório; se for distribuir em uma
  organização, considere liberar o arquivo pelo hash ou assiná-lo.
- Políticas como AppLocker, WDAC ou PowerShell em modo restrito podem bloquear o módulo PowerShell.
  Nesse caso o painel mostra uma mensagem explicando.

## Limitações conhecidas

- Execute a partir de um **disco local**. Em pasta de rede (UNC) o console avisa que o caminho não é suportado, e a
  reabertura como administrador não enxerga unidades de rede mapeadas.
- O painel usa UTF-8 no console (`chcp 65001`). Em versões antigas do Windows 10 esse modo pode ter falhas em
  arquivos `.bat` com acentos. Prefira uma versão atual do Windows.
- **Resetar a rede (passo 3)** pode remover configurações de IP fixo. Anote-as antes.
- **Resetar o Windows Update** zera o histórico exibido em Configurações; o que já foi instalado continua instalado.
- Alguns serviços automáticos aparecem como "parados" por design (início atrasado ou por gatilho). A tela avisa.

## Variáveis de ambiente

| Variável | Efeito |
|---|---|
| `PAINEL_COR=1` | Força as cores, mesmo quando a detecção automática desligaria |
| `PAINEL_COR=0` | Desliga as cores |

Exemplo: `set PAINEL_COR=0 && PC_Check_Painel.bat`

## Para quem for editar o código

O arquivo tem duas partes: o **batch** (menus e reparos) e, depois da linha `#PS_BEGIN`, o **módulo PowerShell**.
O `cmd` nunca chega ao módulo, porque há um `exit /b 0` antes dele. O batch lê o próprio arquivo e executa
o trecho a partir do último `#PS_BEGIN`.

Regras para não quebrar o arquivo:

- **Fim de linha CRLF** e **UTF-8 sem BOM**. O `.gitattributes` e o `.editorconfig` deste repositório já cuidam disso.
- A linha `set "ESC=..."` no começo do arquivo contém o caractere de controle **ESC (0x1B)**, invisível na maioria
  dos editores. Se ele for apagado, o painel desliga as cores sozinho; se quiser restaurá-las, reinsira o caractere.
- Nomes de labels (`:menu`, `:rep_1`, etc.) devem ser **apenas ASCII**.
- Não escreva a string `#PS_BEGIN` em nenhum outro lugar do arquivo depois do marcador real.
- Cada modo do PowerShell é escolhido pela variável `RP_MODE`, definida pela sub-rotina `:ps`.

## Licença

[MIT](LICENSE). Use, copie e adapte à vontade. O software é fornecido sem garantia; teste os reparos
em um computador não crítico antes de distribuir.
