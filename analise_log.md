# Análise do Log do Rec Room - Proton

## Problemas Identificados

### 1. Erro Principal: Função Não Implementada
**Erro crítico**: `coremessaging.dll.DllGetActivationFactory` não está implementada no Wine/Proton

```
wine: Call from 00006FFFFFC0D157 to unimplemented function coremessaging.dll.DllGetActivationFactory, aborting
Unhandled exception: unimplemented function coremessaging.dll.DllGetActivationFactory called in 64-bit code
```

Este é o erro fatal que causa o crash do jogo. A DLL `coremessaging.dll` é uma biblioteca do Windows Runtime (WinRT) usada para mensagens entre processos e notificações.

### 2. Erros de LD_PRELOAD (Não Críticos)
```
ERROR: ld.so: object '/home/shdw/Development/Millennium/build/src/hhx64-build/libmillennium_hhx64.so' from LD_PRELOAD cannot be preloaded
```
Estes erros são repetidos mas não são críticos - apenas indicam que uma biblioteca externa (Millennium) não está disponível.

### 3. Exceções de Acesso à Memória
Múltiplas exceções `EXCEPTION_ACCESS_VIOLATION` (código c0000005) e `EXCEPTION_PRIV_INSTRUCTION` (código c0000096) relacionadas ao módulo `Referee.dll`:

```
5920.809:01a0:01a4:trace:seh:dispatch_exception code=c0000096 (EXCEPTION_PRIV_INSTRUCTION) flags=0 addr=000000018229C7D9
```

### 4. Serviço Bluetooth Falhou ao Iniciar
```
5913.378:0090:009c:err:ntoskrnl:ZwLoadDriver failed to create driver L"\\Registry\\Machine\\System\\CurrentControlSet\\Services\\winebth": c0000142
5913.379:0030:0034:fixme:service:scmdatabase_autostart_services Auto-start service L"winebth" failed to start: 1114
```

### 5. Avisos Diversos (Fixme)
- `fixme:file:GetLongPathNameW UNC pathname` - Problemas com caminhos UNC
- `fixme:uiautomation` - Funcionalidades de UI Automation não implementadas
- `fixme:oleacc:find_class_data unhandled window class: L"#32769"`

## Causa Raiz do Crash

O jogo Rec Room (baseado em Unity) tenta usar a API Windows Runtime (WinRT) através da DLL `coremessaging.dll` para funcionalidades de mensageria/notificações. Esta DLL e especificamente a função `DllGetActivationFactory` não estão implementadas no Wine/Proton, causando o crash.

## Solução Necessária

É necessário criar um stub (implementação mínima) para a função `DllGetActivationFactory` na DLL `coremessaging.dll` no Wine/Proton.
