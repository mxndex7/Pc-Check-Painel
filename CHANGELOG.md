# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/).

## [1.0.0] - 2026-09-28

Primeira versão pública.

### Adicionado
- Painel em um único arquivo `.bat`, com menus em batch e módulo PowerShell embutido.
- **Diagnóstico**: saúde do PC, segurança, relatório completo e identificação do PC para chamados.
- **Reparos** (com confirmação e exigência de administrador): ponto de restauração, DISM + SFC,
  chkdsk, reset do Windows Update, reset de rede, fila de impressão, temporários, Microsoft Store,
  Explorer e cache de ícones, relógio e políticas de grupo.
- **Utilitários**: IP e DNS, teste de host, teste de portas TCP, Wi-Fi, processos, programas instalados,
  serviços automáticos parados, maiores arquivos, hash de arquivo, impressoras, reinícios inesperados.
- **Ferramentas do Windows**: atalhos para os consoles e painéis mais usados.
- Resultados exibidos na própria janela, com paginação, resumo de alertas e opção de copiar
  ou salvar em `.txt`.
- Interface em verde e branco (ANSI), com desativação automática quando o console não suporta cores.
- Limpeza de temporários que não segue atalhos de pasta (junctions e links simbólicos) e ignora
  caminhos perigosos.
- A página de código do console é restaurada ao sair.
