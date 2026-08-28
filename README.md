# 💰 MoneyFlow

<p align="center">
  <img src="assets/images/icon.png" alt="MoneyFlow Logo" width="120" height="120">
</p>

<p align="center">
  <strong>Tu app financiera personal inteligente</strong>
</p>

<p align="center">
  Aplicación móvil para gestionar ingresos, gastos, presupuestos y visualizar el estado de tus finanzas personales.
</p>

<p align="center">
  <a href="#-características">Características</a> •
  <a href="#-tecnologías">Tecnologías</a> •
  <a href="#-instalación">Instalación</a> •
  <a href="#-estructura-del-proyecto">Estructura</a>
</p>

---

## 📱 Descripción

**MoneyFlow** es una aplicación móvil de finanzas personales desarrollada con **Flutter**. Su objetivo es facilitar el registro, organización y análisis de los movimientos financieros del usuario mediante una interfaz sencilla, moderna e intuitiva.

La aplicación permite administrar **ingresos, gastos, categorías y presupuestos**, además de proporcionar diferentes herramientas de visualización para comprender mejor el comportamiento de las finanzas personales.

### 🎯 Filosofía

> **"El control de tus finanzas comienza con conocer en qué gastas tu dinero."**

---

## ✨ Características

### 📊 Gestión financiera

* ✅ Registro de **ingresos y gastos**.
* ✅ Clasificación mediante **categorías personalizables**.
* ✅ Gestión de **presupuestos**.
* ✅ Seguimiento del progreso de los presupuestos.
* ✅ Visualización del **balance financiero**.
* ✅ Historial de movimientos financieros.
* ✅ Calendario para consultar movimientos por fecha.

### 📈 Análisis y estadísticas

* ✅ Gráficos interactivos.
* ✅ Gráficos de barras.
* ✅ Gráficos circulares.
* ✅ Evolución de ingresos y gastos.
* ✅ Comparación de movimientos financieros.
* ✅ Resúmenes periódicos de las finanzas.

### 📋 Gestión de datos

* ✅ Operaciones **CRUD** para transacciones.
* ✅ Operaciones **CRUD** para categorías.
* ✅ Búsqueda y filtrado de transacciones.
* ✅ Exportación de información financiera.
* ✅ Soporte para diferentes monedas.

### 🎨 Experiencia de usuario

* ✅ Interfaz moderna y adaptable.
* ✅ Tema **claro y oscuro**.
* ✅ Soporte **Español / Inglés**.
* ✅ Splash Screen.
* ✅ Onboarding para nuevos usuarios.
* ✅ Animaciones y transiciones.
* ✅ Diseño orientado a dispositivos móviles.

### 🔒 Privacidad

* ✅ Los datos financieros se almacenan **localmente**.
* ✅ Utiliza **SQLite** como sistema de almacenamiento.
* ✅ No requiere conexión permanente a Internet.
* ✅ Los datos financieros permanecen en el dispositivo del usuario.

---

## 🛠️ Tecnologías

| Tecnología             | Uso                                           |
| ---------------------- | --------------------------------------------- |
| **Flutter**            | Framework para el desarrollo de la aplicación |
| **Dart**               | Lenguaje de programación                      |
| **SQLite / sqflite**   | Almacenamiento local de datos                 |
| **GetX**               | Gestión de estado, dependencias y navegación  |
| **fl_chart**           | Creación de gráficos interactivos             |
| **table_calendar**     | Calendario financiero                         |
| **PDF**                | Generación de documentos                      |
| **CSV**                | Exportación de datos                          |
| **Shared Preferences** | Almacenamiento de preferencias locales        |
| **Font Awesome**       | Iconografía                                   |

---

## 📦 Instalación

### Requisitos previos

Antes de ejecutar MoneyFlow necesitas tener instalado:

* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* Dart SDK
* Android Studio o Visual Studio Code
* Android SDK
* Un dispositivo Android físico o un emulador

Puedes verificar la configuración de Flutter ejecutando:

