@extends('admin.layouts.app')

@section('panel')
    <div class="row g-4">
        <div class="col-lg-6">
            <div class="card full-view">
                <div class="card-header">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                        <h5 class="card-title mb-0">@lang('Total Invests')</h5>
                        <div class="">
                            <button class="exit-btn d-sm-none d-md-block d-xl-none">
                                <i class="fullscreen-open las la-compress openFullscreen"></i>
                            </button>
                        </div>
                        <div>
                            <div class="d-flex justify-content-end gap-2 flex-wrap">
                                <div id="totalInvestPicker" class="border p-1 cursor-pointer rounded">
                                    <i class="la la-calendar"></i>&nbsp;
                                    <span></span> <i class="la la-caret-down"></i>
                                </div>
                                <button class="exit-btn d-none d-sm-block d-md-none d-xl-block">
                                    <i class="fullscreen-open las la-compress openFullscreen"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-body text-center pb-0 px-0">
                    <div class="px-3">
                        <div class="row align-items-center">
                            <div class="col-md-6">
                                <p>@lang('Invest for') <span class="time_type"></span></p>
                            </div>
                            <div class="col-md-6">
                                <h3 class="text-md-end"><span>{{ gs('cur_sym') }}</span><span class="total_invest"></span></h3>
                            </div>
                        </div>
                    </div>
                    <div class="my_invest_canvas"></div>
                </div>
            </div>
        </div>
        <div class="col-lg-6">
            <div class="card h-100">
                <div class="card-header">
                    <div class="d-flex justify-content-between align-items-center gap-2 flex-wrap">
                        <div>
                            <h5 class="card-title mb-0">@lang('Investment by Plan')</h5>
                        </div>
                        <div>
                            <div class="d-flex align-items-center flex-wrap gap-2">
                                <select name="plan_statistics_invests" class="widget_select">
                                    <option value="">@lang('All')</option>
                                    <option value="1">@lang('Running')</option>
                                    <option value="2">@lang('Completed')</option>
                                </select>
                                <div id="investmentPlanPicker" class="border p-1 cursor-pointer rounded">
                                    <i class="la la-calendar"></i>&nbsp;
                                    <span></span> <i class="la la-caret-down"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="chart-container">
                        <div class="chart-info">
                            <span class="chart-info-toggle">
                                <img src="{{ asset('assets/images/collapse.svg') }}" alt="image" class="chart-info-img">
                            </span>
                            <div class="chart-info-content">
                                <ul class="chart-info-list plan-info-data"></ul>
                            </div>
                        </div>
                        <div class="chart-area chart-area--fixed">
                            <div class="plan_invest_canvas"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <div class="row align-items-center g-2">
                        <div class="col-sm-6">
                            <h5 class="card-title mb-0">@lang('Latest 10 Pool Invest & Interest')</h5>
                        </div>
                        <div class="col-sm-6">
                            <div class="pair-option">
                                <select name="pull_status" class="widget_select">
                                    <option value="all">@lang('All')</option>
                                    <option value="dispatch">@lang('Dispatch')</option>
                                    <option value="no_dispatch">@lang('No Dispatch')</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <canvas id="poolChart"></canvas>

                </div>
            </div>
        </div>
    </div>
@endsection


@push('style-lib')
    <link rel="stylesheet" type="text/css" href="{{ asset('assets/admin/css/daterangepicker.css') }}">
@endpush

@push('script-lib')
    <script src="{{ asset('assets/global/js/chart.js.2.8.0.js') }}"></script>
    <script src="{{ asset('assets/admin/js/moment.min.js') }}"></script>
    <script src="{{ asset('assets/admin/js/daterangepicker.min.js') }}"></script>
@endpush


