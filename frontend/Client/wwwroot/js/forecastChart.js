window.drawForecastChart = function (labels, precipitation, temperatures, realFeelTemps) {
    if (!window.Chart) return;
    var canvas = document.getElementById('precipChart');
    if (!canvas) return;
    var ctx = canvas.getContext('2d');
    if (window.precipChartInstance) {
        window.precipChartInstance.destroy();
    }
    window.precipChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'Precipitación (mm)',
                    data: precipitation,
                    borderColor: 'rgba(54, 162, 235, 1)',      // Vibrant blue
                    backgroundColor: 'rgba(54, 162, 235, 0.3)', // Light blue fill
                    fill: true,
                    tension: 0.3,
                    yAxisID: 'y',
                },
                {
                    label: 'Temperatura (°C)',
                    data: temperatures,
                    borderColor: '#FF6B35',                     // Vibrant orange-red
                    backgroundColor: '#FF6B35',
                    fill: false,
                    tension: 0.3,
                    yAxisID: 'y1',
                    borderWidth: 3,                             // Thicker line
                },
                {
                    label: 'Sensación Térmica (°C)',
                    data: realFeelTemps,
                    borderColor: '#4ECDC4',                     // Turquoise/teal
                    backgroundColor: '#4ECDC4',
                    fill: false,
                    tension: 0.3,
                    yAxisID: 'y1',
                    borderDash: [8, 4],                         // More prominent dashed line
                    borderWidth: 2.5,                           // Slightly thicker
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false, 
            plugins: {
                legend: { display: true }
            },
            scales: {
                y: { beginAtZero: true, position: 'left', title: { display: true, text: 'Precipitación (mm)' } },
                y1: { beginAtZero: false, position: 'right', title: { display: true, text: 'Temperatura (°C)' }, grid: { drawOnChartArea: false } }
            }
        }
    });
}
