@echo off
setlocal EnableExtensions
set "OLDCP="
for /f "tokens=2 delims=:" %%C in ('chcp') do set "OLDCP=%%C"
chcp 65001 >nul
title PC Check Painel
set "SELF=%~f0"
set "ESC="

rem ------------------------------------------------------------------
rem  PC CHECK PAINEL - v1.0
rem  Tudo em um unico arquivo: menus em batch, reparos com comandos
rem  nativos e um modulo PowerShell embutido no fim do arquivo para os
rem  diagnosticos e utilitarios. Os resultados aparecem na propria janela.
rem  Diagnosticos e utilitarios sao somente leitura, exceto a limpeza de
rem  temporarios. Reparos pedem confirmacao e exigem administrador.
rem  Cores: verde e branco. Usa sequencias ANSI; o caractere ESC (0x1B)
rem  da linha set ESC precisa ser preservado se o arquivo for editado.
rem  Variavel PAINEL_COR: 1 forca cores, 0 desliga as cores.
rem ------------------------------------------------------------------

set "ISADMIN=0"
fltmc >nul 2>&1 && set "ISADMIN=1"

rem --- cores ANSI: Windows Terminal ou Windows 10 build 19041 ou superior
set "COR=0"
if defined WT_SESSION set "COR=1"
if "%COR%"=="1" goto :cor_ok
set "BUILD="
for /f "tokens=3" %%B in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul') do set "BUILD=%%B"
if not defined BUILD goto :cor_ok
if %BUILD% GEQ 19041 set "COR=1"
:cor_ok
if "%PAINEL_COR%"=="1" set "COR=1"
if "%PAINEL_COR%"=="0" set "COR=0"
if not defined ESC set "COR=0"
call :cores

:menu
call :cabecalho "MENU PRINCIPAL"
echo    %G%[1]%R%  %W%Diagnóstico                   %R%  %D%saúde, segurança, identificação%R%
echo    %G%[2]%R%  %W%Reparos                       %R%  %D%Windows, rede, update, impressão%R%
echo    %G%[3]%R%  %W%Utilitários                   %R%  %D%rede, processos, programas, hash%R%
echo    %G%[4]%R%  %W%Ferramentas do Windows        %R%  %D%atalhos para consoles e painéis%R%
echo.
echo    %G%[5]%R%  %W%Reabrir como administrador    %R%
echo    %G%[0]%R%  %W%Sair                          %R%
echo.
echo   %D%Os resultados aparecem nesta janela.%R%
echo.
choice /c 123450 /n /m "%G%  ► Escolha: %R%"
set "SEL=%errorlevel%"
if "%SEL%"=="1" goto :menu_diag
if "%SEL%"=="2" goto :menu_rep
if "%SEL%"=="3" goto :menu_util
if "%SEL%"=="4" goto :menu_tools
if "%SEL%"=="5" goto :m_admin
if "%SEL%"=="6" goto :sair
goto :menu

rem ==================================================================
rem  DIAGNOSTICO
rem ==================================================================
:menu_diag
call :cabecalho "DIAGNÓSTICO"
echo    %G%[1]%R%  %W%Saúde do PC                   %R%  %D%disco, memória, rede, bateria%R%
echo    %G%[2]%R%  %W%Segurança                     %R%  %D%portas, inicialização, contas%R%
echo    %G%[3]%R%  %W%Completo                      %R%  %D%saúde + segurança%R%
echo    %G%[4]%R%  %W%Identificação do PC           %R%  %D%dados para abrir chamado%R%
echo    %G%[0]%R%  %W%Voltar                        %R%
echo.
echo   %D%Ao final de cada relatório: copiar ou salvar em .txt.%R%
if "%ISADMIN%"=="1" goto :diag_ask
echo   %Y%Modo usuário padrão: itens avançados aparecem como "requer administrador".%R%
:diag_ask
echo.
choice /c 12340 /n /m "%G%  ► Escolha: %R%"
set "SEL=%errorlevel%"
if "%SEL%"=="1" call :ps saude & goto :menu_diag
if "%SEL%"=="2" call :ps seguranca & goto :menu_diag
if "%SEL%"=="3" call :ps completo & goto :menu_diag
if "%SEL%"=="4" call :ps ident & goto :menu_diag
if "%SEL%"=="5" goto :menu
goto :menu_diag

rem ==================================================================
rem  UTILITARIOS
rem ==================================================================
:menu_util
call :cabecalho "UTILITÁRIOS"
echo    %G%[1]%R%  %W%IP, DNS e IP público          %R%
echo    %G%[2]%R%  %W%Testar um host                %R%  %D%DNS, ping e rota%R%
echo    %G%[3]%R%  %W%Testar portas TCP             %R%  %D%de um host%R%
echo    %G%[4]%R%  %W%Wi-Fi                         %R%  %D%conexão atual e redes salvas%R%
echo    %G%[5]%R%  %W%Processos                     %R%  %D%maiores usos de CPU e memória%R%
echo    %G%[6]%R%  %W%Programas instalados          %R%
echo    %G%[7]%R%  %W%Serviços automáticos parados  %R%
echo    %G%[8]%R%  %W%Maiores arquivos              %R%  %D%de uma pasta%R%
echo    %G%[9]%R%  %W%Hash de arquivo               %R%  %D%SHA-256, SHA-1 e MD5%R%
echo    %G%[A]%R%  %W%Impressoras e fila            %R%
echo    %G%[B]%R%  %W%Reinícios inesperados         %R%  %D%últimos 30 dias%R%
echo    %G%[0]%R%  %W%Voltar                        %R%
echo.
choice /c 123456789AB0 /n /m "%G%  ► Escolha: %R%"
set "SEL=%errorlevel%"
if "%SEL%"=="1" call :ps ipinfo & goto :menu_util
if "%SEL%"=="2" call :ps nettest & goto :menu_util
if "%SEL%"=="3" call :ps portas & goto :menu_util
if "%SEL%"=="4" goto :u_wifi
if "%SEL%"=="5" call :ps procs & goto :menu_util
if "%SEL%"=="6" call :ps programas & goto :menu_util
if "%SEL%"=="7" call :ps servicos & goto :menu_util
if "%SEL%"=="8" call :ps arquivos & goto :menu_util
if "%SEL%"=="9" call :ps hash & goto :menu_util
if "%SEL%"=="10" call :ps impressoras & goto :menu_util
if "%SEL%"=="11" call :ps reinicios & goto :menu_util
if "%SEL%"=="12" goto :menu
goto :menu_util

:u_wifi
call :cabecalho "UTILITÁRIOS  ›  WI-FI"
netsh wlan show interfaces
echo.
netsh wlan show profiles
echo.
pause
goto :menu_util

rem ==================================================================
rem  FERRAMENTAS DO WINDOWS (atalhos)
rem ==================================================================
:menu_tools
call :cabecalho "FERRAMENTAS DO WINDOWS"
echo    %G%[1]%R%  %W%Gerenciador de Tarefas        %R%
echo    %G%[2]%R%  %W%Gerenciador de Dispositivos   %R%
echo    %G%[3]%R%  %W%Gerenciamento de Disco        %R%
echo    %G%[4]%R%  %W%Serviços                      %R%
echo    %G%[5]%R%  %W%Visualizador de Eventos       %R%
echo    %G%[6]%R%  %W%Informações do Sistema        %R%
echo    %G%[7]%R%  %W%Conexões de Rede              %R%
echo    %G%[8]%R%  %W%Programas e Recursos          %R%
echo    %G%[9]%R%  %W%Monitor de Recursos           %R%
echo    %G%[A]%R%  %W%Usuários e grupos locais      %R%
echo    %G%[B]%R%  %W%Agendador de Tarefas          %R%
echo    %G%[C]%R%  %W%Limpeza de Disco              %R%
echo    %G%[0]%R%  %W%Voltar                        %R%
echo.
choice /c 123456789ABC0 /n /m "%G%  ► Abrir: %R%"
set "SEL=%errorlevel%"
if "%SEL%"=="13" goto :menu
if "%SEL%"=="1" start "" taskmgr
if "%SEL%"=="2" start "" devmgmt.msc
if "%SEL%"=="3" start "" diskmgmt.msc
if "%SEL%"=="4" start "" services.msc
if "%SEL%"=="5" start "" eventvwr.msc
if "%SEL%"=="6" start "" msinfo32
if "%SEL%"=="7" start "" ncpa.cpl
if "%SEL%"=="8" start "" appwiz.cpl
if "%SEL%"=="9" start "" resmon
if "%SEL%"=="10" start "" lusrmgr.msc
if "%SEL%"=="11" start "" taskschd.msc
if "%SEL%"=="12" start "" cleanmgr
goto :menu_tools

rem ==================================================================
rem  REPAROS (exigem administrador; cada acao pede confirmacao)
rem ==================================================================
:menu_rep
call :cabecalho "REPAROS"
echo    %G%[1]%R%  %W%Ponto de restauração          %R%  %D%faça antes dos reparos maiores%R%
echo    %G%[2]%R%  %W%Reparar arquivos do Windows   %R%  %D%DISM + SFC, demorado%R%
echo    %G%[3]%R%  %W%Verificar disco               %R%  %D%chkdsk online, sem reiniciar%R%
echo    %G%[4]%R%  %W%Resetar o Windows Update      %R%  %D%quando as atualizações travam%R%
echo    %G%[5]%R%  %W%Resetar a rede                %R%  %D%DNS, IP e Winsock%R%
echo    %G%[6]%R%  %W%Limpar fila de impressão      %R%  %D%reinicia o spooler%R%
echo    %G%[7]%R%  %W%Limpar temporários            %R%  %D%Temp, caches, lixeira opcional%R%
echo    %G%[8]%R%  %W%Reparar a Microsoft Store     %R%  %D%wsreset%R%
echo    %G%[9]%R%  %W%Explorer e cache de ícones    %R%  %D%reinicia o Explorer%R%
echo    %G%[A]%R%  %W%Ressincronizar o relógio      %R%  %D%w32tm%R%
echo    %G%[B]%R%  %W%Atualizar políticas de grupo  %R%  %D%gpupdate%R%
echo    %G%[0]%R%  %W%Voltar                        %R%
echo.
if "%ISADMIN%"=="1" goto :rep_choose
echo   %Y%Usuário padrão: ao escolher uma ação será oferecido reabrir como administrador.%R%
echo.
:rep_choose
choice /c 123456789AB0 /n /m "%G%  ► Escolha: %R%"
set "SEL=%errorlevel%"
if "%SEL%"=="0" goto :menu_rep
if "%SEL%"=="12" goto :menu
call :need_admin
if errorlevel 2 goto :sair
if errorlevel 1 goto :menu_rep
goto :rep_%SEL%

