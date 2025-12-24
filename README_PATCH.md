# Patch de Correção para Rec Room no Proton

## Descrição do Problema

O jogo **Rec Room** (Steam AppID 471710) apresenta crash ao tentar inicializar devido à função não implementada `DllGetActivationFactory` na DLL `coremessaging.dll` do Windows Runtime (WinRT).

### Erro Original
```
wine: Call from 00006FFFFFC0D157 to unimplemented function coremessaging.dll.DllGetActivationFactory, aborting
Unhandled exception: unimplemented function coremessaging.dll.DllGetActivationFactory called in 64-bit code
```

## Solução Implementada

Este patch adiciona uma implementação stub (mínima) da DLL `coremessaging.dll` ao Wine/Proton, incluindo:

1. **DllGetActivationFactory**: Retorna `CLASS_E_CLASSNOTAVAILABLE` em vez de crashar
2. **DllCanUnloadNow**: Implementação padrão
3. **DllGetClassObject**: Implementação padrão

A implementação permite que o jogo trate graciosamente a ausência da funcionalidade WinRT em vez de crashar.

## Como Aplicar o Patch

### Opção 1: Aplicar no Source do Wine/Proton (Recomendado)

Se você compila o Proton a partir do código-fonte:

```bash
# 1. Clone o repositório do Proton (se ainda não tiver)
git clone https://github.com/ValveSoftware/Proton.git
cd Proton

# 2. Entre no diretório do Wine
cd wine

# 3. Aplique o patch
git apply /caminho/para/recroom_coremessaging_fix.patch

# 4. Recompile o Proton
cd ..
./configure.sh
make
```

### Opção 2: Criar DLL Manualmente

Se você não quer recompilar todo o Proton, pode criar apenas a DLL:

```bash
# 1. Extraia os arquivos do patch
mkdir -p dlls/coremessaging
cd dlls/coremessaging

# 2. Crie os arquivos main.c, Makefile.in e coremessaging.spec
# (copie o conteúdo do patch)

# 3. Compile usando o ambiente Wine
winegcc -shared main.c -o coremessaging.dll -lcombase -luuid

# 4. Copie para o diretório do Proton
cp coremessaging.dll ~/.steam/steam/steamapps/common/Proton*/files/lib64/wine/
```

### Opção 3: Usar Proton-GE (Alternativa)

O Proton-GE frequentemente inclui patches da comunidade. Verifique se uma versão recente já inclui este fix:

```bash
# Baixe a versão mais recente do Proton-GE
# https://github.com/GloriousEggroll/proton-ge-custom/releases

# Extraia e configure no Steam
mkdir -p ~/.steam/root/compatibilitytools.d/
tar -xf GE-Proton*.tar.gz -C ~/.steam/root/compatibilitytools.d/
```

## Testando o Patch

Após aplicar o patch:

1. Reinicie o Steam
2. Nas propriedades do Rec Room, selecione a versão do Proton com o patch
3. Execute o jogo
4. Verifique o log em `~/.steam/steam/logs/` para confirmar que o erro não ocorre mais

## Verificação

Para verificar se o patch foi aplicado corretamente, procure no log do jogo:

```
FIXME:coremessaging:DllGetActivationFactory class <nome_da_classe> stub!
```

Em vez do erro fatal anterior, você verá apenas um aviso FIXME, e o jogo deve continuar executando.

## Limitações

- Este é um **stub** (implementação mínima) que apenas previne o crash
- Funcionalidades que dependem do Windows Runtime messaging podem não funcionar completamente
- O jogo deve funcionar, mas recursos específicos de notificações/mensagens podem estar limitados

## Contribuindo

Se você melhorar este patch ou implementar funcionalidades adicionais da `coremessaging.dll`, considere:

1. Submeter ao projeto Wine: https://www.winehq.org/contributing
2. Submeter ao Proton: https://github.com/ValveSoftware/Proton
3. Compartilhar no ProtonDB: https://www.protondb.com/app/471710

## Informações Técnicas

- **Versão do Proton testada**: experimental-10.0-20251222
- **Kernel**: Linux 6.18.1-arch1-2
- **Arquitetura**: x86_64
- **Game Engine**: Unity (UnityPlayer.dll detectado)
- **Anti-cheat**: Referee.dll (pode causar problemas adicionais)

## Suporte

Para problemas ou dúvidas:
- ProtonDB: https://www.protondb.com/app/471710
- Wine AppDB: https://appdb.winehq.org/
- Steam Community: Fóruns do Rec Room

## Licença

Este patch é distribuído sob a mesma licença do Wine (LGPL 2.1+).
