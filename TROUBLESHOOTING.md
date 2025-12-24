# Guia de Troubleshooting - Patch Rec Room

## Problemas Comuns e Soluções

### 1. O jogo ainda crasheia após aplicar o patch

**Possíveis causas:**

- O patch não foi aplicado corretamente
- Você está usando uma versão diferente do Proton
- Existem outros problemas além do coremessaging.dll

**Soluções:**

```bash
# Verificar se a DLL foi instalada
ls -la ~/.steam/steam/steamapps/common/Proton*/files/lib64/wine/coremessaging.dll.so

# Verificar logs do jogo
tail -f ~/.steam/steam/logs/steam_*.log

# Executar com debug verbose
PROTON_LOG=1 WINEDEBUG=+all %command%
```

### 2. Erro: "winegcc not found"

O script de instalação automática requer o winegcc. Se não estiver disponível:

**Solução 1: Usar Proton-GE**
```bash
# Baixe Proton-GE que inclui ferramentas de compilação
wget https://github.com/GloriousEggroll/proton-ge-custom/releases/latest
```

**Solução 2: Compilar no Wine do sistema**
```bash
# Instale wine-devel no seu sistema
sudo pacman -S mingw-w64-gcc wine  # Arch
sudo apt install wine-development   # Debian/Ubuntu

# Compile a DLL
winegcc -shared main.c -o coremessaging.dll.so -lcombase -luuid
```

### 3. O jogo inicia mas trava na tela de carregamento

**Possíveis causas:**

- Problemas com anti-cheat (Referee.dll)
- Problemas de rede/conectividade
- Falta de outras DLLs do Windows Runtime

**Soluções:**

```bash
# Adicionar mais DLLs WinRT como override
export WINEDLLOVERRIDES="coremessaging=n,b;windows.gaming.input=n,b"

# Desabilitar anti-cheat (pode não funcionar online)
# Nas opções de lançamento do Steam:
PROTON_USE_WINED3D=1 %command%
```

### 4. Erro: "CLASS_E_CLASSNOTAVAILABLE"

Este não é um erro! É o comportamento esperado do stub. O jogo deve continuar executando.

Se o jogo crasheia mesmo assim, significa que ele **requer** a implementação completa da funcionalidade WinRT.

**Solução avançada:**

Você precisará de uma implementação mais completa. Considere:
- Usar Windows em dual-boot
- Usar uma VM com GPU passthrough
- Aguardar implementação oficial no Wine/Proton

### 5. Problemas de Performance

O stub não deve afetar a performance. Se você notar lentidão:

```bash
# Desabilitar logs de debug
unset WINEDEBUG
unset PROTON_LOG

# Usar DXVK (padrão no Proton)
# Certifique-se de que está habilitado
PROTON_USE_WINED3D=0 %command%

# Habilitar fsync/esync
PROTON_NO_ESYNC=0 PROTON_NO_FSYNC=0 %command%
```

### 6. Erro: "Permission denied"

```bash
# Dar permissões corretas
chmod 755 ~/.steam/steam/steamapps/common/Proton*/files/lib64/wine/coremessaging.dll.so

# Verificar propriedade dos arquivos
ls -la ~/.steam/steam/steamapps/common/Proton*/files/lib64/wine/coremessaging.dll.so
```

### 7. O patch funciona mas recursos online não funcionam

Isso pode ser devido ao anti-cheat Referee.dll detectado no log.

**Soluções limitadas:**

- Alguns jogos com anti-cheat não funcionam no Linux
- Verifique ProtonDB para workarounds específicos
- Considere usar o modo offline (se disponível)

## Verificação de Instalação

### Checklist de Verificação

```bash
# 1. Verificar se a DLL existe
test -f ~/.steam/steam/steamapps/common/Proton*/files/lib64/wine/coremessaging.dll.so && echo "✓ DLL instalada" || echo "✗ DLL não encontrada"

# 2. Verificar permissões
stat -c "%a %n" ~/.steam/steam/steamapps/common/Proton*/files/lib64/wine/coremessaging.dll.so

# 3. Verificar se é um arquivo válido
file ~/.steam/steam/steamapps/common/Proton*/files/lib64/wine/coremessaging.dll.so

# 4. Testar carregamento (requer Wine)
wine64 regsvr32 /path/to/coremessaging.dll.so
```

## Logs Úteis

### Onde encontrar logs

```bash
# Logs do Steam
~/.steam/steam/logs/

# Logs do jogo (com PROTON_LOG=1)
~/.steam/steam/steamapps/compatdata/471710/pfx/

# Crash dumps
~/.steam/steam/steamapps/compatdata/471710/pfx/drive_c/users/steamuser/Temp/
```

### Como analisar logs

```bash
# Procurar por erros de coremessaging
grep -i "coremessaging" ~/.steam/steam/logs/steam_*.log

# Procurar por crashes
grep -i "exception\|crash\|unhandled" ~/.steam/steam/logs/steam_*.log

# Ver últimas linhas antes do crash
tail -n 100 ~/.steam/steam/logs/steam_*.log
```

## Revertendo o Patch

Se você quiser remover o patch:

```bash
# Remover a DLL
rm ~/.steam/steam/steamapps/common/Proton*/files/lib64/wine/coremessaging.dll.so

# Restaurar do backup
cp ~/.proton_patches_backup/TIMESTAMP/coremessaging.dll.so \
   ~/.steam/steam/steamapps/common/Proton*/files/lib64/wine/

# Ou simplesmente reinstalar o Proton pelo Steam
```

## Reportando Problemas

Se você encontrar problemas:

1. **Colete informações:**
   ```bash
   # Informações do sistema
   uname -a
   lsb_release -a
   
   # Versão do Proton
   cat ~/.steam/steam/steamapps/common/Proton*/version
   
   # Logs relevantes
   grep -A 20 -B 5 "coremessaging" ~/.steam/steam/logs/steam_*.log
   ```

2. **Reporte em:**
   - ProtonDB: https://www.protondb.com/app/471710
   - GitHub do Proton: https://github.com/ValveSoftware/Proton/issues
   - Wine AppDB: https://appdb.winehq.org/

3. **Inclua:**
   - Distribuição Linux e versão
   - Versão do Proton
   - Logs completos
   - Passos para reproduzir

## Alternativas

Se o patch não funcionar para você:

1. **Proton-GE**: Versões da comunidade com mais patches
2. **Lutris**: Pode ter runners específicos para o jogo
3. **Bottles**: Gerenciador de Wine com configurações pré-definidas
4. **Dual-boot Windows**: Para máxima compatibilidade

## Recursos Adicionais

- **ProtonDB**: https://www.protondb.com/app/471710
- **Wine HQ**: https://www.winehq.org/
- **Proton GitHub**: https://github.com/ValveSoftware/Proton
- **Proton-GE**: https://github.com/GloriousEggroll/proton-ge-custom
- **r/linux_gaming**: https://reddit.com/r/linux_gaming