:rep_1
call :cabecalho "REPAROS  ›  PONTO DE RESTAURAÇÃO"
echo   Cria um ponto de restauração do Windows antes de mexer no sistema.
echo   Exige a Proteção do Sistema ativa. O Windows limita a um ponto a cada 24 horas.
call :confirm || goto :menu_rep
echo.
powershell -NoProfile -Command "try { Checkpoint-Computer -Description 'PC Check Painel' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; Write-Host '  Ponto de restauracao criado.' -ForegroundColor Green } catch { Write-Host ('  Nao foi possivel criar: ' + $_.Exception.Message) -ForegroundColor Yellow }"
echo.
pause
goto :menu_rep

:rep_2
call :cabecalho "REPAROS  ›  ARQUIVOS DO WINDOWS"
echo   Etapa 1: DISM restaura a imagem do Windows, usando Windows Update ou WSUS.
echo   Etapa 2: SFC verifica e repara os arquivos protegidos do sistema.
echo   %Y%Pode levar de 10 a 40 minutos. Não feche a janela.%R%
call :confirm || goto :menu_rep
echo.
echo   %G%[1/2]%R% DISM /Online /Cleanup-Image /RestoreHealth
DISM /Online /Cleanup-Image /RestoreHealth
if errorlevel 1 (
    echo.
    echo   %Y%O DISM terminou com erro. Em rede com WSUS o erro 0x800f0954 é comum.%R%
    echo   Log: %windir%\Logs\DISM\dism.log
)
echo.
echo   %G%[2/2]%R% sfc /scannow
sfc /scannow
echo.
echo   %G%Concluído.%R% Detalhes do SFC: %windir%\Logs\CBS\CBS.log
echo   Se houve correções, reinicie o computador.
echo.
pause
goto :menu_rep

:rep_3
call :cabecalho "REPAROS  ›  VERIFICAR DISCO"
echo   Executa chkdsk %SystemDrive% /scan, uma verificação online que não reinicia o PC.
call :confirm || goto :menu_rep
echo.
chkdsk %SystemDrive% /scan
echo.
echo   Erros que exigem o disco offline podem ser corrigidos no próximo boot.
echo   Nesse caso a inicialização seguinte ficará mais lenta.
choice /c SN /n /m "%G%  Agendar verificação com reparo no próximo boot? [S/N] %R%"
if errorlevel 2 goto :rep_3_fim
fsutil dirty set %SystemDrive%
echo   Agendado. Reinicie o computador para executar.
:rep_3_fim
echo.
pause
goto :menu_rep

:rep_4
call :cabecalho "REPAROS  ›  WINDOWS UPDATE"
echo   Para os serviços de atualização, renomeia as pastas SoftwareDistribution e
echo   catroot2 e reinicia os serviços. O Windows recria as pastas sozinho.
echo   O histórico exibido em Configurações será zerado; o que já foi instalado
echo   continua instalado. Feche outros instaladores antes.
call :confirm || goto :menu_rep
echo.
net stop wuauserv
net stop bits
net stop cryptsvc
net stop msiserver
if exist "%windir%\SoftwareDistribution.old" rd /s /q "%windir%\SoftwareDistribution.old"
if exist "%windir%\System32\catroot2.old" rd /s /q "%windir%\System32\catroot2.old"
ren "%windir%\SoftwareDistribution" SoftwareDistribution.old
ren "%windir%\System32\catroot2" catroot2.old
net start cryptsvc
net start bits
net start wuauserv
echo.
echo   %G%Pronto.%R% Reinicie o computador e procure atualizações novamente.
echo.
pause
goto :menu_rep

:rep_5
call :cabecalho "REPAROS  ›  REDE"
echo   Passo 1: limpa o cache DNS, ARP e NetBIOS. É seguro.
echo   Passo 2: renova o IP por DHCP. A conexão cai por alguns segundos.
echo   Passo 3: reseta Winsock e a pilha TCP/IP. Exige reiniciar e
echo   %Y%PODE remover configurações de IP fixo. Anote os IPs fixos antes.%R%
call :confirm || goto :menu_rep
echo.
ipconfig /flushdns
nbtstat -R
arp -d *
echo.
choice /c SN /n /m "%G%  Passo 2 - renovar o IP por DHCP? [S/N] %R%"
if errorlevel 2 goto :rep_5_p3
ipconfig /release
ipconfig /renew
:rep_5_p3
echo.
choice /c SN /n /m "%G%  Passo 3 - resetar Winsock e TCP/IP? [S/N] %R%"
if errorlevel 2 goto :rep_5_fim
netsh winsock reset
netsh int ip reset
echo.
echo   %G%Concluído.%R% REINICIE o computador para aplicar.
:rep_5_fim
echo.
pause
goto :menu_rep

:rep_6
call :cabecalho "REPAROS  ›  FILA DE IMPRESSÃO"
echo   Para o spooler, apaga os trabalhos travados da fila e inicia o spooler de novo.
echo   %Y%Todos os documentos pendentes de impressão neste computador serão cancelados.%R%
call :confirm || goto :menu_rep
echo.
net stop spooler
del /q /f "%windir%\System32\spool\PRINTERS\*.*" >nul 2>&1
net start spooler
echo.
pause
goto :menu_rep

:rep_7
call :cabecalho "REPAROS  ›  ARQUIVOS TEMPORÁRIOS"
echo   Remove Temp do usuário e do Windows, cache de internet, relatórios de erro,
echo   dumps de falha e o cache de download do Windows Update.
echo   Arquivos em uso são ignorados. Feche programas e instaladores antes.
echo   Ao final mostra quanto espaço foi liberado.
echo.
set "RP_LIXO=0"
choice /c SN /n /m "%G%  Esvaziar também a Lixeira? Irreversível [S/N] %R%"
if errorlevel 2 goto :rep_7_ok
set "RP_LIXO=1"
:rep_7_ok
call :confirm || goto :menu_rep
call :ps limpeza
goto :menu_rep

:rep_8
call :cabecalho "REPAROS  ›  MICROSOFT STORE"
echo   Executa wsreset: limpa o cache da Store. A Store abre ao terminar.
call :confirm || goto :menu_rep
echo.
wsreset.exe
echo.
pause
goto :menu_rep

:rep_9
call :cabecalho "REPAROS  ›  EXPLORER E ÍCONES"
echo   Encerra o Explorer, apaga o cache de ícones e miniaturas do usuário atual
echo   e inicia o Explorer de novo. A tela pisca por alguns segundos.
call :confirm || goto :menu_rep
echo.
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 2 /nobreak >nul
del /a /f /q "%localappdata%\IconCache.db" >nul 2>&1
del /a /f /q "%localappdata%\Microsoft\Windows\Explorer\iconcache*" >nul 2>&1
del /a /f /q "%localappdata%\Microsoft\Windows\Explorer\thumbcache*" >nul 2>&1
start "" explorer.exe
echo   %G%Concluído.%R%
echo.
pause
goto :menu_rep

:rep_10
call :cabecalho "REPAROS  ›  RELÓGIO"
echo   Inicia o serviço de hora se estiver parado e força a sincronização.
echo   Em domínio, relógio errado causa falhas de logon e de autenticação.
call :confirm || goto :menu_rep
echo.
sc query w32time | find "RUNNING" >nul || net start w32time
w32tm /resync /force
echo.
w32tm /query /source
echo.
pause
goto :menu_rep

:rep_11
call :cabecalho "REPAROS  ›  POLÍTICAS DE GRUPO"
echo   Executa gpupdate /force. Algumas políticas só se aplicam após logoff ou reinício.
call :confirm || goto :menu_rep
echo.
echo N | gpupdate /force
echo.
pause
goto :menu_rep

rem ==================================================================
rem  SUBROTINAS
rem ==================================================================
:cores
set "R="
set "W="
set "G="
set "D="
set "Y="
color 0F
if not "%COR%"=="1" exit /b 0
set "R=%ESC%[97;40m"
set "W=%ESC%[97;40m"
set "G=%ESC%[92;40m"
set "D=%ESC%[90;40m"
set "Y=%ESC%[93;40m"
exit /b 0

:cabecalho
cls
echo.
echo   %G%■ PC CHECK PAINEL%R%  %D%v1.0%R%
echo.
echo   %D%Computador%R%  %W%%COMPUTERNAME%%R%      %D%Usuário%R%  %W%%USERNAME%%R%
if "%ISADMIN%"=="1" goto :cab_adm
echo   %D%Permissão%R%   %W%usuário padrão%R%
goto :cab_fim
:cab_adm
echo   %D%Permissão%R%   %G%■ ADMINISTRADOR%R%
:cab_fim
echo   %D%──────────────────────────────────────────────────────────────────%R%
echo   %G%► %~1%R%
echo.
exit /b 0

:confirm
echo.
choice /c SN /n /m "%G%  Confirmar? [S/N] %R%"
if errorlevel 2 exit /b 1
if errorlevel 1 exit /b 0
exit /b 1

