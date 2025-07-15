window.drawForecastChart = function (labels, data) {
    if (!window.Chart) return;
    var ctx = document.getElementById('precipChart').getContext('2d');
    if (window.precipChartInstance) {
        window.precipChartInstance.destroy();
    }
    window.precipChartInstance = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Precipitación (mm)',
                data: data,
                borderColor: 'rgba(30, 144, 255, 1)',
                backgroundColor: 'rgba(30, 144, 255, 0.2)',
                fill: true,
                tension: 0.3
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: { display: true }
            },
            scales: {
                y: { beginAtZero: true }
            }
        }
    });
}
