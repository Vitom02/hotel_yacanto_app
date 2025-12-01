# Solución: App no disponible en mi región (Argentina)

## Problema
La aplicación muestra "no disponible en tu región" aunque fue publicada para Argentina, tanto en iOS como en Android.

## Causas Comunes

### 1. **Google Play Console - Modo de Prueba Activo**
Si la app está en modo de prueba (cerrada o abierta), solo está disponible para usuarios específicos, no para el público general.

### 2. **App Store Connect - Disponibilidad no configurada correctamente**
La app puede estar publicada pero sin Argentina seleccionada en la lista de países disponibles.

### 3. **Estado de la publicación**
La app puede estar en estado "En revisión" o "Borrador" y no estar completamente publicada.

---

## Solución para Android (Google Play Console)

### Paso 1: Verificar el estado de publicación
1. Ve a [Google Play Console](https://play.google.com/console)
2. Selecciona tu app "hotel_yacanto"
3. En el menú lateral, ve a **"Publicación"** → **"Producción"** (o "Open testing"/"Closed testing" si está en prueba)

### Paso 2: Verificar disponibilidad por país
1. En la misma página, busca la sección **"Países y regiones"** o **"Disponibilidad"**
2. Verifica que **Argentina** esté seleccionada
3. Si no está seleccionada:
   - Haz clic en **"Gestionar países"** o **"Editar"**
   - Selecciona **Argentina** en la lista
   - Guarda los cambios

### Paso 3: Verificar que NO esté en modo de prueba
1. Ve a **"Publicación"** → **"Open testing"** o **"Closed testing"**
2. Si hay una versión activa en prueba:
   - **Opción A**: Promueve la versión a Producción
     - Ve a la versión en prueba
     - Haz clic en **"Promover a producción"**
   - **Opción B**: Desactiva las pruebas
     - Desactiva o elimina las pruebas activas

### Paso 4: Verificar que la app esté publicada
1. En **"Publicación"** → **"Producción"**
2. Verifica que haya una versión activa con estado **"Publicada"** o **"Disponible"**
3. Si está en estado **"Borrador"** o **"En revisión"**:
   - Completa todos los requisitos pendientes
   - Envía la app para revisión si es necesario

### Paso 5: Verificar restricciones de contenido
1. Ve a **"Contenido"** → **"Clasificación de contenido"**
2. Verifica que no haya restricciones que bloqueen Argentina
3. Ve a **"Contenido"** → **"Restricciones de países"**
4. Asegúrate de que NO haya restricciones activas

### Paso 6: Esperar propagación (IMPORTANTE)
- Los cambios pueden tardar **24-48 horas** en propagarse
- Si acabas de hacer cambios, espera al menos 24 horas antes de probar nuevamente

---

## Solución para iOS (App Store Connect)

### Paso 1: Verificar disponibilidad por país
1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Selecciona tu app "Hotel Yacanto"
3. Ve a **"App Store"** → **"Disponibilidad"**
4. En la sección **"Países y regiones"**:
   - Verifica que **Argentina** esté en la lista de países seleccionados
   - Si no está:
     - Haz clic en **"Editar"** o **"Gestionar"**
     - Busca y selecciona **Argentina**
     - Guarda los cambios

### Paso 2: Verificar el estado de la versión
1. Ve a **"App Store"** → **"Versión de la app"**
2. Verifica que haya una versión con estado:
   - ✅ **"Lista para enviar"** (Ready to Submit)
   - ✅ **"En revisión"** (In Review)
   - ✅ **"Aprobada"** (Approved)
   - ✅ **"Disponible"** (Available)
3. Si está en estado **"Borrador"** o **"Rechazada"**:
   - Completa los requisitos pendientes
   - Envía la app para revisión

### Paso 3: Verificar distribución no listada (si aplica)
Si configuraste la app como "Distribución no listada":
1. Ve a **"App Store"** → **"Disponibilidad"**
2. Verifica que **Argentina** esté seleccionada en la lista de países
3. La distribución no listada NO afecta la disponibilidad por país, solo la visibilidad en búsquedas

### Paso 4: Verificar restricciones de edad/país
1. Ve a **"App Store"** → **"Información de la app"**
2. Verifica la clasificación por edades
3. Ve a **"App Store"** → **"Disponibilidad"**
4. Asegúrate de que no haya restricciones geográficas activas

### Paso 5: Esperar propagación (IMPORTANTE)
- Los cambios pueden tardar **24-48 horas** en propagarse
- Si acabas de hacer cambios, espera al menos 24 horas antes de probar nuevamente

---

## Verificación adicional

### Para Android:
1. **Prueba desde otro dispositivo**: Usa un dispositivo diferente o cuenta de Google diferente
2. **Verifica la URL directa**: Intenta acceder directamente con la URL de Google Play
3. **Limpia caché**: En el dispositivo, ve a Configuración → Apps → Google Play Store → Almacenamiento → Limpiar caché
4. **Verifica la cuenta**: Asegúrate de que tu cuenta de Google esté configurada para Argentina

### Para iOS:
1. **Prueba desde otro dispositivo**: Usa un dispositivo diferente o cuenta de Apple diferente
2. **Verifica la URL directo**: Intenta acceder directamente con la URL del App Store
3. **Verifica la región de la cuenta**: En Configuración → App Store → Verifica que tu cuenta esté configurada para Argentina
4. **Cierra sesión y vuelve a iniciar**: Cierra sesión en App Store y vuelve a iniciar sesión

---

## Checklist rápido

### Android (Google Play Console)
- [ ] La app está en **Producción** (no en Open/Closed testing)
- [ ] **Argentina** está seleccionada en "Países y regiones"
- [ ] El estado es **"Publicada"** o **"Disponible"**
- [ ] No hay restricciones de países activas
- [ ] Han pasado al menos 24 horas desde los cambios

### iOS (App Store Connect)
- [ ] **Argentina** está seleccionada en "Países y regiones"
- [ ] El estado de la versión es **"Aprobada"** o **"Disponible"**
- [ ] No hay restricciones geográficas activas
- [ ] Han pasado al menos 24 horas desde los cambios

---

## Si el problema persiste

### Para Android:
1. Ve a Google Play Console → **"Ayuda"** → **"Contactar con soporte"**
2. Explica que la app está configurada para Argentina pero aparece como no disponible
3. Proporciona:
   - ID de la app: `com.vistasouth.hotelyacanto`
   - País desde el que intentas acceder: Argentina
   - Captura de pantalla del error

### Para iOS:
1. Ve a App Store Connect → **"Ayuda"** → **"Contactar con soporte"**
2. Explica que la app está configurada para Argentina pero aparece como no disponible
3. Proporciona:
   - Bundle ID de la app
   - País desde el que intentas acceder: Argentina
   - Captura de pantalla del error

---

## Notas importantes

1. **Propagación**: Los cambios en disponibilidad pueden tardar hasta 48 horas en aplicarse completamente
2. **Caché**: Los dispositivos y las tiendas pueden tener información en caché, espera o limpia la caché
3. **Cuenta de desarrollador**: Asegúrate de que tu cuenta de desarrollador esté activa y en buen estado
4. **Pago de cuotas**: Verifica que no haya problemas con el pago de la cuota anual de desarrollador (iOS: $99 USD, Android: $25 USD una vez)

---

## Contacto de soporte

- **Google Play Console**: [Soporte de Google Play](https://support.google.com/googleplay/android-developer)
- **App Store Connect**: [Soporte de Apple Developer](https://developer.apple.com/support/)

