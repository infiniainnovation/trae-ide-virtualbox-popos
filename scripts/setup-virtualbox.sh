#!/bin/bash
# TRAE IDE VirtualBox Setup Script for Pop!_OS
# Maintained by infiniainnovation
# Version: 1.2.0

set -e

# Colores para salida
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables globales
VM_NAME="Trae-IDE-Windows"
VM_DIR="$HOME/VirtualBox VMs/$VM_NAME"
SHARED_FOLDER="$HOME/trae-projects"
ISO_PATH=""
WINDOWS_USER=""
GITHUB_USER="infiniainnovation"

# Funciones de utilidad
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}!${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

# Verificar que se ejecute como usuario normal
if [ "$(id -u)" = "0" ]; then
    error "Este script NO debe ejecutarse como root. Usa tu usuario normal."
fi

# Verificar requisitos previos
check_prerequisites() {
    log "Verificando requisitos del sistema..."
    
    # Verificar virtualización
    if ! grep -E --color=never -q '(vmx|svm)' /proc/cpuinfo; then
        warning "Virtualización no habilitada en BIOS. Necesitarás habilitarla manualmente."
        read -p "¿Deseas continuar de todos modos? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Verificar espacio en disco
    FREE_SPACE=$(df -BG --output=avail "$HOME" | tail -1 | tr -d 'G B')
    if [ "$FREE_SPACE" -lt 100 ]; then
        error "Necesitas al menos 100GB de espacio libre en $HOME. Solo tienes ${FREE_SPACE}GB disponibles."
    fi
    
    # Verificar RAM
    TOTAL_RAM=$(free -g | awk '/Mem:/ {print $2}')
    if [ "$TOTAL_RAM" -lt 16 ]; then
        warning "Se recomiendan 16GB+ de RAM para un buen rendimiento. Tienes ${TOTAL_RAM}GB."
        read -p "¿Deseas continuar de todos modos? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    success "Requisitos mínimos verificados."
}

# Instalar VirtualBox
install_virtualbox() {
    log "Configurando repositorio de VirtualBox..."
    
    # Eliminar archivos incorrectos si existen
    sudo rm -f /usr/share/keyrings/oracle-virtualbox-2016.gpg
    sudo rm -f /etc/apt/sources.list.d/virtualbox.list
    
    # Descargar clave GPG correcta
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo tee /usr/share/keyrings/virtualbox.asc >/dev/null
    
    # Crear archivo de repositorio
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/virtualbox.asc] https://download.virtualbox.org/virtualbox/debian jammy contrib" | \
    sudo tee /etc/apt/sources.list.d/virtualbox.list >/dev/null
    
    # Actualizar e instalar
    sudo apt update
    sudo apt install -y virtualbox-7.0 dkms
    
    # Instalar Extension Pack
    log "Descargando VirtualBox Extension Pack..."
    EXT_PACK_URL=$(curl -s https://download.virtualbox.org/virtualbox/ | grep -oP '(\d+\.\d+\.\d+)' | head -1)
    wget "https://download.virtualbox.org/virtualbox/$EXT_PACK_URL/Oracle_VM_VirtualBox_Extension_Pack-$EXT_PACK_URL.vbox-extpack" -O /tmp/vbox-extpack.vbox-extpack
    
    sudo VBoxManage extpack install --replace /tmp/vbox-extpack.vbox-extpack
    rm /tmp/vbox-extpack.vbox-extpack
    
    success "VirtualBox 7.0 instalado correctamente."
}

# Crear VM
create_vm() {
    log "Creando máquina virtual '$VM_NAME'..."
    
    # Crear VM
    VBoxManage createvm --name "$VM_NAME" --ostype "Windows11_64" --register
    
    # Configurar memoria y CPU
    TOTAL_CPUS=$(nproc)
    ALLOC_CPUS=$((TOTAL_CPUS < 8 ? $TOTAL_CPUS/2 : 4))
    [ $ALLOC_CPUS -lt 2 ] && ALLOC_CPUS=2
    [ $ALLOC_CPUS -gt 6 ] && ALLOC_CPUS=6
    
    VBoxManage modifyvm "$VM_NAME" \
        --memory 8192 \
        --vram 256 \
        --cpus $ALLOC_CPUS \
        --pae on \
        --hpet on
    
    # Configurar sistema
    VBoxManage modifyvm "$VM_NAME" \
        --firmware efi \
        --biossystemtimeoffset 0 \
        --bioslogofadein off \
        --bioslogofadeout off \
        --bioslogodisplaytime 0
    
    # Configurar gráficos
    VBoxManage modifyvm "$VM_NAME" \
        --graphicscontroller vmsvga \
        --accelerate3d on \
        --accelerate2dvideo on
    
    # Configurar red y USB
    VBoxManage modifyvm "$VM_NAME" \
        --nic1 nat \
        --nictype1 82545EM \
        --cableconnected1 on \
        --usbehci off \
        --usbxhci on \
        --audio dsound \
        --audiocodec stac9700
    
    # Configurar port forwarding (SSH y servidores de desarrollo)
    VBoxManage modifyvm "$VM_NAME" \
        --natpf1 "ssh,tcp,,2222,,22" \
        --natpf1 "http,tcp,,8080,,8080" \
        --natpf1 "dev3000,tcp,,3000,,3000" \
        --natpf1 "dev3001,tcp,,3001,,3001"
    
    # Crear disco duro
    log "Creando disco duro virtual (80GB)..."
    VBoxManage createhd --filename "$VM_DIR/$VM_NAME.vdi" --size 81920 --variant Standard
    
    # Configurar controladores de almacenamiento
    VBoxManage storagectl "$VM_NAME" --name "SATA" --add sata --controller IntelAhci --portcount 2
    VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VM_DIR/$VM_NAME.vdi"
    
    # Adjuntar ISO de Windows (si existe)
    if [ -n "$ISO_PATH" ] && [ -f "$ISO_PATH" ]; then
        VBoxManage storagectl "$VM_NAME" --name "IDE" --add ide --controller PIIX4
        VBoxManage storageattach "$VM_NAME" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH"
        VBoxManage modifyvm "$VM_NAME" --boot1 dvd --boot2 disk --boot3 none --boot4 none
    fi
    
    success "Máquina virtual configurada correctamente."
}

# Configurar carpetas compartidas
setup_shared_folder() {
    log "Configurando carpeta compartida..."
    
    mkdir -p "$SHARED_FOLDER"
    
    VBoxManage sharedfolder add "$VM_NAME" \
        --name "trae-projects" \
        --hostpath "$SHARED_FOLDER" \
        --automount
    
    success "Carpeta compartida '$SHARED_FOLDER' configurada."
}

# Crear script de inicio
create_start_script() {
    log "Creando script de inicio rápido..."
    
    mkdir -p "$HOME/bin"
    
    cat > "$HOME/bin/start-trae-vm" << EOF
#!/bin/bash
# Script para iniciar TRAE IDE VM rápidamente
VM_NAME="$VM_NAME"

# Verificar si la VM existe
if ! VBoxManage showvminfo "\$VM_NAME" &>/dev/null; then
    echo "Error: La VM '\$VM_NAME' no existe."
    exit 1
fi

# Iniciar VM
echo "Iniciando VM '\$VM_NAME'..."
VBoxManage startvm "\$VM_NAME" --type gui

# Esperar para que la VM arranque
echo "Esperando 60 segundos para que la VM arranque..."
sleep 60

# Abrir carpeta compartida en VS Code si está instalado
if command -v code &> /dev/null; then
    echo "Abriendo carpeta de proyectos en VS Code..."
    code "$SHARED_FOLDER"
else
    echo "VS Code no está instalado. Abriendo carpeta de proyectos en el explorador de archivos..."
    xdg-open "$SHARED_FOLDER"
fi

echo "¡Listo! TRAE IDE debería estar disponible en unos momentos."
EOF
    
    chmod +x "$HOME/bin/start-trae-vm"
    export PATH="$HOME/bin:$PATH"
    
    # Añadir a .bashrc/.zshrc si no existe
    if [ -f "$HOME/.bashrc" ] && ! grep -q "export PATH=\"$HOME/bin:\$PATH\"" "$HOME/.bashrc"; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    
    if [ -f "$HOME/.zshrc" ] && ! grep -q "export PATH=\"$HOME/bin:\$PATH\"" "$HOME/.zshrc"; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    
    success "Script de inicio creado en ~/bin/start-trae-vm"
}

# Configuración interactiva
interactive_setup() {
    log "Configuración interactiva..."
    
    # Preguntar por ISO de Windows
    while true; do
        read -p "Ruta al ISO de Windows 11 (dejar en blanco para configurar después): " ISO_PATH
        if [ -z "$ISO_PATH" ]; then
            warning "Configurarás el ISO manualmente después."
            break
        elif [ -f "$ISO_PATH" ]; then
            success "ISO encontrado en $ISO_PATH"
            break
        else
            error "El archivo ISO no existe en $ISO_PATH"
        fi
    done
    
    # Preguntar por nombre de usuario de Windows
    read -p "Nombre de usuario para Windows (predeterminado: user): " WINDOWS_USER
    WINDOWS_USER=${WINDOWS_USER:-user}
    
    # Preguntar por carpeta compartida
    read -p "Carpeta para proyectos compartidos (predeterminado: ~/trae-projects): " CUSTOM_FOLDER
    if [ -n "$CUSTOM_FOLDER" ]; then
        SHARED_FOLDER=$(realpath "$CUSTOM_FOLDER")
        mkdir -p "$SHARED_FOLDER"
    fi
    
    success "Configuración guardada."
}

# Mensaje final
show_final_message() {
    cat << EOF

${GREEN}🎉 ¡Configuración completada exitosamente!${NC}

${BLUE}Próximos pasos:${NC}
1. ${YELLOW}Inicia la VM:${NC} start-trae-vm
2. ${YELLOW}Completa la instalación de Windows 11${NC} (si configuraste el ISO)
3. ${YELLOW}Instala VirtualBox Guest Additions${NC} desde el menú "Dispositivos"
4. ${YELLOW}Configura la carpeta compartida en Windows:${NC}
   - Abre el Explorador de Archivos
   - Ve a "Red" → "VBOXSVR"
   - Haz clic derecho en "trae-projects" → "Conectar unidad de red"
   - Selecciona letra de unidad: Z:

${BLUE}Para optimizar Windows 11:${NC}
- Ejecuta el script de optimización incluido:
  ${YELLOW}Copiar este comando en PowerShell (como administrador) en Windows:${NC}
  irm https://raw.githubusercontent.com/$GITHUB_USER/trae-ide-virtualbox-popos/main/scripts/optimize-windows.ps1 | iex

${BLUE}Mantente actualizado:${NC}
git pull origin main

${RED}¡IMPORTANTE!${NC} Crea un snapshot de la VM después de configurar todo:
- En VirtualBox Manager → Selecciona la VM → Snapshots
- Haz clic en "Tomar" (icono de cámara)
- Nombre: "Base-Optimized-TRAE"

${GREEN}¡Disfruta de TRAE IDE en tu Pop!_OS!${NC}
EOF
}

# Flujo principal
main() {
    echo -e "${GREEN}"
    echo "==============================================="
    echo " TRAE IDE VirtualBox Setup para Pop!_OS"
    echo " Versión 1.2.0 - Mantenido por infiniainnovation"
    echo "==============================================="
    echo -e "${NC}"
    
    check_prerequisites
    interactive_setup
    install_virtualbox
    create_vm
    setup_shared_folder
    create_start_script
    show_final_message
}

# Ejecutar
main
