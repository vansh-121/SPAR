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
                                <p>@lang('Invest for ')<span class="time_type"></span></p>
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
            <div class="card full-view">
                <div class="card-header">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                        <h5 class="card-title mb-0">@lang('Total Interest')</h5>
                        <div class="">
                            <button class="exit-btn d-sm-none d-md-block d-xl-none">
                                <i class="fullscreen-open las la-compress openFullscreen"></i>
                                <i class="fullscreen-close las la-compress-arrows-alt closeFullscreen"></i>
                            </button>
                        </div>
                        <div>
                            <div class="d-flex justify-content-end gap-2 flex-wrap">
                                <div id="totalInterestPicker" class="border p-1 cursor-pointer rounded">
                                    <i class="la la-calendar"></i>&nbsp;
                                    <span></span> <i class="la la-caret-down"></i>
                                </div>
                                <button class="exit-btn d-none d-sm-block d-md-none d-xl-block">
                                    <i class="fullscreen-open las la-compress openFullscreen"></i>
                                    <i class="fullscreen-close las la-compress-arrows-alt closeFullscreen"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card-body text-center pb-0 px-0">
                    <div class="px-3">
                        <div class="row align-items-center">
                            <div class="col-md-6">
                                <p>@lang('Interest for ')<span class="interest_time_type"></span></p>
                            </div>
                            <div class="col-md-6">
                                <h3 class="text-md-end"><span>{{ gs('cur_sym') }}</span><span class="total_interest"></span></h3>
                            </div>
                        </div>
                    </div>
                    <div class="my_interest_canvas"></div>
                </div>
            </div>
        </div>
        <div class="col-lg-6">
            <div class="card">
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
        <div class="col-lg-6">
            <div class="card h-100">
                <div class="card-header">
                    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                        <h5 class="card-title mb-0">@lang('Interest by Plan')</h5>
                        <div id="investInterestStatisticsPicker" class="border p-1 cursor-pointer rounded">
                            <i class="la la-calendar"></i>&nbsp;
                            <span></span> <i class="la la-caret-down"></i>
                        </div>
                    </div>
                </div>
                <div class="card-body invest-interest-statistics">
                </div>
            </div>
        </div>
        <div class="col-12">
            <div class="card h-100">
                <div class="card-header">
                    <div class="row align-items-center g-2">
                        <div class="col-sm-6">
                            <h5 class="card-title mb-0">@lang('Invest & Interest')</h5>
                        </div>
                        @if (@$firstInvestYear)
                            <div class="col-sm-6">
                                <div class="pair-option">
                                    <select name="invest_interest_year" class="widget_select">
                                        @for ($i = $firstInvestYear; $i <= date('Y'); $i++)
                                            <option value="{{ $i }}" @if (date('Y') == $i) selected @endif>
                                                {{ $i }}
                                            </option>
                                        @endfor
                                    </select>
                                    <select name="invest_interest_month" class="widget_select">
                                        <option value="01" @if (date('m') == '01') selected @endif>
                                            @lang('January')</option>
                                        <option value="02" @if (date('m') == '02') selected @endif>
                                            @lang('February')</option>
                                        <option value="03" @if (date('m') == '03') selected @endif>
                                            @lang('March')</option>
                                        <option value="04" @if (date('m') == '04') selected @endif>
                                            @lang('April')</option>
                                        <option value="05" @if (date('m') == '05') selected @endif>
                                            @lang('May')</option>
                                        <option value="06" @if (date('m') == '06') selected @endif>
                                            @lang('June')</option>
                                        <option value="07" @if (date('m') == '07') selected @endif>
                                            @lang('July')</option>
                                        <option value="08" @if (date('m') == '08') selected @endif>
                                            @lang('August')</option>
                                        <option value="09" @if (date('m') == '09') selected @endif>
                                            @lang('September')</option>
                                        <option value="10" @if (date('m') == '10') selected @endif>
                                            @lang('October')</option>
                                        <option value="11" @if (date('m') == '11') selected @endif>
                                            @lang('November')</option>
                                        <option value="12" @if (date('m') == '12') selected @endif>
                                            @lang('December')</option>
                                    </select>
                                </div>
                            </div>
                        @endif
                    </div>
                </div>
                <div class="card-body">
                    <canvas height="80" id="chartjs-boundary-area-chart" class="chartjs-chart"></canvas>
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
                var url = "{{ route('admin.staking.invest.statistics') }}";

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
                                    tension: 0 // disables bezier curves
                                }
                            },
                            scales: {
                                xAxes: [{
                                    display: false
                                }],
                                yAxes: [{
                                    ticks: {
                                        suggestedMin: 0, // Set a minimum value
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
            $('#totalInvestPicker').on('apply.daterangepicker', (event, picker) => totalInvest(picker.startDate, picker.endDate, picker.chosenLabel));

            changeDatePickerText('#totalInvestPicker span', start, end);
            totalInvest(start, end)



            // interest
            const totalInterest = (startDate, endDate) => {
                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD'),
                }

                let time = $('#totalInterestPicker span').text();
                var url = "{{ route('admin.staking.interest.statistics') }}";

                $.get(url, {
                    start_date: data.start_date,
                    end_date: data.end_date,
                }, function(response) {
                    $('.interest_time_type').text(time);
                    $('.total_interest').text(response.total_interest.toFixed(2));
                    $('.my_interest_canvas').html(
                        '<canvas height="150" id="interest_chart" class="chartjs-chart mt-4"></canvas>'
                    )
                    var ctx = document.getElementById('interest_chart');
                    var myChart = new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: Object.keys(response.interests),
                            datasets: [{
                                data: Object.values(response.interests),
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
                                    tension: 0 // disables bezier curves
                                }
                            },
                            scales: {
                                xAxes: [{
                                    display: false
                                }],
                                yAxes: [{
                                    ticks: {
                                        suggestedMin: 0, // Set a minimum value
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

            $('#totalInterestPicker').daterangepicker(dateRangeOptions, (start, end) => changeDatePickerText('#totalInterestPicker span', start, end));
            $('#totalInterestPicker').on('apply.daterangepicker', (event, picker) => totalInterest(picker.startDate, picker.endDate, picker.chosenLabel));

            changeDatePickerText('#totalInterestPicker span', start, end);
            totalInterest(start, end)



            // Investment by Plan
            const investPlan = (startDate, endDate) => {
                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD')
                }
                let investType = $('[name=plan_statistics_invests]').val();
                var url = "{{ route('admin.staking.invest.plan') }}";

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
                    let stakingInvestUrl = "{{ route('admin.staking.invest') }}";
                    let searchByDate = "date=" + $('#investmentPlanPicker span').text();

                    $.each(invests, function(key, invest) {
                        let investPercent = (invest.investAmount / response.total_invest) * 100;
                        investAmount.push(parseFloat(invest.investAmount).toFixed(2));
                        planName.push(invest.staking.days);
                        planInfo +=
                            `<li class="chart-info-list-item"><i class="fas fa-plane planPoint me-2"></i>${investPercent.toFixed(2)}% - ${invest.staking.days} Days <a class="ms-1" href="${stakingInvestUrl}?staking_id=${invest.staking_id}&${searchByDate}&status=${investType}"><i class="las la-info-circle"></i></a></li>`
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


            // Interest by Plan
            const investInterestStatistics = (startDate, endDate) => {
                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD')
                }
                var url = "{{ route('admin.staking.interest.plan') }}";
                $.get(url, {
                    start_date: data.start_date,
                    end_date: data.end_date,
                }, function(response) {
                    $('.invest-interest-statistics').html(response.html);
                    planColors();
                });
            }
            $('#investInterestStatisticsPicker').daterangepicker(dateRangeOptions, (start, end) => changeDatePickerText('#investInterestStatisticsPicker span', start, end));
            $('#investInterestStatisticsPicker').on('apply.daterangepicker', (event, picker) => investInterestStatistics(picker.startDate, picker.endDate));
            changeDatePickerText('#investInterestStatisticsPicker span', start, end);
            investInterestStatistics(start, end)


            // invest & interest

            $('[name=plan_statistics_invests]').on('change', function() {
                $('[name=plan_statistics_time]').trigger('change');
                let picker = $('#investmentPlanPicker').data('daterangepicker');
                $('#investmentPlanPicker').trigger('apply.daterangepicker', [picker, picker.startDate, picker.endDate]);
            });

            $('[name=invest_interest_year]').on('change', function() {
                let year = $('[name=invest_interest_year]').val();
                let month = $('[name=invest_interest_month]').val();
                let url = "{{ route('admin.staking.interest.chart') }}";
                $.get(url, {
                    year: year,
                    month: month
                }, function(response) {
                    var boundaryAreaID = document.getElementById("chartjs-boundary-area-chart")
                        .getContext('2d');
                    var boundaryArea = new Chart(boundaryAreaID, {
                        type: 'line',
                        data: {
                            labels: response.keys,
                            datasets: [{
                                    backgroundColor: ["rgba(110, 129, 220,0.2)"],
                                    borderColor: ["#6e81dc"],
                                    pointBorderColor: ["#6e81dc", "#6e81dc", "#6e81dc",
                                        "#6e81dc", "#6e81dc", "#6e81dc", "#6e81dc"
                                    ],
                                    pointBackgroundColor: ["#6e81dc", "#6e81dc", "#6e81dc",
                                        "#6e81dc", "#6e81dc", "#6e81dc", "#6e81dc"
                                    ],
                                    pointBorderWidth: 0,
                                    data: response.invests,
                                    label: 'Invests',
                                    fill: 'start'
                                },
                                {
                                    backgroundColor: ["rgba(252, 193, 0,0.2)"],
                                    borderColor: ["#fcc100"],
                                    pointBorderColor: ["#fcc100", "#fcc100", "#fcc100",
                                        "#fcc100", "#fcc100", "#fcc100", "#fcc100"
                                    ],
                                    pointBackgroundColor: ["#fcc100", "#fcc100", "#fcc100",
                                        "#fcc100", "#fcc100", "#fcc100", "#fcc100"
                                    ],
                                    pointBorderWidth: 0,
                                    data: response.interests,
                                    label: 'Interests',
                                    fill: 'start'
                                }
                            ]
                        },
                        options: {
                            title: {
                                text: 'fill: start',
                                display: false
                            },
                            maintainAspectRatio: true,
                            spanGaps: true,
                            elements: {
                                point: {
                                    radius: 0,
                                }
                            },
                            plugins: {
                                filler: {
                                    propagate: false
                                }
                            },
                            legend: {
                                display: true
                            },
                            scales: {
                                xAxes: [{
                                    display: true,
                                    ticks: {
                                        autoSkip: false,
                                        maxRotation: 0
                                    },
                                    gridLines: {
                                        color: '#dcdde1',
                                        lineWidth: 1,
                                        borderDash: [1]
                                    }
                                }],
                                yAxes: [{
                                    display: true,
                                    gridLines: {
                                        color: '#dcdde1',
                                        lineWidth: 1,
                                        borderDash: [1],
                                        zeroLineColor: '#dcdde1',
                                    }
                                }]
                            }
                        }
                    });

                });
            }).change();

            $('[name=invest_interest_month]').on('change', function() {
                $('[name=invest_interest_year]').trigger('change');
            });

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
