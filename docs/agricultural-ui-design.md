# 🌾 Agricultural Weather Index - UI Design Specification

## Overview
This document outlines the user interface design concept for the Climaguate Agricultural Weather Index feature, providing farmers and agricultural professionals with real-time crop condition assessments based on weather data.

## Visual Design Mockup

### Desktop Layout
```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🌱 ÍNDICE AGRÍCOLA - ANTIGUA GUATEMALA                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ 📍 Altiplano • 1,530m • Suelo Volcánico                                   │
│                                                                             │
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐               │
│ │ ☕ CAFÉ         │ │ 🥬 VEGETALES    │ │ 🥑 AGUACATE     │               │
│ │                 │ │                 │ │                 │               │
│ │      95%        │ │      85%        │ │      80%        │               │
│ │   EXCELENTE     │ │   MUY BUENO     │ │   BUENO         │               │
│ │                 │ │                 │ │                 │               │
│ │ 🟢 ÓPTIMO       │ │ 🟡 VIGILAR      │ │ 🟡 VIGILAR      │               │
│ │ Temp: 22°C      │ │ Temp: 18°C      │ │ Temp: 20°C      │               │
│ │ Humedad: 65%    │ │ Humedad: 70%    │ │ Humedad: 60%    │               │
│ └─────────────────┘ └─────────────────┘ └─────────────────┘               │
│                                                                             │
│ ⚠️  ALERTAS CLIMÁTICAS                                                     │
│ • Posible helada nocturna (15°C) - Proteger cultivos                      │
│ • Humedad alta (75%) - Riesgo de hongos en café                           │
│                                                                             │
│ 📅 RECOMENDACIONES ESTACIONALES                                           │
│ • PLANTACIÓN: Óptimo para siembra de café (Marzo-Abril)                   │
│ • COSECHA: Temporada de cosecha de café (Nov-Ene)                         │
│ • RIEGO: No necesario, humedad natural suficiente                         │
│                                                                             │
│ 📊 PRONÓSTICO 5 DÍAS                                                      │
│ Hoy   Mañana  Mier   Jue    Vie                                           │
│ 🟢    🟡     🟢    🟢     🟡                                               │
│ 95%   78%    92%   88%    75%                                             │
│                                                                             │
│ ⏰ Última actualización: Hace 15 minutos                                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Mobile Layout
```
Mobile View:
┌─────────────────────┐
│ 🌱 ÍNDICE AGRÍCOLA  │
│ Antigua Guatemala   │
├─────────────────────┤
│ ☕ CAFÉ       95%   │
│ 🟢 EXCELENTE        │
│ Temp: 22°C          │
├─────────────────────┤
│ 🥬 VEGETALES  85%   │
│ 🟡 MUY BUENO        │
│ Temp: 18°C          │
├─────────────────────┤
│ ⚠️ ALERTAS          │
│ • Helada nocturna   │
└─────────────────────┘
```

## Color-Coded System

### Suitability Score Colors
- 🟢 **Verde (90-100%)**: Condiciones excelentes para el cultivo
- 🟡 **Amarillo (70-89%)**: Buenas condiciones, monitorear de cerca
- 🟠 **Naranja (50-69%)**: Condiciones regulares, tomar precauciones
- 🔴 **Rojo (<50%)**: Condiciones desfavorables, acciones necesarias

### Status Indicators
- **EXCELENTE**: Condiciones óptimas, sin acciones requeridas
- **MUY BUENO**: Condiciones favorables, monitoreo rutinario
- **BUENO**: Condiciones aceptables, vigilancia recomendada
- **REGULAR**: Condiciones subóptimas, considerar medidas preventivas
- **DEFICIENTE**: Condiciones adversas, acciones inmediatas necesarias

## Component Structure

### 1. Main Container (`AgricultureIndex.razor`)
- Page title with city name
- Location context (elevation, soil type, climate zone)
- Grid layout for crop cards
- Alert section
- Recommendations section
- Forecast section
- Last update timestamp

### 2. Crop Card Component (`CropCard.razor`)
```razor
<div class="crop-card @GetStatusClass()">
    <div class="crop-header">
        <span class="crop-emoji">@CropEmoji</span>
        <span class="crop-name">@CropName</span>
    </div>
    <div class="suitability-score">@SuitabilityScore%</div>
    <div class="suitability-text">@GetSuitabilityText()</div>
    <div class="status-indicator">@GetStatusIndicator()</div>
    <div class="current-conditions">
        <div>Temp: @CurrentTemp°C</div>
        <div>Humedad: @CurrentHumidity%</div>
    </div>