@push('script')
    <script>
        (function($) {
            "use strict";
            const firstInvestDate = moment("{{ $firstInvestDate }}", "YYYY-MM-DD HH:mm:ss");
            const lastInvestDate = moment("{{ $lastInvestDate }}", "YYYY-MM-DD HH:mm:ss");
            const start = moment().subtract(30, 'days');
            const end = moment();

            const dateRangeOptions = {
                startDate: start,
                endDate: end,
                ranges: {
                    'All': [firstInvestDate, lastInvestDate],
                    'Today': [moment(), moment()],
                    'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
                    'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                    'Last 15 Days': [moment().subtract(14, 'days'), moment()],
                    'Last 30 Days': [moment().subtract(30, 'days'), moment()],
                    'This Month': [moment().startOf('month'), moment().endOf('month')],
                    'Last 6 Months': [moment().subtract(6, 'months').startOf('month'), moment().endOf('month')],
                    'This Year': [moment().startOf('year'), moment().endOf('year')],
                },
                maxDate: moment()
            }

            const changeDatePickerText = (element, startDate, endDate) => {
                $(element).html(startDate.format('MMMM D, YYYY') + ' - ' + endDate.format('MMMM D, YYYY'));
            }


            // invest
            const totalInvest = (startDate, endDate) => {
                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD'),
                }

                let time = $('#totalInvestPicker span').text();
                var url = "{{ route('admin.pool.invest.statistics') }}";

                $.get(url, {
                    start_date: data.start_date,
                    end_date: data.end_date,
                }, function(response) {
                    $('.time_type').text(time);
                    $('.total_invest').text(response.total_invest.toFixed(2));
                    $('.my_invest_canvas').html(
                        '<canvas height="150" id="invest_chart" class="chartjs-chart mt-4"></canvas>'
                    )
                    var ctx = document.getElementById('invest_chart');
                    var myChart = new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: Object.keys(response.invests),
                            datasets: [{
                                data: Object.values(response.invests),
                                backgroundColor: [
                                    @for ($i = 0; $i < 365; $i++)
                                        '#6c5ce7',
                                    @endfor
                                ],
                                borderColor: [
                                    'rgba(231, 80, 90, 0.75)'
                                ],
                                borderWidth: 0,
                            }]
                        },
                        options: {
                            aspectRatio: 1,
                            responsive: true,
                            maintainAspectRatio: true,
                            elements: {
                                line: {
                                    tension: 0
                                }
                            },
                            scales: {
                                xAxes: [{
                                    display: false
                                }],
                                yAxes: [{
                                    ticks: {
                                        suggestedMin: 0,
                                    },
                                    display: false
                                }]
                            },
                            legend: {
                                display: false,
                            },
                            tooltips: {
                                callbacks: {
                                    label: (tooltipItem, data) => data.datasets[0].data[
                                        tooltipItem.index] + ' {{ gs('cur_text') }}'
                                }
                            }
                        }
                    });
                });
            }

            $('#totalInvestPicker').daterangepicker(dateRangeOptions, (start, end) => changeDatePickerText('#totalInvestPicker span', start, end));
            $('#totalInvestPicker').on('apply.daterangepicker', (event, picker) => totalInvest(picker.startDate, picker.endDate));

            changeDatePickerText('#totalInvestPicker span', start, end);
            totalInvest(start, end)


            // Investment by Plan
            const investPlan = (startDate, endDate) => {
                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD')
                }
                let investType = $('[name=plan_statistics_invests]').val();
                var url = "{{ route('admin.pool.invest.plan') }}";

                $.get(url, {
                    start_date: data.start_date,
                    end_date: data.end_date,
                    invest_type: investType,
                }, function(response) {
                    $('.plan_invest_canvas').html(
                        '<canvas height="250" id="plan_invest_statistics"></canvas>');
                    let invests = response.invest_data;
                    let planInfo = '';
                    let investAmount = [];
                    let planName = [];
                    let poolInvestUrl = "{{ route('admin.pool.invest') }}";
                    let searchByDate = "date=" + $('#investmentPlanPicker span').text();

                    $.each(invests, function(key, invest) {
                        let investPercent = (invest.investAmount / response.total_invest) * 100;
                        investAmount.push(parseFloat(invest.investAmount).toFixed(2));
                        planName.push(invest.pool.name);
                        planInfo +=
                            `<li class="chart-info-list-item"><i class="fas fa-plane planPoint me-2"></i>${investPercent.toFixed(2)}% - ${invest.pool.name} Days <a class="ms-1" href="${poolInvestUrl}?pool_id=${invest.pool_id}&${searchByDate}&status=${investType}"><i class="las la-info-circle"></i></a></li>`
                    });
                    $('.plan-info-data').html(planInfo);

                    var pieChartID = document.getElementById("plan_invest_statistics").getContext('2d');
                    var pieChart = new Chart(pieChartID, {
                        type: 'pie',
                        data: {
                            datasets: [{
                                data: investAmount,
                                borderColor: 'transparent',
                                backgroundColor: planColors()
                            }]
                        },
                        options: {
                            responsive: true,
                            legend: {
                                display: false
                            },
                            tooltips: {
                                callbacks: {
                                    label: (tooltipItem, data) => data.datasets[0].data[
                                        tooltipItem.index] + ' {{ gs('cur_text') }}'
                                }
                            }
                        }
                    });

                    var planPoints = $('.planPoint');
                    planPoints.each(function(key, planPoint) {
                        var planPoint = $(planPoint)
                        planPoint.css('color', planColors()[key])
                    })
                });
            }
            $('#investmentPlanPicker').daterangepicker(dateRangeOptions, (start, end) => changeDatePickerText('#investmentPlanPicker span', start, end));
            $('#investmentPlanPicker').on('apply.daterangepicker', (event, picker) => investPlan(picker.startDate, picker.endDate));
            changeDatePickerText('#investmentPlanPicker span', start, end);
            investPlan(start, end)

            // invest & interest



            const poolChart = document.getElementById("poolChart").getContext("2d");
            let poolChartInstance = new Chart(poolChart, {
                type: "bar",
                data: {
                    labels: [],
                    datasets: [{
                            label: "Invest",
                            data: [],
                            borderColor: "rgba(40, 199, 111, 1)",
                            backgroundColor: "rgba(40, 199, 111, 1)",
                        },
                        {
                            label: "Interest",
                            data: [],
                            borderColor: "rgba(255, 99, 132, 0.5)",
                            backgroundColor: "rgba(255, 99, 132, 0.5)",
                        }
                    ]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: "top",
                        },
                        title: {
                            display: true,
                            text: "Chart.js Bar Chart",
                        }
                    },

                    tooltips: {
                        callbacks: {
                            label: (tooltipItem, data) => data.datasets[0].data[
                                tooltipItem.index] + ' {{ gs('cur_text') }}'
                        }
                    },
                    scales: {
                        y: {
                            min: 0, // Prevents negative values
                        }
                    }
                }
            });


            $('[name=pull_status]').on('change', function() {
                let pullStatus = $('[name=pull_status]').val();
                let url = "{{ route('admin.pool.invest.interest.chart') }}";
                $.get(url, {
                    pull_status: pullStatus
                }, function(response) {
                    poolChartInstance.data.labels = response.keys;
                    poolChartInstance.data.datasets[0].data = response.invests; // Invest dataset
                    poolChartInstance.data.datasets[1].data = response.interests; // Interest dataset
                    poolChartInstance.update();
                });
            }).change();


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


            $(document).on('click', '.chart-info-toggle', function() {
                let content = $(this).siblings().first().toggleClass('is-open');
            });

            $(document).on('click', '.openFullscreen', function() {
                let fullView = $(this).closest('.full-view');

                if (!document.fullscreenElement) {
                    fullView.find('.cursor-pointer').addClass('d-none');
                    fullView[0].requestFullscreen();
                } else {
                    document.exitFullscreen();
                    fullView.find('.cursor-pointer').removeClass('d-none');
                }
            });

            $(document).on('fullscreenchange', function() {
                if (!document.fullscreenElement) {
                    $('.full-view .cursor-pointer').removeClass('d-none');
                }
            });

        })(jQuery);
    </script>
@endpush


@push('style')
    <style>
        select {
            font-size: 14px !important;
            height: 34px !important;
            padding: 5px 0px !important;
            border-color: var(--bs-border-color) !important;
        }
    </style>
@endpush
