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
                    borderColor: 'rgba(30, 144, 255, 1)',
                    backgroundColor: 'rgba(30, 144, 255, 0.2)',
                    fill: true,
                    tension: 0.3,
                    yAxisID: 'y',
                },
                {
                    label: 'Temperatura (°C)',
                    data: temperatures,
                    borderColor: '#FF4500',
                    backgroundColor: '#FF4500',
                    fill: false,
                    tension: 0.3,
                    yAxisID: 'y1',
                },
                {
                    label: 'Sensación Térmica (°C)',
                    data: realFeelTemps,
                    borderColor: 'skyblue',
                    backgroundColor: 'skyblue',
                    fill: false,
                    tension: 0.3,
                    yAxisID: 'y1',
                    borderDash: [5, 5], // Dashed line to distinguish from actual temperature
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