</div>
```

### 3. Weather Alert Component (`WeatherAlert.razor`)
```razor
<div class="alert-section">
    <h4>⚠️ ALERTAS CLIMÁTICAS</h4>
    @foreach (var alert in WeatherAlerts)
    {
        <div class="alert-item @alert.Severity">
            • @alert.Message
        </div>
    }
</div>
```

### 4. Seasonal Advice Component (`SeasonalAdvice.razor`)
```razor
<div class="advice-section">
    <h4>📅 RECOMENDACIONES ESTACIONALES</h4>
    <div class="advice-item">
        • <strong>PLANTACIÓN:</strong> @PlantingAdvice
    </div>
    <div class="advice-item">
        • <strong>COSECHA:</strong> @HarvestAdvice
    </div>
    <div class="advice-item">
        • <strong>RIEGO:</strong> @IrrigationAdvice
    </div>
</div>
```

## Data Integration

### Required API Endpoints
1. `GET /api/agriculture/crops/{cityCode}` - Get crops for city
2. `GET /api/agriculture/conditions/{cityCode}` - Get current agricultural conditions
3. `GET /api/agriculture/alerts/{cityCode}` - Get weather alerts for agriculture
4. `GET /api/agriculture/forecast/{cityCode}` - Get agricultural forecast

### Sample Data Structure
```json
{
  "cityCode": "ANT",
  "cityName": "Antigua Guatemala",
  "elevation": 1530,
  "soilType": "Volcánico",
  "climateZone": "Altiplano",
  "crops": [
    {
      "cropCode": "COFFEE",
      "cropName": "Café",
      "emoji": "☕",
      "suitabilityScore": 95,
      "status": "EXCELENTE",
      "currentTemp": 22,
      "currentHumidity": 65,
      "optimalTempMin": 18,
      "optimalTempMax": 24
    }
  ],
  "alerts": [
    {
      "severity": "warning",
      "message": "Posible helada nocturna (15°C) - Proteger cultivos"
    }
  ],
  "recommendations": {
    "planting": "Óptimo para siembra de café (Marzo-Abril)",
    "harvest": "Temporada de cosecha de café (Nov-Ene)",
    "irrigation": "No necesario, humedad natural suficiente"
  },
  "forecast": [
    { "day": "Hoy", "score": 95, "status": "🟢" },
    { "day": "Mañana", "score": 78, "status": "🟡" }
  ]
}
```

## Key Features

### Real-time Updates
- Data refreshes every 15 minutes
- Live status indicators
- Push notifications for critical alerts

### Interactive Elements
- Clickable crop cards with detailed modals
- Expandable sections for detailed information
- Responsive design for mobile devices

### Export Functionality
- PDF reports for farmers
- WhatsApp/SMS alert integration
- Historical data comparison

### Navigation
- City selector dropdown
- Crop filter options
- Date range selector for historical data

## Implementation Priority

### Phase 1: Core Features
1. Basic crop card layout
2. Suitability score calculation
3. Simple alert system
4. Mobile-responsive design

### Phase 2: Enhanced Features
1. Interactive crop details
2. Seasonal recommendations
3. 5-day forecast integration
4. Alert customization

### Phase 3: Advanced Features
1. Historical comparison charts
2. Export functionality
3. Push notifications
4. Social sharing capabilities

## Technical Notes

### CSS Classes
```css
.crop-card { /* Card styling */ }
.crop-card.excellent { background: linear-gradient(135deg, #4CAF50, #81C784); }
.crop-card.very-good { background: linear-gradient(135deg, #FFC107, #FFD54F); }
.crop-card.good { background: linear-gradient(135deg, #FF9800, #FFB74D); }
.crop-card.poor { background: linear-gradient(135deg, #F44336, #E57373); }

.suitability-score { font-size: 2.5rem; font-weight: bold; }
.alert-section { border-left: 4px solid #FF9800; padding: 1rem; }
.forecast-bar { display: flex; gap: 1rem; }
```

### Performance Considerations
- Lazy loading for crop details
- Cached API responses (5-minute TTL)
- Optimized images and icons
- Progressive web app capabilities

---

*Created: August 22, 2025*  
*Status: Design Specification - Ready for Implementation*  
*Next Steps: Begin Blazor component development*
