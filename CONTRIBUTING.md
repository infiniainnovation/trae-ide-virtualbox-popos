# Contribuyendo a TRAE IDE en VirtualBox para Pop!_OS

¡Gracias por tu interés en contribuir a este proyecto! Cualquier contribución es bienvenida, ya sea reportando bugs, sugiriendo mejoras o enviando pull requests.

## 🤝 Cómo Contribuir

### Reportando Bugs
- Abre un [issue](https://github.com/infiniainnovation/trae-ide-virtualbox-popos/issues) con:
  - Descripción clara del problema
  - Pasos para reproducir el error
  - Versión de Pop!_OS, VirtualBox y Windows 11
  - Capturas de pantalla si es posible

### Sugiriendo Mejoras
- Propón nuevas características o mejoras existentes mediante un [issue](https://github.com/infiniainnovation/trae-ide-virtualbox-popos/issues)
- Sé específico sobre cómo la mejora beneficiaría a los usuarios
- Incluye ejemplos o bocetos si es relevante

### Enviando Pull Requests
1. Haz un fork del repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nombre-feature`)
3. Realiza tus cambios
4. Asegúrate de que no rompes nada existente
5. Escribe pruebas si es necesario
6. Documenta tus cambios en el README si es necesario
7. Haz commit de tus cambios (`git commit -am 'Añade nueva característica'`)
8. Sube tu rama (`git push origin feature/nombre-feature`)
9. Abre un Pull Request

## 📝 Estándares de Código

### Scripts de Bash
- Usar `set -e` para salir en caso de error
- Incluir comentarios explicativos
- Seguir las convenciones de estilo:
  - Variables en mayúsculas (`VARIABLE_NAME`)
  - Funciones en minúsculas con guiones bajos (`function_name`)
  - Sangría de 4 espacios
- Manejar errores adecuadamente

### Scripts de PowerShell
- Usar `Write-Host` con colores para mensajes importantes
- Incluir verificación de permisos de administrador
- Manejar excepciones con try/catch
- Seguir las convenciones de la comunidad PowerShell

### Documentación
- Usar Markdown con formato consistente
- Incluir capturas de pantalla para configuraciones complejas
- Mantener los ejemplos actualizados
- Usar emojis para mejorar la legibilidad

## 🧪 Pruebas

Antes de enviar un PR, por favor verifica que:
- Los scripts funcionan en una instalación limpia de Pop!_OS
- La documentación es clara y precisa
- No hay errores de sintaxis
- Los enlaces externos están actualizados

## 📜 Licencia

Al contribuir a este proyecto, aceptas que tus contribuciones estén bajo la [licencia MIT](LICENSE) del proyecto.

## 🙏 Agradecimientos

¡Gracias por contribuir a este proyecto! Tu ayuda hace que este recurso sea más valioso para la comunidad de desarrolladores.