:ps
set "RP_MODE=%~1"
set "RP_ADMIN=%ISADMIN%"
cls
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s=[IO.File]::ReadAllText($env:SELF,[Text.Encoding]::UTF8); Invoke-Expression $s.Substring($s.LastIndexOf('#PS_BEGIN'))"
if errorlevel 1 goto :ps_erro
exit /b 0
:ps_erro
echo.
echo   %Y%Não foi possível executar o módulo PowerShell. Verifique se há política%R%
echo   %Y%de segurança bloqueando o PowerShell neste computador.%R%
echo.
pause
exit /b 1

:need_admin
if "%ISADMIN%"=="1" exit /b 0
echo.
echo   Esta ação altera o sistema e exige administrador.
choice /c SN /n /m "%G%  Reabrir o painel como administrador agora? [S/N] %R%"
if errorlevel 2 exit /b 1
call :elevar
exit /b %errorlevel%

:elevar
echo.
echo   Solicitando permissão de administrador. Confirme na janela do UAC...
powershell -NoProfile -Command "try { Start-Process -FilePath $env:SELF -Verb RunAs -ErrorAction Stop } catch { exit 1 }"
if errorlevel 1 goto :elevar_falhou
exit /b 2
:elevar_falhou
echo.
echo   %Y%Não foi possível elevar: solicitação cancelada ou negada.%R%
echo.
pause
exit /b 1

:m_admin
if "%ISADMIN%"=="1" goto :ja_admin
call :elevar
if errorlevel 2 goto :sair
goto :menu
:ja_admin
echo.
echo   Este painel já está em modo administrador.
echo.
pause
goto :menu

:sair
color
if "%COR%"=="1" <nul set /p "=%ESC%[0m"
cls
if defined OLDCP for %%C in (%OLDCP%) do chcp %%C >nul
endlocal
exit /b 0

rem --- fim da parte batch; abaixo so ha o modulo PowerShell (nunca executado pelo cmd) ---
exit /b 0
#PS_BEGIN
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference    = 'SilentlyContinue'

$mode     = $env:RP_MODE
$isAdmin  = ($env:RP_ADMIN -eq '1')
$now      = Get-Date
$hostN    = $env:COMPUTERNAME
$osInfo   = Get-CimInstance Win32_OperatingSystem
$isWs     = ($osInfo.ProductType -eq 1)
$isLaptop = [bool](Get-CimInstance Win32_Battery)
$needAdm  = 'requer administrador'

$global:RPLines  = 0
$global:RPQuit   = $false
$global:RPLog    = New-Object System.Collections.ArrayList
$global:RPAlerts = New-Object System.Collections.ArrayList

# ======================================================================
#  SAIDA NO CONSOLE: cores, paginacao e registro para copiar/salvar
# ======================================================================
function Get-ConSize {
  $w = 100; $h = 30
  try {
    $ws = $Host.UI.RawUI.WindowSize
    if ($ws.Width -gt 20) { $w = $ws.Width }
    if ($ws.Height -gt 8) { $h = $ws.Height }
  } catch { }
  return @($w, $h)
}

function Say([string]$t = '', [string]$c = 'Gray', [string]$t2 = '', [string]$c2 = 'Gray', [string]$t3 = '', [string]$c3 = 'Gray') {
  $text = $t + $t2 + $t3
  [void]$global:RPLog.Add($text)
  if ($global:RPQuit) { return }
  $sz = Get-ConSize
  $n  = [math]::Max(1, [math]::Ceiling($text.Length / [double]$sz[0]))
  if (($global:RPLines + $n) -ge ($sz[1] - 2)) {
    Write-Host '  -- ENTER: continuar    Q: parar a listagem --' -ForegroundColor 'Green' -NoNewline
    $k = [Console]::ReadKey($true)
    Write-Host ("`r" + (' ' * ($sz[0] - 1)) + "`r") -NoNewline
    $global:RPLines = 0
    if ($k.Key -eq [ConsoleKey]::Q) { $global:RPQuit = $true; return }
  }
  Write-Host $t -ForegroundColor $c -NoNewline
  if ($t2) { Write-Host $t2 -ForegroundColor $c2 -NoNewline }
  if ($t3) { Write-Host $t3 -ForegroundColor $c3 -NoNewline }
  Write-Host ''
  $global:RPLines += $n
}

function Head([string]$t) { Say ''; Say ('  ■ ' + $t + ' ' + ('─' * [math]::Max(3, 68 - $t.Length))) 'Green' }
function Sub([string]$t)  { Say ''; Say ('  ► ' + $t) 'White' }
function Note([string]$t) { Say ('  ' + $t) 'DarkGray' }

function KV($k, $v, $st = '') {
  $badge = '          '; $col = 'Gray'
  switch ($st) {
    'OK'      { $badge = '[  OK   ] '; $col = 'Green' }
    'ATENÇÃO' { $badge = '[ATENÇÃO] '; $col = 'Yellow' }
    'CRÍTICO' { $badge = '[CRÍTICO] '; $col = 'Red' }
    'n/d'     { $badge = '[  n/d  ] '; $col = 'DarkGray' }
  }
  Say ('  ' + $badge) $col (('{0,-30}' -f $k)) 'Gray' ([string]$v) 'White'
}

function Tbl($rows) {
  $rows = @($rows | Where-Object { $null -ne $_ })
  if ($rows.Count -eq 0) { Note 'Nenhum item encontrado.'; return }
  $sz = Get-ConSize
  $txt = $rows | Format-Table -AutoSize -Wrap | Out-String -Stream -Width ($sz[0] - 4)
  $i = 0
  foreach ($l in $txt) {
    if ([string]::IsNullOrWhiteSpace($l)) { continue }
    $i++
    $c = 'White'
    if ($i -eq 1) { $c = 'Green' }
    elseif ($l -match 'CRÍTICO') { $c = 'Red' }
    elseif ($l -match 'ATENÇÃO') { $c = 'Yellow' }
    Say ('  ' + $l.TrimEnd()) $c
  }
}

function Add-Alert([string]$lvl, [string]$msg) { [void]$global:RPAlerts.Add([pscustomobject]@{ Nivel = $lvl; Msg = $msg }) }
function Fmt-Date($d) { if ($d) { ([datetime]$d).ToString('dd/MM/yyyy HH:mm') } else { '—' } }
function Test-PrivateIP([string]$ip) { $ip -match '^(10\.|127\.|169\.254\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|::|fe80|fc|fd|0\.0\.0\.0)' }

function Pause-Menu {
  Write-Host ''
  Write-Host '  Pressione qualquer tecla para voltar ao menu...' -ForegroundColor 'Green' -NoNewline
  [void][Console]::ReadKey($true)
  Write-Host ''
}

function Show-Summary {
  $global:RPQuit = $false
  $crit = @($global:RPAlerts | Where-Object { $_.Nivel -eq 'crit' })
  $warn = @($global:RPAlerts | Where-Object { $_.Nivel -eq 'warn' })
  Head 'RESUMO'
  if ($crit.Count -eq 0 -and $warn.Count -eq 0) {
    Say '  Nenhum alerta nas verificações executadas.' 'Green'
  } else {
    Say ('  Críticos: {0}     Atenção: {1}' -f $crit.Count, $warn.Count) 'White'
    Say ''
    foreach ($a in $crit) { Say '  [CRÍTICO] ' 'Red' $a.Msg 'White' }
    foreach ($a in $warn) { Say '  [ATENÇÃO] ' 'Yellow' $a.Msg 'White' }
  }
}

function Finish([string]$name) {
  $global:RPQuit = $false
  Write-Host ''
  Write-Host '  ' -NoNewline
  Write-Host '[C]' -ForegroundColor 'Green' -NoNewline
  Write-Host ' copiar resultado    ' -NoNewline
  Write-Host '[S]' -ForegroundColor 'Green' -NoNewline
  Write-Host ' salvar em .txt    ' -NoNewline
  Write-Host '[ENTER]' -ForegroundColor 'Green' -NoNewline
  Write-Host ' voltar ao menu  ' -NoNewline
  $k = [Console]::ReadKey($true)
  Write-Host ''
  $body = ($global:RPLog -join "`r`n")
  if ($k.Key -eq [ConsoleKey]::C) {
    Set-Clipboard -Value $body
    Write-Host '  Copiado para a área de transferência.' -ForegroundColor 'Green'
    Pause-Menu
  } elseif ($k.Key -eq [ConsoleKey]::S) {
    $dir = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Relatorios_PC'
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $f = Join-Path $dir ('{0}_{1}_{2}.txt' -f $name, $env:COMPUTERNAME, (Get-Date).ToString('yyyyMMdd_HHmm'))
    [IO.File]::WriteAllText($f, $body, (New-Object System.Text.UTF8Encoding($true)))
    Write-Host ('  Salvo em: ' + $f) -ForegroundColor 'Green'
    Pause-Menu
  }
}

