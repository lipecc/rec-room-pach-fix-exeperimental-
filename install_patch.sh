#!/bin/bash
# Script de Instalação do Patch Rec Room para Proton (v5 - Correção de Permissões)
# Autor: RecRoom Proton Fix
# Data: 23/12/2024

set -e

echo "======================================"
echo "Patch Rec Room - Proton Coremessaging"
echo "======================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
print_error() { echo -e "${RED}[ERRO]${NC} $1"; }

# Verificar se está rodando como root (não recomendado, mas vamos checar)
if [ "$EUID" -eq 0 ]; then 
    print_warn "Você está rodando como root. Isso pode alterar as permissões dos arquivos do Steam."
fi

# Detectar diretório do Steam
STEAM_DIR=""
if [ -d "$HOME/.steam/steam" ]; then
    STEAM_DIR="$HOME/.steam/steam"
elif [ -d "$HOME/.local/share/Steam" ]; then
    STEAM_DIR="$HOME/.local/share/Steam"
else
    print_error "Diretório do Steam não encontrado!"
    exit 1
fi

# Listar versões do Proton
IFS=$'\n'
PROTON_DIRS=($(find "$STEAM_DIR/steamapps/common" -maxdepth 1 -type d -name "Proton*" 2>/dev/null))
unset IFS

if [ ${#PROTON_DIRS[@]} -eq 0 ]; then
    print_error "Nenhuma instalação do Proton encontrada!"
    exit 1
fi

print_info "Versões do Proton encontradas:"
for i in "${!PROTON_DIRS[@]}"; do
    echo "  [$i] $(basename "${PROTON_DIRS[$i]}")"
done

echo ""
read -p "Selecione a versão do Proton [0-$((${#PROTON_DIRS[@]}-1))]: " PROTON_INDEX
SELECTED_PROTON="${PROTON_DIRS[$PROTON_INDEX]}"

# --- BUSCA DIRETÓRIO WINE ---
WINE_LIB_DIR=""
POSSIBLE_PATHS=(
    "$SELECTED_PROTON/files/lib64/wine/x86_64-windows"
    "$SELECTED_PROTON/files/lib/wine/x86_64-windows"
    "$SELECTED_PROTON/files/lib64/wine"
    "$SELECTED_PROTON/files/lib/wine"
)
for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$path" ]; then WINE_LIB_DIR="$path"; break; fi
done

if [ -z "$WINE_LIB_DIR" ]; then
    WINE_LIB_DIR=$(find "$SELECTED_PROTON" -type d -name "x86_64-windows" | grep "wine" | head -n 1 || true)
fi

# --- COMPILAÇÃO ---
print_info "Compilando coremessaging.dll..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

cat > main.c << 'EOF'
#include <stdarg.h>
#define COBJMACROS
#include "windef.h"
#include "winbase.h"
#include "winstring.h"
#include "wine/debug.h"
#include "objbase.h"
#include "initguid.h"
#include "activation.h"
WINE_DEFAULT_DEBUG_CHANNEL(coremessaging);
BOOL WINAPI DllMain(HINSTANCE instance, DWORD reason, void *reserved) { return TRUE; }
HRESULT WINAPI DllGetActivationFactory(HSTRING class_str, IActivationFactory **factory) {
    if (!factory) return E_INVALIDARG;
    *factory = NULL;
    return CLASS_E_CLASSNOTAVAILABLE;
}
HRESULT WINAPI DllCanUnloadNow(void) { return S_FALSE; }
HRESULT WINAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, void **out) {
    if (!out) return E_INVALIDARG;
    return CLASS_E_CLASSNOTAVAILABLE;
}
EOF

cat > coremessaging.spec << 'EOF'
@ stdcall DllGetActivationFactory(ptr ptr)
@ stdcall DllCanUnloadNow()
@ stdcall DllGetClassObject(ptr ptr ptr)
EOF

WINEGCC="$SELECTED_PROTON/files/bin/winegcc"
if [ ! -f "$WINEGCC" ]; then WINEGCC="winegcc"; fi

"$WINEGCC" -m64 -shared main.c coremessaging.spec -o coremessaging.dll.so -lcombase -luuid

# --- INSTALAÇÃO COM TRATAMENTO DE PERMISSÕES ---
install_file() {
    local src=$1
    local dest=$2
    print_info "Instalando em: $dest"
    
    # Tentar remover o arquivo existente primeiro (ajuda se estiver travado)
    if [ -f "$dest" ]; then
        rm -f "$dest" || (print_warn "Falha ao remover $dest, tentando com sudo..." && sudo rm -f "$dest")
    fi
    
    # Tentar copiar
    cp "$src" "$dest" || (print_warn "Falha ao copiar para $dest, tentando com sudo..." && sudo cp "$src" "$dest")
    
    # Garantir permissões de leitura/execução
    sudo chmod 644 "$dest" || true
    sudo chown $USER:$USER "$dest" || true
}

# 1. Instalar no diretório do Proton
install_file "coremessaging.dll.so" "$WINE_LIB_DIR/coremessaging.dll"
if [[ "$WINE_LIB_DIR" == *"x86_64-windows"* ]]; then
    # Em algumas versões do Proton, o arquivo precisa estar um nível acima também
    install_file "coremessaging.dll.so" "$(dirname "$WINE_LIB_DIR")/coremessaging.dll" || true
fi

# 2. Instalar no prefixo do jogo
COMPAT_DATA_DIR="$STEAM_DIR/steamapps/compatdata/471710/pfx"
if [ -d "$COMPAT_DATA_DIR" ]; then
    SYS32_DIR="$COMPAT_DATA_DIR/drive_c/windows/system32"
    if [ -d "$SYS32_DIR" ]; then
        install_file "coremessaging.dll.so" "$SYS32_DIR/coremessaging.dll"
    fi
    
    # Aplicar override no registro
    cat > override.reg << 'EOF'
REGEDIT4
[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"coremessaging"="native,builtin"
EOF
    WINE_BIN="$SELECTED_PROTON/files/bin/wine"
    if [ -f "$WINE_BIN" ]; then
        WINEPREFIX="$COMPAT_DATA_DIR" "$WINE_BIN" regedit override.reg &> /dev/null || true
    fi
fi

rm -rf "$TEMP_DIR"

echo ""
print_info "======================================"
print_info "Patch v5 instalado com sucesso!"
print_info "======================================"
echo ""
print_warn "Se o jogo pedir senha, é para o comando 'sudo' conseguir sobrescrever os arquivos protegidos."
echo ""
