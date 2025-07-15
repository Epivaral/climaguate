window.drawForecastChart = function (labels, precipitation, minTemps, maxTemps) {
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
                    label: 'Temp. Mínima (°C)',
                    data: minTemps,
                    borderColor: 'skyblue',
                    backgroundColor: 'skyblue',
                    fill: false,
                    tension: 0.3,
                    yAxisID: 'y1',
                },
                {
                    label: 'Temp. Máxima (°C)',
                    data: maxTemps,
                    borderColor: '#FF4500',
                    backgroundColor: '#FF4500',
                    fill: false,
                    tension: 0.3,
                    yAxisID: 'y1',
                }
            ]
        },
        options: {
            responsive: true,
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