# ======================================================================
#  DIAGNOSTICO: SAUDE
# ======================================================================
function Do-Saude {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
  $bios = Get-CimInstance Win32_BIOS
  $dv   = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion
  $up   = $now - $osInfo.LastBootUpTime
  $ramT = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
  $ramF = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 1)
  $ramP = 0; if ($ramT -gt 0) { $ramP = [math]::Round(100 * $ramF / $ramT, 0) }

  $stUp = 'OK'
  if ($up.TotalDays -gt 30) { $stUp = 'ATENÇÃO'; Add-Alert 'warn' ('PC ligado há {0} dias sem reiniciar.' -f [int]$up.TotalDays) }
  $stRam = 'OK'
  if ($ramP -lt 10) { $stRam = 'ATENÇÃO'; Add-Alert 'warn' ('Pouca memória RAM livre neste momento: {0}%.' -f $ramP) }

  $reboot = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') -or
            (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') -or
            ($null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations).PendingFileRenameOperations)
  $stReb = 'OK'; $rebTxt = 'não'
  if ($reboot) { $stReb = 'ATENÇÃO'; $rebTxt = 'sim'; Add-Alert 'warn' 'Há reinicialização pendente (atualização ou instalação incompleta).' }

  $domTxt = 'Grupo de trabalho: ' + $cs.Domain
  if ($cs.PartOfDomain) { $domTxt = 'Domínio: ' + $cs.Domain }

  Head 'SISTEMA'
  KV 'Computador' $hostN
  KV 'Usuário logado' ('{0}\{1}' -f $env:USERDOMAIN, $env:USERNAME)
  KV 'Domínio' $domTxt
  KV 'Fabricante / modelo' ('{0} {1}' -f $cs.Manufacturer, $cs.Model)
  KV 'Nº de série (BIOS)' $bios.SerialNumber
  KV 'Versão da BIOS' $bios.SMBIOSBIOSVersion
  KV 'Processador' ('{0} ({1} núcleos / {2} threads)' -f ([string]$cpu.Name).Trim(), $cpu.NumberOfCores, $cpu.NumberOfLogicalProcessors)
  KV 'Memória RAM' ('{0} GB total, {1} GB livres ({2}%)' -f $ramT, $ramF, $ramP) $stRam
  KV 'Windows' ('{0} {1} (build {2})' -f $osInfo.Caption, $dv, $osInfo.BuildNumber)
  KV 'Instalado em' (Fmt-Date $osInfo.InstallDate)
  KV 'Ligado desde' ((Fmt-Date $osInfo.LastBootUpTime) + ('  (há {0}d {1}h {2}min)' -f $up.Days, $up.Hours, $up.Minutes)) $stUp
  KV 'Reinício pendente' $rebTxt $stReb

  # ---- discos
  Head 'DISCOS E ARMAZENAMENTO'
  $vols = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
    $pct = 0; if ($_.Size) { $pct = [math]::Round(100 * $_.FreeSpace / $_.Size, 1) }
    $st = 'OK'
    if ($pct -lt 15) { $st = 'ATENÇÃO'; Add-Alert 'warn' ('Unidade {0} com pouco espaço livre: {1}%.' -f $_.DeviceID, $pct) }
    if ($pct -lt 5)  { $st = 'CRÍTICO'; Add-Alert 'crit' ('Unidade {0} quase cheia: {1}% livre.' -f $_.DeviceID, $pct) }
    [pscustomobject]@{
      'Unidade'    = $_.DeviceID
      'Rótulo'     = $_.VolumeName
      'Total (GB)' = [math]::Round($_.Size / 1GB, 1)
      'Livre (GB)' = [math]::Round($_.FreeSpace / 1GB, 1)
      '% livre'    = $pct
      'Situação'   = $st
    }
  })
  Tbl $vols
  Sub 'Discos físicos'
  $pds = @(Get-PhysicalDisk | ForEach-Object {
    $st = switch ([string]$_.HealthStatus) { 'Healthy' { 'OK' } 'Unhealthy' { 'CRÍTICO' } default { 'ATENÇÃO' } }
    if ($st -eq 'CRÍTICO') { Add-Alert 'crit' ("Disco físico '{0}' reporta estado não saudável." -f $_.FriendlyName) }
    elseif ($st -eq 'ATENÇÃO') { Add-Alert 'warn' ("Disco físico '{0}' com estado de saúde {1}." -f $_.FriendlyName, $_.HealthStatus) }
    [pscustomobject]@{
      'Disco'        = $_.FriendlyName
      'Tipo'         = [string]$_.MediaType
      'Tamanho (GB)' = [math]::Round($_.Size / 1GB, 0)
      'Saúde'        = [string]$_.HealthStatus
      'Situação'     = $st
    }
  })
  Tbl $pds

  # ---- rede
  Head 'REDE E CONECTIVIDADE'
  $nets = @(Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq 'Up' } | ForEach-Object {
    [pscustomobject]@{
      'Interface' = $_.InterfaceAlias
      'IPv4'      = (@($_.IPv4Address | ForEach-Object { $_.IPAddress }) -join ', ')
      'Gateway'   = (@($_.IPv4DefaultGateway | ForEach-Object { $_.NextHop }) -join ', ')
      'DNS'       = (@($_.DNSServer | Where-Object { $_.AddressFamily -eq 2 } | ForEach-Object { $_.ServerAddresses }) -join ', ')
    }
  })
  Tbl $nets
  $gw = (@($nets | Where-Object { $_.Gateway } | Select-Object -First 1)).Gateway
  if ($gw) { $gw = ([string]$gw -split ', ')[0] }
  Note 'Testes em camadas. Redes que bloqueiam ping (ICMP) podem mostrar falha sem haver problema.'
  $okGw  = $false; if ($gw) { $okGw = [bool](Test-Connection -ComputerName $gw -Count 2 -Quiet) }
  $okNet = [bool](Test-Connection -ComputerName 1.1.1.1 -Count 2 -Quiet)
  $okDns = [bool](Resolve-DnsName 'www.microsoft.com' -Type A -DnsOnly)
  KV ('Gateway padrão ({0})' -f $gw) $(if ($okGw) { 'responde' } else { 'sem resposta' }) $(if ($okGw) { 'OK' } else { 'ATENÇÃO' })
  KV 'Saída para a internet (1.1.1.1)' $(if ($okNet) { 'responde' } else { 'sem resposta' }) $(if ($okNet) { 'OK' } else { 'ATENÇÃO' })
  KV 'Resolução de nomes (DNS)' $(if ($okDns) { 'resolve nomes' } else { 'falhou' }) $(if ($okDns) { 'OK' } else { 'ATENÇÃO' })
  if (-not $okGw -and -not $okNet -and -not $okDns) { Add-Alert 'crit' 'Sem conectividade detectada (gateway, internet e DNS falharam).' }
  elseif ($okNet -and -not $okDns) { Add-Alert 'warn' 'A internet responde por IP, mas o DNS não resolve nomes.' }

  # ---- bateria
  $batt = Get-CimInstance Win32_Battery | Select-Object -First 1
  if ($batt) {
    Head 'BATERIA'
    $des  = (Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData | Select-Object -First 1).DesignedCapacity
    $full = (Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity | Select-Object -First 1).FullChargedCapacity
    $hlt = $null
    if ($des -and $full -and $des -gt 0) { $hlt = [math]::Round(100 * $full / $des, 0) }
    KV 'Carga atual' ('{0}%' -f $batt.EstimatedChargeRemaining)
    if ($null -ne $hlt) {
      $stB = 'OK'
      if ($hlt -lt 80) { $stB = 'ATENÇÃO'; Add-Alert 'warn' ('Bateria com desgaste: {0}% da capacidade original.' -f $hlt) }
      if ($hlt -lt 60) { $stB = 'CRÍTICO'; Add-Alert 'crit' ('Bateria bastante desgastada: {0}% da capacidade original.' -f $hlt) }
      KV 'Saúde estimada' ('{0}% da capacidade original' -f $hlt) $stB
    } else {
      KV 'Saúde estimada' 'não disponível' 'n/d'
    }
  }

  # ---- atualizações
  Head 'ATUALIZAÇÕES DO WINDOWS'
  $hf = @(Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10)
  $lastHf = ($hf | Where-Object { $_.InstalledOn } | Select-Object -First 1).InstalledOn
  if ($lastHf) {
    $days = ($now - [datetime]$lastHf).Days
    $stH = 'OK'
    if ($days -gt 60) { $stH = 'ATENÇÃO'; Add-Alert 'warn' ('Nenhuma atualização do Windows registrada há {0} dias.' -f $days) }
    KV 'Última atualização registrada' ('{0} (há {1} dias)' -f ([datetime]$lastHf).ToString('dd/MM/yyyy'), $days) $stH
  }
  Tbl @($hf | ForEach-Object {
    [pscustomobject]@{ 'KB' = $_.HotFixID; 'Descrição' = $_.Description; 'Instalada em' = $(if ($_.InstalledOn) { ([datetime]$_.InstalledOn).ToString('dd/MM/yyyy') } else { '—' }); 'Instalada por' = $_.InstalledBy }
  })

  # ---- eventos
  Head 'EVENTOS CRÍTICOS E ERROS (ÚLTIMAS 24 H)'
  Note 'Agrupados por origem e ID. Logs do sistema e de aplicativos.'
  $ev = @(Get-WinEvent -FilterHashtable @{ LogName = 'System', 'Application'; Level = 1, 2; StartTime = $now.AddHours(-24) } -MaxEvents 300 -ErrorAction SilentlyContinue)
  $critEv = @($ev | Where-Object { $_.Level -eq 1 }).Count
  if ($critEv -gt 0) { Add-Alert 'warn' ('{0} evento(s) crítico(s) no log do Windows nas últimas 24 h (ex.: desligamento inesperado).' -f $critEv) }
  if ($ev.Count -ge 50) { Add-Alert 'warn' ('Muitos erros nos logs nas últimas 24 h: {0} eventos.' -f $ev.Count) }
  $evRows = $ev | Group-Object { '{0}|{1}|{2}' -f $_.LogName, $_.ProviderName, $_.Id } | Sort-Object Count -Descending | Select-Object -First 15 | ForEach-Object {
    $e = $_.Group[0]
    $m = [string]$e.Message
    $m = ($m -split "`n")[0].Trim()
    if ($m.Length -gt 90) { $m = $m.Substring(0, 87) + '...' }
    [pscustomobject]@{
      'Qtd'     = $_.Count
      'Log'     = $e.LogName
      'Fonte'   = $e.ProviderName
      'ID'      = $e.Id
      'Nível'   = $(if ($e.Level -eq 1) { 'Crítico' } else { 'Erro' })
      'Última'  = (Fmt-Date $e.TimeCreated)
      'Mensagem' = $m
    }
  }
  Tbl @($evRows)
}

