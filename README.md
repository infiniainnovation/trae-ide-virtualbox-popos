# 🖥️ TRAE IDE en VirtualBox para Pop!_OS

<p align="center">
  <img src="https://img.shields.io/badge/Pop!_OS-48B9C7?logo=popos&logoColor=white" alt="Pop!_OS"/>
  <img src="https://img.shields.io/badge/VirtualBox-272D33?logo=virtualbox&logoColor=white" alt="VirtualBox"/>
  <img src="https://img.shields.io/badge/Windows_11-0078D6?logo=windows&logoColor=white" alt="Windows 11"/>
  <img src="https://img.shields.io/badge/TRAE_AI-FF4500?logo=artificial-intelligence&logoColor=white" alt="TRAE AI"/>
  <a href="https://github.com/infiniainnovation/trae-ide-virtualbox-popos/actions/workflows/ci.yml">
    <img src="https://github.com/infiniainnovation/trae-ide-virtualbox-popos/actions/workflows/ci.yml/badge.svg" alt="CI/CD"/>
  </a>
</p>

<p align="center">
  <b>Guía definitiva para ejecutar TRAE IDE en Linux sin dual-boot</b><br>
  <i>Una solución profesional para desarrolladores que necesitan herramientas Windows en un entorno Linux nativo</i>
</p>

<p align="center">
  <a href="#-características">características</a> •
  <a href="#%EF%B8%8F-prerrequisitos">prerrequisitos</a> •
  <a href="#-instalación-rápida">instalación rápida</a> •
  <a href="#-rendimiento-esperado">rendimiento</a> •
  <a href="#-solución-de-problemas">troubleshooting</a> •
  <a href="#-licencia">licencia</a>
</p>

![TRAE IDE en VirtualBox](screenshots/trae-performance.png)

## 🌟 Características

✅ **Rendimiento optimizado** - Configuración específica para máximo rendimiento en VM  
✅ **Integración perfecta** - Carpetas compartidas, port forwarding y SSH integrado  
✅ **Sin bloatware** - Windows 11 limpio y optimizado para desarrollo  
✅ **Flujo de trabajo profesional** - Scripts automatizados para inicio rápido  
✅ **Seguridad reforzada** - Desactivación de telemetry y servicios innecesarios  
✅ **Backup automático** - Sistema de snapshots para recuperación instantánea  

## ⚙️ Prerrequisitos

Antes de comenzar, asegúrate de tener:

- **Hardware mínimo**:
  - 🧠 Procesador: 6+ cores físicos (Intel VT-x/AMD-V habilitado en BIOS)
  - 💾 RAM: 16GB+ (8GB para la VM, 8GB para el host)
  - 💿 Almacenamiento: 100GB+ de espacio en SSD (HDD tradicional no recomendado)
  - 🖥️ Tarjeta gráfica: Soporte para virtualización de GPU

- **Software**:
  - Pop!_OS 22.04 LTS o superior
  - VirtualBox 7.0+ (se instalará mediante el script)
  - ISO de Windows 11 (versión de evaluación de 90 días disponible en [Microsoft Evaluation Center](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/))

## 🚀 Instalación Rápida

### 1. Clona este repositorio
```bash
git clone https://github.com/infiniainnovation/trae-ide-virtualbox-popos.git
cd trae-ide-virtualbox-popos