```bash
flutter doctor
```

### Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/money_flow.git
cd money_flow
```

### Instalar dependencias

```bash
flutter pub get
```

### Ejecutar la aplicación

```bash
flutter run
```

También puedes especificar el dispositivo:

```bash
flutter devices
flutter run -d <device-id>
```

---

## ⚙️ Configuración

MoneyFlow utiliza almacenamiento local mediante SQLite, por lo que no requiere configurar una base de datos externa para comenzar a utilizar la aplicación.

Las preferencias del usuario se gestionan mediante almacenamiento local.

Si el proyecto incluye configuraciones adicionales para notificaciones, asegúrate de conceder los permisos correspondientes en el dispositivo.

---

## 🚀 Compilación para producción

### Android — APK

Para generar una versión de lanzamiento:

```bash
flutter build apk --release
```

Para generar APKs separados por arquitectura:

```bash
flutter build apk --split-per-abi --release
```

Los archivos generados estarán disponibles dentro de:

```text
build/app/outputs/flutter-apk/
```

### Android — App Bundle

Para generar un archivo `.aab`:

```bash
flutter build appbundle --release
```

El archivo se encontrará en:

```text
build/app/outputs/bundle/release/
```

### iOS

En macOS con Xcode configurado:

```bash
flutter build ios --release
```

---

## 📁 Estructura del proyecto

La aplicación utiliza una estructura organizada por responsabilidades para facilitar el mantenimiento y evolución del proyecto.

```text
money_flow/
│
├── android/
├── ios/
├── assets/
│   └── images/
│
├── lib/
│   ├── controllers/
│   │   └── # Controladores GetX
│   │
│   ├── database/
│   │   └── # Configuración y acceso a SQLite
│   │
│   ├── models/
│   │   └── # Modelos de datos
│   │
│   ├── services/
│   │   └── # Servicios de la aplicación
│   │
│   ├── theme/
│   │   └── # Temas y estilos
│   │
│   ├── utils/
│   │   └── # Utilidades y funciones auxiliares
│   │
│   └── views/
│       ├── screens/
│       │   └── # Pantallas principales
│       │
│       └── widgets/
│           └── # Widgets reutilizables
│
├── test/
│   └── # Pruebas
│
├── pubspec.yaml
├── README.md
└── LICENSE
```

---

## 🔄 Flujo general de la aplicación

El funcionamiento general de MoneyFlow puede representarse de la siguiente manera:

```text
                    ┌─────────────────┐
                    │    MoneyFlow    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Dashboard     │
                    └────────┬────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
            ▼                ▼                ▼
       ┌─────────┐      ┌──────────┐    ┌────────────┐
       │ Ingresos│      │  Gastos  │    │Presupuestos│
       └────┬────┘      └─────┬────┘    └──────┬─────┘
            │                 │                │
            └─────────────────┼────────────────┘
                              │
                              ▼
                       ┌─────────────┐
                       │   SQLite    │
                       │ Base local  │
                       └──────┬──────┘
                              │
                              ▼
                       ┌─────────────┐
                       │ Estadísticas│
                       │ y gráficos  │
                       └─────────────┘
```

---

## 🧪 Pruebas

Para ejecutar las pruebas del proyecto:

```bash
flutter test
```

Para analizar posibles problemas en el código:

```bash
flutter analyze
```

---

## 📄 Licencia

Este proyecto se distribuye bajo la licencia **MIT**.

Consulta el archivo [`LICENSE`](LICENSE) para conocer los términos completos de la licencia.

---

## 📧 Contacto

**Desarrollador:** Juan José Carmona Ortiz

**Proyecto:** MoneyFlow

Si tienes alguna sugerencia, encuentras un error o deseas comunicarte sobre el proyecto, puedes abrir un **Issue** en el repositorio.

---

## ⭐ Apoya el proyecto

Si MoneyFlow te resulta útil, considera darle una ⭐ al repositorio en GitHub.

---

<p align="center">
  Hecho con Flutter
</p>