# ======================================================================
#  DIAGNOSTICO: SEGURANCA
# ======================================================================
function Do-Seguranca {
  $procs = @{}
  Get-Process | ForEach-Object { $procs[[int]$_.Id] = $_.ProcessName }

  Head 'POSTURA DE SEGURANÇA'
  $avList = @(Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntivirusProduct | ForEach-Object { $_.displayName })
  $third  = @($avList | Where-Object { $_ -and $_ -notmatch 'Defender' })
  if (-not $isWs) {
    KV 'Antivírus registrado' 'não avaliado em Windows Server' 'n/d'
  } elseif ($avList.Count -gt 0) {
    KV 'Antivírus registrado' ($avList -join ', ') 'OK'
  } else {
    KV 'Antivírus registrado' 'nenhum detectado' 'CRÍTICO'
    Add-Alert 'crit' 'Nenhum antivírus registrado na Central de Segurança do Windows.'
  }

  $mp = Get-MpComputerStatus
  if ($mp) {
    $rt = [bool]$mp.RealTimeProtectionEnabled
    if ($rt) { KV 'Defender: tempo real' 'ativa' 'OK' }
    elseif ($third.Count -gt 0) { KV 'Defender: tempo real' 'desativada (há outro antivírus ativo)' 'OK' }
    else {
      KV 'Defender: tempo real' 'desativada' 'CRÍTICO'
      Add-Alert 'crit' 'Proteção em tempo real do Defender desativada e sem outro antivírus.'
    }
    if ($mp.AntivirusSignatureLastUpdated) {
      $sigAge = ($now - $mp.AntivirusSignatureLastUpdated).Days
      $stS = 'OK'
      if ($sigAge -gt 7 -and $third.Count -eq 0) { $stS = 'ATENÇÃO'; Add-Alert 'warn' ('Assinaturas do Defender desatualizadas há {0} dias.' -f $sigAge) }
      KV 'Defender: assinaturas' ('{0} (há {1} dias)' -f (Fmt-Date $mp.AntivirusSignatureLastUpdated), $sigAge) $stS
    }
  } else {
    KV 'Defender' 'não foi possível consultar' 'n/d'
  }

  foreach ($fwp in @(Get-NetFirewallProfile)) {
    $on = ([string]$fwp.Enabled -eq 'True')
    if ($on) { KV ('Firewall - perfil ' + $fwp.Name) 'ativo' 'OK' }
    else {
      KV ('Firewall - perfil ' + $fwp.Name) 'desativado' 'ATENÇÃO'
      Add-Alert 'warn' ('Firewall do Windows desativado no perfil {0} (verifique se há firewall de terceiros).' -f $fwp.Name)
    }
  }

  $lua = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System').EnableLUA
  if ($lua -eq 1) { KV 'UAC (controle de conta)' 'ativo' 'OK' }
  else { KV 'UAC (controle de conta)' 'desativado' 'CRÍTICO'; Add-Alert 'crit' 'UAC (controle de conta de usuário) está desativado.' }

  $rdpDeny = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server').fDenyTSConnections
  $nla     = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp').UserAuthentication
  if ($rdpDeny -eq 0) {
    if ($nla -eq 1) { KV 'Área de Trabalho Remota (RDP)' 'habilitada, com NLA' 'ATENÇÃO'; Add-Alert 'warn' 'RDP habilitado (com NLA). Confirme se é necessário.' }
    else { KV 'Área de Trabalho Remota (RDP)' 'habilitada SEM NLA' 'CRÍTICO'; Add-Alert 'crit' 'RDP habilitado sem autenticação em nível de rede (NLA).' }
  } else { KV 'Área de Trabalho Remota (RDP)' 'desabilitada' 'OK' }

  if ($isAdmin) {
    $smb1 = (Get-SmbServerConfiguration).EnableSMB1Protocol
    if ($smb1 -eq $true) { KV 'SMBv1' 'habilitado' 'CRÍTICO'; Add-Alert 'crit' 'Protocolo SMBv1 habilitado (obsoleto e vulnerável).' }
    elseif ($smb1 -eq $false) { KV 'SMBv1' 'desabilitado' 'OK' }
    else { KV 'SMBv1' 'não foi possível consultar' 'n/d' }

    $bl = Get-BitLockerVolume -MountPoint $env:SystemDrive
    if ($bl) {
      if ([string]$bl.ProtectionStatus -eq 'On') { KV ('BitLocker (' + $env:SystemDrive + ')') 'protegido' 'OK' }
      else {
        KV ('BitLocker (' + $env:SystemDrive + ')') 'sem proteção' 'ATENÇÃO'
        if ($isLaptop) { Add-Alert 'warn' 'Notebook sem criptografia BitLocker na unidade do sistema.' }
      }
    } else { KV 'BitLocker' 'indisponível nesta edição/sistema' 'n/d' }

    try {
      $secBoot = Confirm-SecureBootUEFI -ErrorAction Stop
      if ($secBoot) { KV 'Secure Boot' 'ativo' 'OK' } else { KV 'Secure Boot' 'desativado' 'ATENÇÃO' }
    } catch { KV 'Secure Boot' 'não suportado (BIOS legado)' 'n/d' }

    $tpm = Get-Tpm
    if ($tpm -and $tpm.TpmPresent) {
      if ($tpm.TpmReady) { KV 'TPM' 'presente e pronto' 'OK' } else { KV 'TPM' 'presente, mas não pronto' 'ATENÇÃO' }
    } else { KV 'TPM' 'não detectado' 'ATENÇÃO' }
  } else {
    KV 'SMBv1' $needAdm 'n/d'
    KV 'BitLocker' $needAdm 'n/d'
    KV 'Secure Boot' $needAdm 'n/d'
    KV 'TPM' $needAdm 'n/d'
  }

  $wl = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
  if ($wl.AutoAdminLogon -eq '1') {
    if ($wl.DefaultPassword) { KV 'Logon automático' 'ativo, com senha em texto no registro' 'CRÍTICO'; Add-Alert 'crit' 'Logon automático com senha gravada em texto no registro.' }
    else { KV 'Logon automático' 'ativo' 'ATENÇÃO'; Add-Alert 'warn' 'Logon automático do Windows está ativo.' }
  } else { KV 'Logon automático' 'desativado' 'OK' }

  # ---- contas
  Head 'CONTAS LOCAIS E ADMINISTRADORES'
  $users = @(Get-LocalUser | ForEach-Object {
    $sid = $_.SID.Value
    $st = 'OK'
    if ($_.Enabled) {
      if ($sid -like '*-501') { $st = 'CRÍTICO'; Add-Alert 'crit' 'A conta Convidado está habilitada.' }
      elseif ($sid -like '*-500') { $st = 'ATENÇÃO'; Add-Alert 'warn' ('A conta Administrador interna ({0}) está habilitada.' -f $_.Name) }
      elseif (-not $_.PasswordRequired) { $st = 'ATENÇÃO'; Add-Alert 'warn' ('A conta local {0} não exige senha.' -f $_.Name) }
    }
    [pscustomobject]@{
      'Conta'        = $_.Name
      'Ativa'        = $(if ($_.Enabled) { 'sim' } else { 'não' })
      'Exige senha'  = $(if ($_.PasswordRequired) { 'sim' } else { 'não' })
      'Senha em'     = (Fmt-Date $_.PasswordLastSet)
      'Último logon' = (Fmt-Date $_.LastLogon)
      'Situação'     = $st
    }
  })
  Tbl $users

  Sub 'Membros do grupo Administradores local'
  $adminSid = 'S-1-5-32-544'
  $adm = @()
  $gm = Get-LocalGroupMember -SID $adminSid
  if ($gm) {
    $adm = @($gm | ForEach-Object { [pscustomobject]@{ 'Membro' = $_.Name; 'Tipo' = [string]$_.ObjectClass; 'Origem' = [string]$_.PrincipalSource } })
  } else {
    $gname = ([Security.Principal.SecurityIdentifier]$adminSid).Translate([Security.Principal.NTAccount]).Value.Split('\')[-1]
    $lines = @(net localgroup $gname 2>$null | Where-Object { $_.Trim() -ne '' })
    $sep = -1
    for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^-{5,}') { $sep = $i; break } }
    if ($sep -ge 0 -and ($lines.Count - 2) -ge ($sep + 1)) {
      $adm = @($lines[($sep + 1)..($lines.Count - 2)] | ForEach-Object { [pscustomobject]@{ 'Membro' = $_.Trim(); 'Tipo' = 'n/d'; 'Origem' = 'n/d' } })
    }
  }
  if ($adm.Count -gt 4) { Add-Alert 'warn' ('O grupo Administradores local tem {0} membros. Revise se todos são necessários.' -f $adm.Count) }
  Tbl $adm

  # ---- compartilhamentos
  Head 'COMPARTILHAMENTOS DE REDE'
  Note 'Exclui os compartilhamentos administrativos padrão (C$, ADMIN$, IPC$).'
  $shares = @(Get-SmbShare | Where-Object { $_.Name -notmatch '^([A-Za-z]\$|ADMIN\$|IPC\$)$' } | ForEach-Object {
    $shr = $_
    $st = 'OK'
    if ($isAdmin) {
      $open = @(Get-SmbShareAccess -Name $shr.Name | Where-Object { $_.AccountName -match '(?i)(^|\\)(Everyone|Todos)$' -and [string]$_.AccessRight -in 'Full', 'Change' })
      if ($open.Count -gt 0) { $st = 'CRÍTICO'; Add-Alert 'crit' ('Compartilhamento {0} concede acesso de escrita a Todos.' -f $shr.Name) }
    }
    [pscustomobject]@{ 'Nome' = $shr.Name; 'Caminho' = $shr.Path; 'Descrição' = $shr.Description; 'Situação' = $st }
  })
  Tbl $shares
  if (-not $isAdmin) { Note 'As permissões de cada compartilhamento só são verificadas em modo administrador.' }

  # ---- portas em escuta
  Head 'PORTAS TCP EM ESCUTA'
  Note 'Exposição "Rede" aceita conexões de outros computadores; "Local" somente deste PC.'
  $nota = @{ 21 = 'FTP'; 23 = 'Telnet'; 135 = 'RPC'; 139 = 'NetBIOS'; 445 = 'SMB'; 3389 = 'RDP'; 5985 = 'WinRM'; 5986 = 'WinRM (TLS)'; 5900 = 'VNC'; 1433 = 'SQL Server'; 3306 = 'MySQL' }
  $sens = @(21, 23, 5900, 5985, 5986, 1433, 3306)
  $listen = @(Get-NetTCPConnection -State Listen | ForEach-Object {
    $pn = $procs[[int]$_.OwningProcess]
    if (-not $pn) { $pn = 'n/d' }
    $lp = [int]$_.LocalPort
    $exp = 'Rede'; if ($_.LocalAddress -eq '127.0.0.1' -or $_.LocalAddress -eq '::1') { $exp = 'Local' }
    [pscustomobject]@{ 'Porta' = $lp; 'Endereço' = $_.LocalAddress; 'Exposição' = $exp; 'Processo' = $pn; 'Nota' = [string]$nota[$lp] }
  })
  $lrows = $listen | Group-Object 'Porta', 'Processo', 'Exposição' | ForEach-Object {
    $g0 = $_.Group[0]
    [pscustomobject]@{
      'Porta'     = $g0.Porta
      'Exposição' = $g0.'Exposição'
      'Endereços' = (@($_.Group | ForEach-Object { $_.'Endereço' } | Select-Object -Unique) -join ', ')
      'Processo'  = $g0.Processo
      'Nota'      = $g0.Nota
    }
  } | Sort-Object Porta
  $exposedSens = @($lrows | Where-Object { $_.'Exposição' -eq 'Rede' -and ($sens -contains [int]$_.Porta) } | ForEach-Object { '{0} ({1})' -f $_.Porta, $_.Nota } | Select-Object -Unique)
  if ($exposedSens.Count -gt 0) { Add-Alert 'warn' ('Portas sensíveis aceitando conexões da rede: ' + ($exposedSens -join ', ') + '.') }
  Tbl @($lrows)

  # ---- conexões externas
  Head 'CONEXÕES COM ENDEREÇOS PÚBLICOS'
  Note 'Agrupadas por processo (top 25).'
  $estRows = @(Get-NetTCPConnection -State Established | Where-Object { -not (Test-PrivateIP $_.RemoteAddress) } |
    Group-Object OwningProcess | Sort-Object Count -Descending | Select-Object -First 25 | ForEach-Object {
      $pn = $procs[[int]$_.Name]; if (-not $pn) { $pn = 'n/d' }
      [pscustomobject]@{
        'Processo' = $pn
        'Conexões' = $_.Count
        'Destinos' = (@($_.Group | ForEach-Object { '{0}:{1}' -f $_.RemoteAddress, $_.RemotePort } | Select-Object -Unique | Select-Object -First 4) -join ', ')
      }
    })
  Tbl $estRows

  # ---- inicialização
  Head 'PROGRAMAS DE INICIALIZAÇÃO'
  Note 'Sinaliza comandos em pastas temporárias, Downloads ou Users\Public, ou com PowerShell codificado.'
  $susp = '(?i)\\(Temp|Downloads)\\|\\Users\\Public\\|\$Recycle\.Bin|\s-enc(odedcommand)?\s|mshta|bitsadmin|certutil.*urlcache'
  $runKeys = @(
    @{ P = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run';                 S = 'Máquina' },
    @{ P = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce';             S = 'Máquina (uma vez)' },
    @{ P = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run';     S = 'Máquina (32 bits)' },
    @{ P = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run';                 S = 'Usuário' },
    @{ P = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce';             S = 'Usuário (uma vez)' }
  )
  $psSkip = @('PSPath', 'PSParentPath', 'PSChildName', 'PSDrive', 'PSProvider')
  $startup = New-Object System.Collections.ArrayList
  foreach ($k in $runKeys) {
    $props = Get-ItemProperty -Path $k.P
    if ($props) {
      foreach ($pr in $props.PSObject.Properties) {
        if ($psSkip -contains $pr.Name) { continue }
        [void]$startup.Add([pscustomobject]@{ 'Escopo' = $k.S; 'Nome' = $pr.Name; 'Comando' = [string]$pr.Value })
      }
    }
  }
  foreach ($d in @([Environment]::GetFolderPath('Startup'), [Environment]::GetFolderPath('CommonStartup'))) {
    if ($d -and (Test-Path -LiteralPath $d)) {
      Get-ChildItem -LiteralPath $d -File | Where-Object { $_.Name -ne 'desktop.ini' } | ForEach-Object {
        [void]$startup.Add([pscustomobject]@{ 'Escopo' = 'Pasta Inicializar'; 'Nome' = $_.Name; 'Comando' = $_.FullName })
      }
    }
  }
  $startRows = @($startup | ForEach-Object {
    $st = 'OK'
    if ($_.Comando -match $susp) { $st = 'ATENÇÃO'; Add-Alert 'warn' ('Item de inicialização em local ou formato suspeito: {0}.' -f $_.Nome) }
    [pscustomobject]@{ 'Escopo' = $_.Escopo; 'Nome' = $_.Nome; 'Comando' = $_.Comando; 'Situação' = $st }
  })
  Tbl $startRows

  # ---- tarefas agendadas
  Head 'TAREFAS AGENDADAS FORA DO PADRÃO MICROSOFT'
  Note 'Somente tarefas habilitadas, fora da pasta \Microsoft (top 60).'
  $taskRows = @(Get-ScheduledTask | Where-Object { $_.TaskPath -notlike '\Microsoft\*' -and [string]$_.State -ne 'Disabled' } | Select-Object -First 60 | ForEach-Object {
    $a = $_.Actions | Select-Object -First 1
    $cmd = ('{0} {1}' -f $a.Execute, $a.Arguments).Trim()
    if (-not $cmd) { $cmd = '(ação COM)' }
    $st = 'OK'
    if ($cmd -match $susp) { $st = 'ATENÇÃO'; Add-Alert 'warn' ('Tarefa agendada com comando suspeito: {0}.' -f $_.TaskName) }
    [pscustomobject]@{ 'Tarefa' = $_.TaskName; 'Conta' = $_.Principal.UserId; 'Executa' = $cmd; 'Situação' = $st }
  })
  Tbl $taskRows

  # ---- logons e alterações de conta (admin)
  Head 'FALHAS DE LOGON E ALTERAÇÕES DE CONTAS'
  if ($isAdmin) {
    $fl = @(Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4625; StartTime = $now.AddDays(-7) } -MaxEvents 1000 -ErrorAction SilentlyContinue)
    $flTxt = [string]$fl.Count; if ($fl.Count -ge 1000) { $flTxt = '1000+' }
    $stF = 'OK'
    if ($fl.Count -ge 100) { $stF = 'CRÍTICO'; Add-Alert 'crit' ('{0} falhas de logon nos últimos 7 dias (possível força bruta).' -f $flTxt) }
    elseif ($fl.Count -ge 20) { $stF = 'ATENÇÃO'; Add-Alert 'warn' ('{0} falhas de logon nos últimos 7 dias.' -f $flTxt) }
    KV 'Falhas de logon (7 dias)' $flTxt $stF
    $flRows = @($fl | Group-Object { '{0}|{1}' -f $_.Properties[5].Value, $_.Properties[19].Value } | Sort-Object Count -Descending | Select-Object -First 15 | ForEach-Object {
      $e = $_.Group[0]
      [pscustomobject]@{
        'Tentativas'  = $_.Count
        'Usuário'     = [string]$e.Properties[5].Value
        'Origem (IP)' = [string]$e.Properties[19].Value
        'Estação'     = [string]$e.Properties[13].Value
        'Última'      = (Fmt-Date $e.TimeCreated)
      }
    })
    Tbl $flRows

    Sub 'Contas criadas e adições a grupos (últimos 30 dias)'
    $chg = @(Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4720, 4732; StartTime = $now.AddDays(-30) } -MaxEvents 200 -ErrorAction SilentlyContinue | ForEach-Object {
      if ($_.Id -eq 4720) {
        $what = 'Conta criada'; $obj = [string]$_.Properties[0].Value; $by = [string]$_.Properties[4].Value
      } else {
        $what = 'Adicionado ao grupo ' + [string]$_.Properties[2].Value; $obj = [string]$_.Properties[0].Value; $by = [string]$_.Properties[6].Value
      }
      [pscustomobject]@{ 'Data' = (Fmt-Date $_.TimeCreated); 'Evento' = $what; 'Alvo' = $obj; 'Feito por' = $by }
    })
    $admAdd = @($chg | Where-Object { $_.Evento -match 'Administra' }).Count
    if ($admAdd -gt 0) { Add-Alert 'warn' ('{0} adição(ões) ao grupo Administradores nos últimos 30 dias.' -f $admAdd) }
    Tbl $chg
  } else {
    KV 'Log de Segurança' $needAdm 'n/d'
    Note 'Falhas de logon e alterações de contas só podem ser lidas em modo administrador.'
  }
}

# ======================================================================
#  DIAGNOSTICO: IDENTIFICACAO PARA CHAMADOS
# ======================================================================
function Do-Ident {
  $cs   = Get-CimInstance Win32_ComputerSystem
  $bios = Get-CimInstance Win32_BIOS
  $dv   = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').DisplayVersion
  $up   = $now - $osInfo.LastBootUpTime
  $domTxt = 'Grupo de trabalho: ' + $cs.Domain
  if ($cs.PartOfDomain) { $domTxt = 'Domínio: ' + $cs.Domain }
  Head 'IDENTIFICAÇÃO DO PC (para abrir chamado)'
  KV 'Computador' $hostN
  KV 'Usuário' ('{0}\{1}' -f $env:USERDOMAIN, $env:USERNAME)
  KV 'Domínio' $domTxt
  KV 'Fabricante / modelo' ('{0} {1}' -f $cs.Manufacturer, $cs.Model)
  KV 'Nº de série' $bios.SerialNumber
  KV 'Windows' ('{0} {1} (build {2})' -f $osInfo.Caption, $dv, $osInfo.BuildNumber)
  KV 'Ligado há' ('{0}d {1}h {2}min' -f $up.Days, $up.Hours, $up.Minutes)
  KV 'Data e hora local' (Fmt-Date $now)
  Sub 'Rede'
  $rows = @(Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq 'Up' } | ForEach-Object {
    $ifc = $_
    [pscustomobject]@{
      'Interface' = $ifc.InterfaceAlias
      'IPv4'      = (@($ifc.IPv4Address | ForEach-Object { $_.IPAddress }) -join ', ')
      'MAC'       = (Get-NetAdapter -InterfaceIndex $ifc.InterfaceIndex).MacAddress
      'Gateway'   = (@($ifc.IPv4DefaultGateway | ForEach-Object { $_.NextHop }) -join ', ')
    }
  })
  Tbl $rows
}

# ======================================================================
#  UTILITARIOS
# ======================================================================
function Do-IpInfo {
  Head 'IP, DNS E CONEXÃO'
  $rows = @(Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq 'Up' } | ForEach-Object {
    $ifc = $_
    $dhcp = (Get-NetIPInterface -InterfaceIndex $ifc.InterfaceIndex -AddressFamily IPv4).Dhcp
    [pscustomobject]@{
      'Interface' = $ifc.InterfaceAlias
      'IPv4'      = (@($ifc.IPv4Address | ForEach-Object { '{0}/{1}' -f $_.IPAddress, $_.PrefixLength }) -join ', ')
      'Gateway'   = (@($ifc.IPv4DefaultGateway | ForEach-Object { $_.NextHop }) -join ', ')
      'DNS'       = (@($ifc.DNSServer | Where-Object { $_.AddressFamily -eq 2 } | ForEach-Object { $_.ServerAddresses }) -join ', ')
      'DHCP'      = [string]$dhcp
      'MAC'       = (Get-NetAdapter -InterfaceIndex $ifc.InterfaceIndex).MacAddress
    }
  })
  Tbl $rows
  Sub 'IP público'
  $pub = $null
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $pub = Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 6 -ErrorAction Stop
  } catch { $pub = $null }
  if ($pub) { KV 'IP público' ([string]$pub) } else { KV 'IP público' 'não foi possível obter (sem internet ou bloqueado)' 'n/d' }
  Note 'O IP público é obtido consultando o serviço api.ipify.org.'
}

function Do-NetTest {
  Head 'TESTE DE HOST'
  $h = ([string](Read-Host '  Host ou IP (ENTER = www.google.com)')).Trim()
  if (-not $h) { $h = 'www.google.com' }
  if ($h -notmatch '^[A-Za-z0-9._:-]+$') { Say '  Host inválido.' 'Red'; return }
  Sub ('DNS: ' + $h)
  $dns = @(Resolve-DnsName $h -DnsOnly | ForEach-Object {
    $val = $_.IPAddress; if (-not $val) { $val = $_.NameHost }
    [pscustomobject]@{ 'Nome' = $_.Name; 'Tipo' = [string]$_.Type; 'Valor' = [string]$val }
  })
  if ($dns.Count -eq 0) { KV 'Resolução' 'falhou' 'ATENÇÃO' } else { Tbl $dns }
  Sub 'Ping (4 pacotes)'
  & ping.exe -n 4 $h
  Sub 'Rota (máx. 20 saltos)'
  & tracert.exe -d -h 20 $h
}

function Do-PortCheck {
  Head 'TESTE DE PORTAS TCP'
  $h = ([string](Read-Host '  Host ou IP')).Trim()
  if ($h -notmatch '^[A-Za-z0-9._:-]+$') { Say '  Host inválido.' 'Red'; return }
  $ps = ([string](Read-Host '  Porta(s) separadas por vírgula (ex.: 80,443,3389)')).Trim()
  $ports = @($ps -split '[,; ]+' | Where-Object { $_ -match '^\d+$' -and [int]$_ -ge 1 -and [int]$_ -le 65535 } | ForEach-Object { [int]$_ })
  if ($ports.Count -eq 0) { Say '  Nenhuma porta válida.' 'Red'; return }
  Say ''
  foreach ($p in $ports) {
    $res = 'fechada, recusada ou host inacessível'; $ms = ''
    try {
      $c = New-Object System.Net.Sockets.TcpClient
      $sw = [Diagnostics.Stopwatch]::StartNew()
      $iar = $c.BeginConnect($h, $p, $null, $null)
      if ($iar.AsyncWaitHandle.WaitOne(4000, $false)) {
        $c.EndConnect($iar)
        $res = 'ABERTA'; $ms = ' ({0} ms)' -f $sw.ElapsedMilliseconds
      } else { $res = 'sem resposta em 4 s (filtrada ou host fora)' }
      $c.Close()
    } catch { $res = 'fechada, recusada ou host inacessível' }
    KV ('{0}:{1}' -f $h, $p) ($res + $ms) $(if ($res -eq 'ABERTA') { 'OK' } else { 'ATENÇÃO' })
  }
}

function Do-Procs {
  Head 'PROCESSOS'
  $cores = [int]$env:NUMBER_OF_PROCESSORS; if ($cores -lt 1) { $cores = 1 }
  [void](Get-CimInstance Win32_PerfFormattedData_PerfProc_Process)
  Start-Sleep -Milliseconds 1200
  $cpu = @(Get-CimInstance Win32_PerfFormattedData_PerfProc_Process | Where-Object { $_.Name -ne '_Total' -and $_.Name -ne 'Idle' } | Sort-Object PercentProcessorTime -Descending | Select-Object -First 12 | ForEach-Object {
    [pscustomobject]@{
      'Processo' = ($_.Name -replace '#\d+$', '')
      'PID'      = $_.IDProcess
      'CPU %'    = [math]::Round($_.PercentProcessorTime / $cores, 1)
      'RAM (MB)' = [math]::Round($_.WorkingSet / 1MB, 0)
    }
  })
  Sub 'Mais CPU agora (amostra de 1 segundo)'
  Tbl $cpu
  Sub 'Mais memória'
  $mem = @(Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 12 | ForEach-Object {
    [pscustomobject]@{ 'Processo' = $_.ProcessName; 'PID' = $_.Id; 'RAM (MB)' = [math]::Round($_.WorkingSet64 / 1MB, 0); 'Threads' = $_.Threads.Count }
  })
  Tbl $mem
}

function Do-Programs {
  Head 'PROGRAMAS INSTALADOS'
  $keys = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*')
  $apps = @(Get-ItemProperty -Path $keys | Where-Object { $_.DisplayName -and $_.SystemComponent -ne 1 -and -not $_.ParentKeyName } | Sort-Object DisplayName -Unique | ForEach-Object {
    $dt = [string]$_.InstallDate
    if ($dt -match '^\d{8}$') { $dt = '{0}/{1}/{2}' -f $dt.Substring(6, 2), $dt.Substring(4, 2), $dt.Substring(0, 4) }
    [pscustomobject]@{ 'Programa' = $_.DisplayName; 'Versão' = $_.DisplayVersion; 'Fabricante' = $_.Publisher; 'Instalado' = $dt }
  })
  Say ('  Total: {0} programas' -f $apps.Count) 'White'
  Say ''
  Tbl $apps
}

function Do-Services {
  Head 'SERVIÇOS AUTOMÁTICOS QUE NÃO ESTÃO EM EXECUÇÃO'
  Note 'Alguns param por design (início atrasado ou por gatilho), como sppsvc, gupdate e edgeupdate.'
  Note 'Para iniciar um serviço, use o console Serviços em Ferramentas do Windows.'
  $svc = @(Get-CimInstance Win32_Service | Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' } | Sort-Object DisplayName | ForEach-Object {
    [pscustomobject]@{ 'Serviço' = $_.Name; 'Nome exibido' = $_.DisplayName; 'Estado' = $_.State; 'Conta' = $_.StartName }
  })
  Say ''
  Tbl $svc
}

