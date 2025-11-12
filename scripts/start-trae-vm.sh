#!/bin/bash
# TRAE IDE VM Starter Script
# Mantenido por infiniainnovation
# Versión: 1.1.0

set -e

# Colores para salida
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Variables de configuración
VM_NAME="Trae-IDE-Windows"
SHARED_FOLDER="$HOME/trae-projects"
BOOT_WAIT_TIME=60  # segundos para esperar el boot de la VM

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
    echo -e "${RED}✗${NC} $1" >&2
    exit 1
}

# Verificar requisitos
check_requirements() {
    log "Verificando requisitos..."
    
    # Verificar si VirtualBox está instalado
    if ! command -v VBoxManage &> /dev/null; then
        error "VirtualBox no está instalado. Instálalo primero ejecutando: ./scripts/setup-virtualbox.sh"
    fi
    
    # Verificar si la VM existe
    if ! VBoxManage showvminfo "$VM_NAME" &> /dev/null; then
        error "La máquina virtual '$VM_NAME' no existe. Crea la VM primero usando el script de configuración."
    fi
    
    # Verificar si la carpeta compartida existe
    if [ ! -d "$SHARED_FOLDER" ]; then
        warning "La carpeta compartida '$SHARED_FOLDER' no existe. Creándola..."
        mkdir -p "$SHARED_FOLDER"
    fi
    
    success "Todos los requisitos verificados."
}

# Iniciar la VM
start_vm() {
    log "Iniciando máquina virtual '$VM_NAME'..."
    
    # Verificar si la VM ya está ejecutándose
    VM_STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)
    
    if [ "$VM_STATE" = "running" ]; then
        warning "La VM '$VM_NAME' ya está en ejecución."
    else
        # Iniciar la VM en modo GUI
        VBoxManage startvm "$VM_NAME" --type gui
        success "VM iniciada correctamente."
    fi
}

# Esperar a que la VM arranque
wait_for_boot() {
    log "Esperando $BOOT_WAIT_TIME segundos para que la VM arranque completamente..."
    for i in $(seq 1 $BOOT_WAIT_TIME); do
        echo -ne "${YELLOW}⏳${NC} $i/$BOOT_WAIT_TIME segundos\r"
        sleep 1
    done
    echo -ne "\n"
    success "Tiempo de espera completado."
}

# Abrir carpeta compartida
open_shared_folder() {
    log "Abriendo carpeta compartida en el editor preferido..."
    
    if command -v code &> /dev/null; then
        # Si VS Code está instalado
        code "$SHARED_FOLDER"
        success "Carpeta '$SHARED_FOLDER' abierta en VS Code."
    elif command -v subl &> /dev/null; then
        # Si Sublime Text está instalado
        subl "$SHARED_FOLDER"
        success "Carpeta '$SHARED_FOLDER' abierta en Sublime Text."
    elif command -v atom &> /dev/null; then
        # Si Atom está instalado
        atom "$SHARED_FOLDER"
        success "Carpeta '$SHARED_FOLDER' abierta en Atom."
    else
        # Abrir en el explorador de archivos por defecto
        if command -v xdg-open &> /dev/null; then
            xdg-open "$SHARED_FOLDER"
            warning "Ningún editor de código detectado. Carpeta abierta en el explorador de archivos."
        else
            warning "No se pudo abrir la carpeta compartida automáticamente."
            echo "Puedes acceder manualmente a: $SHARED_FOLDER"
        fi
    fi
}

# Mostrar instrucciones finales
show_instructions() {
    cat << EOF

${GREEN}🎉 ¡VM iniciada exitosamente!${NC}

${BLUE}Instrucciones para usar TRAE IDE:${NC}
1. ${YELLOW}Espera${NC} a que Windows 11 termine de arrancar (aproximadamente 1-2 minutos)
2. ${YELLOW}Inicia sesión${NC} en Windows con tus credenciales
3. ${YELLOW}Abre TRAE IDE${NC} desde el escritorio o el menú de inicio
4. ${YELLOW}Accede a tus proyectos${NC} en la unidad Z: (carpeta compartida)

${BLUE}Atajos de teclado útiles en VirtualBox:${NC}
- ${YELLOW}Host + C${NC}: Capturar/Desactivar el mouse y teclado en la VM
- ${YELLOW}Host + F${NC}: Modo pantalla completa
- ${YELLOW}Host + L${NC}: Modo ventana única ( seamless mode )
- ${YELLOW}Host + Del${NC}: Enviar Ctrl+Alt+Del a la VM

${BLUE}Para detener la VM:${NC}
- Cierra sesión en Windows y apaga la máquina desde el menú Inicio
- O usa: ${YELLOW}VBoxManage controlvm "$VM_NAME" acpipowerbutton${NC}

${GREEN}¡Disfruta desarrollando con TRAE IDE en tu Pop!_OS!${NC}
EOF
}

# Flujo principal
main() {
    echo -e "${GREEN}"
    echo "==============================================="
    echo " TRAE IDE VM Starter"
    echo " Versión 1.1.0 - Mantenido por infiniainnovation"
    echo "==============================================="
    echo -e "${NC}"
    
    check_requirements
    start_vm
    wait_for_boot
    open_shared_folder
    show_instructions
}

# Ejecutar el script
main
