import Chart from 'chart.js/dist/Chart.js'

const ctx = document.getElementById("myChart").getContext('2d');
const crimeRate = document.getElementById("myChart").dataset.crimeRate
const myChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: ["Crime Rate", " ", " ", " "],
        datasets: [{
            label: 'Crime rating',
            data: [crimeRate],
            backgroundColor: [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)'
            ],
            borderColor: [
                'rgba(255,99,132,1)',
                'rgba(54, 162, 235, 1)'
            ],
            borderWidth: 1
        }]
    },
    options: {
        scales: {
            yAxes: [{
                ticks: {
                    beginAtZero:true
                }
            }]
        }
    }
});