function Do-BigFiles {
  Head 'MAIORES ARQUIVOS DE UMA PASTA'
  $p = ([string](Read-Host ('  Pasta (ENTER = ' + $env:USERPROFILE + ')'))).Trim().Trim('"')
  if (-not $p) { $p = $env:USERPROFILE }
  if (-not (Test-Path -LiteralPath $p -PathType Container)) { Say '  Pasta não encontrada.' 'Red'; return }
  Note 'Analisando. Pode levar alguns minutos em pastas grandes; evite a raiz do disco.'
  $rows = @(Get-ChildItem -LiteralPath $p -Recurse -File -Force -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 25 | ForEach-Object {
    [pscustomobject]@{ 'MB' = [math]::Round($_.Length / 1MB, 1); 'Modificado' = $_.LastWriteTime.ToString('dd/MM/yyyy'); 'Arquivo' = $_.FullName }
  })
  Say ''
  Tbl $rows
}

function Do-Hash {
  Head 'HASH DE ARQUIVO'
  Note 'Dica: arraste o arquivo para esta janela para colar o caminho.'
  $f = ([string](Read-Host '  Caminho do arquivo')).Trim().Trim('"')
  if (-not (Test-Path -LiteralPath $f -PathType Leaf)) { Say '  Arquivo não encontrado.' 'Red'; return }
  Note 'Calculando...'
  $sha  = (Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash
  $sha1 = (Get-FileHash -LiteralPath $f -Algorithm SHA1).Hash
  $md5  = (Get-FileHash -LiteralPath $f -Algorithm MD5).Hash
  Say ''
  KV 'Arquivo' ([IO.Path]::GetFileName($f))
  KV 'SHA-256' $sha
  KV 'SHA-1' $sha1
  KV 'MD5' $md5
  $exp = ([string](Read-Host '  Cole o hash esperado para comparar (ENTER para pular)')).Trim()
  if ($exp) {
    $e = ($exp.ToUpper()) -replace '\s', ''
    if ($e -eq $sha -or $e -eq $sha1 -or $e -eq $md5) { KV 'Comparação' 'CONFERE' 'OK' } else { KV 'Comparação' 'NÃO CONFERE' 'CRÍTICO' }
  }
}

function Do-Printers {
  Head 'IMPRESSORAS'
  $pr = @(Get-CimInstance Win32_Printer | ForEach-Object {
    [pscustomobject]@{
      'Impressora' = $_.Name
      'Driver'     = $_.DriverName
      'Porta'      = $_.PortName
      'Padrão'     = $(if ($_.Default) { 'sim' } else { '' })
      'Offline'    = $(if ($_.WorkOffline) { 'sim' } else { 'não' })
    }
  })
  Tbl $pr
  Sub 'Fila de impressão'
  $jobs = @(Get-CimInstance Win32_PrintJob | ForEach-Object {
    [pscustomobject]@{ 'Trabalho' = $_.Name; 'Documento' = $_.Document; 'Usuário' = $_.Owner; 'Status' = $_.JobStatus; 'Páginas' = $_.TotalPages }
  })
  if ($jobs.Count -eq 0) { Say '  Fila vazia.' 'Green' }
  else { Tbl $jobs; Note 'Fila travada? Use Reparos > Limpar fila de impressão.' }
}

function Do-Reboots {
  Head 'REINÍCIOS E DESLIGAMENTOS (ÚLTIMOS 30 DIAS)'
  $desc = @{ 41 = 'Reinício sem desligamento limpo'; 1074 = 'Desligamento ou reinício solicitado'; 6008 = 'Desligamento anterior inesperado'; 6005 = 'Inicialização do sistema'; 6006 = 'Desligamento normal' }
  $ev = @(Get-WinEvent -FilterHashtable @{ LogName = 'System'; Id = 41, 1074, 6005, 6006, 6008; StartTime = $now.AddDays(-30) } -MaxEvents 80 -ErrorAction SilentlyContinue)
  $bad = @($ev | Where-Object { $_.Id -eq 41 -or $_.Id -eq 6008 }).Count
  $stR = 'OK'; if ($bad -gt 0) { $stR = 'ATENÇÃO' }
  KV 'Desligamentos inesperados' ([string]$bad) $stR
  $rows = @($ev | ForEach-Object {
    $det = ''
    try {
      if ($_.Id -eq 1074) { $det = '{0} ({1}) por {2}' -f ([IO.Path]::GetFileName([string]$_.Properties[0].Value)), $_.Properties[4].Value, $_.Properties[6].Value }
      elseif ($_.Id -eq 41) { $det = 'BugcheckCode: ' + $_.Properties[0].Value }
    } catch { $det = '' }
    $st = 'OK'; if ($_.Id -eq 41 -or $_.Id -eq 6008) { $st = 'ATENÇÃO' }
    [pscustomobject]@{ 'Data' = (Fmt-Date $_.TimeCreated); 'ID' = $_.Id; 'Evento' = [string]$desc[[int]$_.Id]; 'Detalhe' = $det; 'Situação' = $st }
  })
  Say ''
  Tbl $rows
  if ($bad -gt 0) { Note 'BugcheckCode diferente de 0 indica tela azul; 0 costuma ser queda de energia ou travamento.' }
}

# ======================================================================
#  LIMPEZA DE TEMPORARIOS (unica acao que altera arquivos, com confirmacao na parte batch)
# ======================================================================
function Get-DirSize([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) { return [double]0 }
  $s = (Get-ChildItem -LiteralPath $p -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
  if ($null -eq $s) { return [double]0 }
  return [double]$s
}

function Clear-Tree([string]$dir) {
  foreach ($i in @(Get-ChildItem -LiteralPath $dir -Force -ErrorAction SilentlyContinue)) {
    $link = [bool]($i.Attributes -band [IO.FileAttributes]::ReparsePoint)
    try {
      if ($i.PSIsContainer) {
        if (-not $link) { Clear-Tree $i.FullName }
        [IO.File]::SetAttributes($i.FullName, [IO.FileAttributes]::Directory)
        [IO.Directory]::Delete($i.FullName)
      } else {
        [IO.File]::SetAttributes($i.FullName, [IO.FileAttributes]::Normal)
        [IO.File]::Delete($i.FullName)
      }
    } catch { }
  }
}

function Do-Cleanup {
  Head 'LIMPEZA DE ARQUIVOS TEMPORÁRIOS'
  $sysDrive = $env:SystemDrive
  $free0 = (Get-CimInstance Win32_LogicalDisk -Filter ("DeviceID='{0}'" -f $sysDrive)).FreeSpace

  $targets = @(
    @{ N = 'Temp do usuário';                   P = $env:TEMP;                                                        A = $false },
    @{ N = 'Cache de internet (INetCache)';     P = (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\INetCache');      A = $false },
    @{ N = 'Relatórios de erro do usuário';     P = (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\WER');            A = $false },
    @{ N = 'Dumps de falha do usuário';         P = (Join-Path $env:LOCALAPPDATA 'CrashDumps');                       A = $false },
    @{ N = 'Temp do Windows';                   P = (Join-Path $env:windir 'Temp');                                   A = $true },
    @{ N = 'Cache de download do Windows Update'; P = (Join-Path $env:windir 'SoftwareDistribution\Download');        A = $true },
    @{ N = 'Relatórios de erro do sistema';     P = (Join-Path $env:ProgramData 'Microsoft\Windows\WER\ReportQueue'); A = $true }
  )

  $wasWu = ((Get-Service wuauserv).Status -eq 'Running')
  $wasBits = ((Get-Service bits).Status -eq 'Running')
  if ($isAdmin) { Stop-Service wuauserv -Force; Stop-Service bits -Force }

  $rows = @(); $totalFreed = [double]0
  foreach ($t in $targets) {
    if ($t.A -and -not $isAdmin) {
      $rows += [pscustomobject]@{ 'Local' = $t.N; 'Antes (MB)' = ''; 'Depois (MB)' = ''; 'Liberado (MB)' = ''; 'Situação' = 'n/d' }
      continue
    }
    $full = ''
    try { $full = [IO.Path]::GetFullPath([string]$t.P).TrimEnd('\') } catch { }
    if ($full.Length -le 3 -or $full -ieq ([string]$env:USERPROFILE).TrimEnd('\') -or $full -ieq ([string]$env:windir).TrimEnd('\')) {
      $rows += [pscustomobject]@{ 'Local' = $t.N; 'Antes (MB)' = ''; 'Depois (MB)' = ''; 'Liberado (MB)' = ''; 'Situação' = 'ignorado' }
      continue
    }
    if (-not (Test-Path -LiteralPath $t.P)) {
      $rows += [pscustomobject]@{ 'Local' = $t.N; 'Antes (MB)' = 0; 'Depois (MB)' = 0; 'Liberado (MB)' = 0; 'Situação' = 'OK' }
      continue
    }
    $b = Get-DirSize $t.P
    Clear-Tree $t.P
    $a = Get-DirSize $t.P
    $totalFreed += ($b - $a)
    $rows += [pscustomobject]@{ 'Local' = $t.N; 'Antes (MB)' = [math]::Round($b / 1MB, 1); 'Depois (MB)' = [math]::Round($a / 1MB, 1); 'Liberado (MB)' = [math]::Round(($b - $a) / 1MB, 1); 'Situação' = 'OK' }
  }

  if ($isAdmin) {
    if ($wasWu) { Start-Service wuauserv }
    if ($wasBits) { Start-Service bits }
  }
  if ($env:RP_LIXO -eq '1') {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Note 'Lixeira esvaziada.'
  }

  Tbl $rows
  Say ''
  KV 'Total liberado nas pastas' ('{0} MB' -f [math]::Round($totalFreed / 1MB, 1))
  $free1 = (Get-CimInstance Win32_LogicalDisk -Filter ("DeviceID='{0}'" -f $sysDrive)).FreeSpace
  if ($free0 -and $free1) {
    KV ('Espaço livre em ' + $sysDrive) ('{0} GB antes, {1} GB depois' -f [math]::Round($free0 / 1GB, 2), [math]::Round($free1 / 1GB, 2))
  }
  if (-not $isAdmin) { Note 'Modo usuário padrão: itens do Windows e do sistema foram ignorados.' }
  Note 'Arquivos em uso foram ignorados.'
}

# ======================================================================
#  DESPACHO
# ======================================================================
try {
  switch ($mode) {
    'saude'       { Do-Saude; Show-Summary; Finish 'saude' }
    'seguranca'   { Do-Seguranca; Show-Summary; Finish 'seguranca' }
    'completo'    { Do-Saude; Do-Seguranca; Show-Summary; Finish 'completo' }
    'ident'       { Do-Ident; Finish 'identificacao' }
    'ipinfo'      { Do-IpInfo; Finish 'ip' }
    'nettest'     { Do-NetTest; Pause-Menu }
    'portas'      { Do-PortCheck; Pause-Menu }
    'procs'       { Do-Procs; Finish 'processos' }
    'programas'   { Do-Programs; Finish 'programas' }
    'servicos'    { Do-Services; Finish 'servicos' }
    'arquivos'    { Do-BigFiles; Finish 'arquivos' }
    'hash'        { Do-Hash; Pause-Menu }
    'impressoras' { Do-Printers; Finish 'impressoras' }
    'reinicios'   { Do-Reboots; Finish 'reinicios' }
    'limpeza'     { Do-Cleanup; Pause-Menu }
    default       { Write-Host ('  Modo desconhecido: ' + $mode) -ForegroundColor 'Red'; Pause-Menu }
  }
  exit 0
} catch {
  Write-Host ('  Erro: ' + $_.Exception.Message) -ForegroundColor 'Red'
  Pause-Menu
  exit 0
}
