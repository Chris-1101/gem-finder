import Chart from 'chart.js/dist/Chart.js'

const ctx = document.getElementById("myChart").getContext('2d');
const crimeRate = document.getElementById("myChart").dataset.crimeRate
const myChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: ["Crime Rating in this postcode", "UK Average Crime Rating"],
        datasets: [{
            label: 'Crime rating',
            data: [crimeRate, 57.8],
            backgroundColor: [
                'rgba(0, 128, 128, 0.2)',
                'rgba(128, 0, 0, 0.2)',
            ],
            borderColor: [
                'rgba(0, 128, 128, 0.2)',
                'rgba(128, 0, 0, 0.2)'
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

const ctx2 = document.getElementById("myBarChart").getContext('2d');
const avgDataset = document.getElementById("myBarChart").dataset.avgCurrentFirst.split(',')
const myBarChart = new Chart(ctx2, {
    type: 'bar',
    data: {
        labels: ["Detached", "Semi-Detached", "Terraced", "Flats"],
        datasets: [{
            label: 'Average current value of properties',
            data: [avgDataset[0] * 1000 , avgDataset[2] * 1000, avgDataset[3] * 1000, avgDataset[1] * 1000],
            backgroundColor: [
                'rgba(255, 99, 132, 0.2)',
                'rgba(54, 162, 235, 0.2)',
                'rgba(255, 255, 0, 0.2)',
                'rgba(0, 255,0, 0.2)',
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
                    beginAtZero: true,
                    callback: (value) => {
                      return '£' + value
                    }
                },
            }]
        }
    }
});


new Chart(document.getElementById("lineGraph"), {
    type: 'line',
    data: {
      labels: ["Detached", "Semi-Detached", "Terraced", "Flats"],
      datasets: [{
        label: "Average Price Paid over 12 months",
        backgroundColor: ["transparent"],
        borderColor: 'rgba(0,0,0)',
        data: [avgDataset[0] * 1000 , avgDataset[2] * 1000, avgDataset[3] * 1000, avgDataset[1] * 1000]
      }]
    },
    options: {
      title: {
        display: true,
        text: 'Average Price Paid'
      }
    }
});




