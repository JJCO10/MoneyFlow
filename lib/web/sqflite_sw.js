// Service Worker para sqflite en web
// Este worker permite que SQLite funcione en el navegador
// usando WebAssembly

importScripts('https://cdn.jsdelivr.net/npm/sql.js@1.8.0/dist/sql-wasm.js');

// Configurar la base de datos en memoria
var db = null;

self.addEventListener('message', function(e) {
  const data = e.data;
  
  switch (data.action) {
    case 'open':
      // Abrir base de datos
      if (data.dbName) {
        db = new SQL.Database();
        self.postMessage({
          id: data.id,
          result: { success: true }
        });
      }
      break;
      
    case 'exec':
      // Ejecutar consulta SQL
      if (db) {
        try {
          const result = db.exec(data.sql);
          self.postMessage({
            id: data.id,
            result: result
          });
        } catch (error) {
          self.postMessage({
            id: data.id,
            error: error.message
          });
        }
      }
      break;
      
    default:
      self.postMessage({
        id: data.id,
        error: 'Unknown action: ' + data.action
      });
  }
});

// Inicializar
console.log('✅ sqflite worker inicializado');