<div class="chart-container">
    <div class="chart-info">
        <span class="chart-info-toggle">
            <img src="{{ asset('assets/images/collapse.svg') }}" alt="image" class="chart-info-img">
        </span>
        @php
            $dayContent = trans('Day -');
        @endphp
        <div class="chart-info-content">
            <ul class="chart-info-list">
                @foreach ($interestByPlans as $key => $invest)
                    <li class="chart-info-list-item">
                        <i class="fas fa-plane planPointColor me-2"></i>{{ __($key) }} {{ $day ? $dayContent : '' }}
                        {{ showAmount(($invest / $totalInterest) * 100, currencyFormat: false) }}%
                    </li>
                @endforeach
            </ul>
        </div>
    </div>
    <div class="chart-area">
        <canvas id="interest_by_plan" height="250" class="chartjs-chart"></canvas>
    </div>
</div>

<script>
    (function($) {
        "use strict";
        var doughnutChartID = document.getElementById("interest_by_plan").getContext('2d');
        var doughnutChart = new Chart(doughnutChartID, {
            type: 'doughnut',
            data: {
                datasets: [{
                    data: @json($interestByPlans->values()),
                    borderColor: 'transparent',
                    backgroundColor: planColors(),
                }],
            },
            options: {
                responsive: true,
                cutoutPercentage: 75,
                legend: {
                    position: 'bottom'
                },
                title: {
                    display: false,
                    text: 'Chart.js Doughnut Chart'
                },
                animation: {
                    animateScale: true,
                    animateRotate: true
                },
                tooltips: {
                    callbacks: {
                        label: (tooltipItem, data) => data.datasets[0].data[tooltipItem.index] +
                            ' {{ gs('cur_text') }}'
                    }
                }
            }
        });

        var planPointInterests = $(document).find('.planPointColor');
        planPointInterests.each(function(key, planPointInterest) {
            var planPointInterest = $(planPointInterest)
            planPointInterest.css('color', planColors()[key])
        })

        function planColors() {
            return [
                '#ff7675',
                '#6c5ce7',
                '#ffa62b',
                '#ffeaa7',
                '#D980FA',
                '#fccbcb',
                '#45aaf2',
                '#05dfd7',
                '#FF00F6',
                '#1e90ff',
                '#2ed573',
                '#eccc68',
                '#ff5200',
                '#cd84f1',
                '#7efff5',
                '#7158e2',
                '#fff200',
                '#ff9ff3',
                '#08ffc8',
                '#3742fa',
                '#1089ff',
                '#70FF61',
                '#bf9fee',
                '#574b90'
            ]
        }
    })(jQuery);
</script>
