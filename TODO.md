# 📝 LoL Picker – TODO

## 🔥 High Priority (Core)
- [x] Finalizar flujo de login del usuario
- [x] Validar región / nombre / extensión
- [ ] Manejar errores de la Riot API correctamente
- [x] Evitar llamadas duplicadas a la API
- [ ] Cachear respuestas (DataDragon / campeones)

---

## 👤 User Model
- [x] Crear clase User
- [x] Guardar puuid correctamente
- [x] Almacenar champion_pool
- [x] Almacenar ranked_tiers
- [ ] Añadir método `__str__` al usuario
- [ ] Añadir método `is_logged()`

---

## 🏆 Champion Mastery
- [x] Obtener campeones más jugados
- [x] Mapear championId → DataDragon
- [x] Ordenar campeones por mastery_points
- [ ] Limitar top N campeones
- [ ] Mostrar splash art (opcional futuro)

---

## 📊 Ranked Stats
- [x] Obtener SoloQ
- [x] Obtener FlexQ
- [x] Crear clase RankedTier
- [ ] Colorear tiers (Bronze / Silver / Gold…)
- [ ] Añadir iconos por tier
- [ ] Calcular winrate global

---

## 🎨 UI (Rich)
- [x] Menú principal
- [x] Menú de campeones más jugados
- [x] Menú de estadísticas ranked
- [ ] Animaciones (loading spinner)
- [ ] Mejorar espaciado y alineado
- [ ] Tema visual consistente

---

## 🌐 API & Networking
- [x] Centralizar llamadas HTTP
- [x] Manejar status codes
- [ ] Retry automático en 429 (rate limit)
- [ ] Timeout configurable
- [ ] Logging de errores

---

## 🔐 Seguridad
- [x] Usar .env para API_KEY
- [ ] Validar API_KEY al inicio
- [ ] Ocultar datos sensibles en logs

---

## 🧪 Testing (opcional pero recomendable)
- [ ] Test de parsing de API responses
- [ ] Test de User
- [ ] Test de RankedTier
- [ ] Mockear llamadas HTTP

---

## 🚀 Extras / Ideas
- [ ] Guardar datos en JSON local
- [ ] Comparar dos usuarios
- [ ] Exportar stats a CSV
- [ ] Modo offline
- [ ] Añadir en el menú global si está 
      el usuario en partida
- [ ] Añadir script de "autopicker"