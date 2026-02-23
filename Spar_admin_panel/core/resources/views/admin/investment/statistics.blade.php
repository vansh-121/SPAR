@extends('admin.layouts.app')

@section('panel')
    <div class="row g-4">
        <div class="col-md-6">
            <div class="row g-4">
                <div class="col-12">
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
                                        <div id="investTotalPicker" class="border p-1 cursor-pointer rounded">
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
                            <div class="px-2">
                                <div class="row align-items-center">
                                    <div class="col-md-4">
                                        <p>@lang('Investments for ')<span class="time_type"></span></p>
                                    </div>
                                    <div class="col-md-4">
                                        <h3><span>{{ gs('cur_sym') }}</span><span class="total_invest"></span></h3>
                                    </div>
                                    <div class="col-md-4">
                                        <p class="up_down">

                                        </p>
                                    </div>
                                </div>
                            </div>
                            <div class="my_invest_canvas"></div>
                        </div>
                    </div>
                </div>
                <div class="col-xxl-6">
                    <div class="card h-100">
                        <div class="card-header">
                            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                                <h5 class="card-title mb-0">@lang('Investments')</h5>
                                <div id="investmentPicker" class="border p-1 cursor-pointer rounded">
                                    <i class="la la-calendar"></i>&nbsp;
                                    <span></span> <i class="la la-caret-down"></i>
                                </div>
                            </div>
                        </div>
                        <div class="card-body investment-report">
                            <div class="card-container">
                                <div class="investments-scheme">
                                    <div class="investments-scheme-item">
                                        <p class="mb-0">@lang('Total Investments')</p>
                                        <h3 class="mb-6">
                                            <span class="totalInvest"></span>
                                        </h3>
                                    </div>
                                    <div class="investments-scheme-arrow">
                                        <div class="text-end">
                                            <i class="las la-arrow-down text--success" style="transform: rotate(30deg);"></i>
                                        </div>
                                        <div class="text-start">
                                            <i class="las la-arrow-down text--success" style="transform: rotate(-30deg);"></i>
                                        </div>
                                    </div>
                                    <div class="investments-scheme-group">
                                        <div class="investments-scheme-content">
                                            <p class="font-12">@lang('Deposit Wallet')</p>
                                            <h3 class="deposit-amount counter">
                                                <span class="text--success depositWalletInvest"></span>
                                            </h3>
                                            <p class="mb-0 font-12">
                                                <i class="feather icon-users"></i>
                                                <strong>
                                                    <span class="depositWalletInvestPercentage"></span>
                                                </strong>
                                            </p>
                                        </div>
                                        <div class="investments-scheme-content">
                                            <p class="font-12">@lang('Interest Wallet')</p>
                                            <h3 class="deposit-amount counter">
                                                <span class="text--success interestWalletInvest"></span>
                                            </h3>
                                            <p class="mb-0 font-12"><i class="feather icon-users"></i>
                                                <strong>
                                                    <span class="interestWalletInvestPercentage"></span>
                                                </strong>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xxl-6">
                    <div class="card h-100">
                        <div class="card-header">
                            <div class="row align-items-center">
                                <div class="col-6">
                                    <h5 class="card-title mb-0">@lang('Profit to Pay')</h5>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            @if ($widget['profit_to_give'])
                                <div class="card-container">
                                    <div class="row align-items-center pb-3 pb-xxl-0">
                                        <div class="col-6">
                                            <p>@lang('Should Pay')</p>
                                            <h3 class="deposit-amount">
                                                <sup>{{ gs('cur_sym') }}</sup>{{ showAmount($widget['profit_to_give'], currencyFormat: false) }}
                                            </h3>
                                        </div>
                                        <div class="col-6 text-end">
                                            <a href="{{ route('admin.report.invest.history') }}" class="btn btn--primary">@lang('History')</a>
                                        </div>
                                    </div>
                                    <div class="progress-info">
                                        <div class="progress-info-content">
                                            <p>@lang('Paid')
                                                ({{ showAmount(($widget['profit_paid'] / ($widget['profit_paid'] + $widget['profit_to_give'])) * 100, currencyFormat: false) }}%)
                                            </p>
                                        </div>
                                        <div class="progress-info-content">
                                            <p>
                                                {{ showAmount($widget['profit_paid']) }} /
                                                {{ showAmount($widget['profit_paid'] + $widget['profit_to_give']) }}
                                            </p>
                                        </div>
                                    </div>
                                    <div class="progress mb-2 my-progressbar">
                                        <div class="progress-bar" role="progressbar" style="width: {{ getAmount(($widget['profit_paid'] / ($widget['profit_paid'] + $widget['profit_to_give'])) * 100) }}%;">
                                        </div>
                                    </div>

                                    <p class="font-12 mb-0">*@lang('This statistics showing data excluding lifetime investment.')</p>
                                </div>
                            @else
                                <h5 class="text-center">@lang('No invest found to paid')</h5>
                            @endif
                        </div>
                    </div>
                </div>
                <div class="col-12">
                    <div class="card h-100">
                        <div class="card-header">
                            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                                <h5 class="card-title mb-0">@lang('Interest Statistics by Plan')</h5>
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
            </div>
        </div>
        <div class="col-md-6">
            <div class="row g-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <div class="row align-items-center">
                                <div class="col-12">
                                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                        <h5 class="card-title mb-0">@lang('Invest & Interest')</h5>
                                        <div id="investInterestPicker" class="border p-1 cursor-pointer rounded">
                                            <i class="la la-calendar"></i>&nbsp;
                                            <span></span> <i class="la la-caret-down"></i>
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="interest-scheme">
                                <div class="interest-scheme__content">
                                    <p class="mb-0">@lang('Running Invest')</p>
                                    <h5 class="mb-1 text-success runningInvests"></h5>
                                    <p class="mb-0">
                                        <a href="{{ route('admin.report.invest.history') }}?status={{ Status::INVEST_RUNNING }}" class="btn btn-sm btn-success-rgba font-12 px-2 investHistory">@lang('History')</a>
                                    </p>
                                </div>
                                <div class="interest-scheme__content text-sm-center">
                                    <p class="mb-0 font-12">@lang('Closed Invest')</p>
                                    <h5 class="mb-1 text--warning counter expiredInvests"></h5>
                                    <p class="mb-0">
                                        <a href="{{ route('admin.report.invest.history') }}?status={{ Status::INVEST_CLOSED }}" class="btn btn-sm btn-warning-rgba font-12 px-2 investHistory">@lang('History')</a>
                                    </p>
                                </div>
                                <div class="interest-scheme__content text-sm-end">
                                    <p class="mb-0 font-12">@lang('Interest')</p>
                                    <h5 class="mb-1 text--primary interests"></h5>
                                    <p class="mb-0">
                                        <a href="{{ route('admin.report.transaction') }}?remark=interest" class="btn btn-sm btn-primary-rgba font-12 px-2 investHistory speedUp">@lang('History')</a>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <div class="d-flex justify-content-between align-items-center gap-2 flex-wrap">
                                <div>
                                    <h5 class="card-title mb-0">@lang('Investment Statistics by Plan')</h5>
                                </div>
                                <div>
                                    <div class="d-flex align-items-center flex-wrap gap-2">
                                        <select name="plan_statistics_invests" class="widget_select">
                                            <option value="all">@lang('All Invests')</option>
                                            <option value="active">@lang('Active Invests')</option>
                                            <option value="closed">@lang('Closed Invests')</option>
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
                                    <span href="javascript:void(0)" class="chart-info-toggle">
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
                    <div class="card h-100">
                        <div class="card-header">
                            <div class="row align-items-center g-2">
                                <div class="col-sm-6">
                                    <h5 class="card-title mb-0">@lang('Invest & Interest')</h5>
                                </div>
                                @if (@$firstInvestYear->date)
                                    <div class="col-sm-6">
                                        <div class="pair-option">
                                            <select name="invest_interest_year" class="widget_select">
                                                @for ($i = $firstInvestYear->date; $i <= date('Y'); $i++)
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
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <div class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                                <h5 class="card-title mb-0">@lang('Recent Investments')</h5>
                                <a href="{{ route('admin.report.invest.history') }}" class="btn btn-sm btn--primary">@lang('View All')</a>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="plan-list d-flex flex-wrap flex-xxl-column gap-3 gap-xxl-0">
                                @foreach ($recentInvests as $invest)
                                    <div class="plan-item-two">
                                        <div class="plan-info plan-inner-div">
                                            <div class="plan-name fw-bold">{{ $invest->plan->name }} - @lang('Every')
                                                {{ __($invest->time_name) }}
                                                {{ $invest->plan->interest_type != 1 ? gs('cur_sym') : '' }}{{ showAmount($invest->plan->interest, currencyFormat: false) }}{{ $invest->plan->interest_type == 1 ? '%' : '' }}
                                                @lang('for') @if ($invest->plan->lifetime == 0)
                                                    {{ __($invest->plan->repeat_time) }}
                                                    {{ __(@$invest->plan->timeSetting->name) }}
                                                @else
                                                    @lang('LIFETIME')
                                                @endif
                                            </div>
                                            <div class="plan-desc text-end text-xl-start">@lang('Invested'): <span class="fw-bold">{{ showAmount($invest->amount) }}</span></div>
                                        </div>
                                        <div class="plan-start plan-inner-div">
                                            <p class="plan-label">@lang('Start Date')</p>
                                            <p class="plan-value date">
                                                {{ showDateTime($invest->created_at, 'd M, y h:i A') }}</p>
                                        </div>
                                        <div class="plan-end plan-inner-div">
                                            <p class="plan-label">@lang('End Date')</p>
                                            <p class="plan-value date">
                                                {{ showDateTime($invest->created_at, 'd M, y h:i A') }}</p>
                                        </div>
                                        <div class="plan-amount plan-inner-div text-end">
                                            <p class="plan-label">@lang('Net Profit')</p>
                                            <p class="plan-value amount">
                                                {{ $invest->period != -1 ? showAmount($invest->period * $invest->interest) . ' ' . gs('cur_text') : '---' }}
                                            </p>
                                        </div>
                                    </div>
                                @endforeach

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
@endsection


@push('style')
    <style>
        .widget_select {
            padding: 3px 3px;
            font-size: 13px;
        }
    </style>
@endpush

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
        'use strict';
        (function($) {
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

            //invest total
            const investTotal = (startDate, endDate, chosenLabel) => {
                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD'),
                    chosen_label: chosenLabel
                }

                let time = $('#investTotalPicker span').text();
                var url = "{{ route('admin.invest.report.statistics') }}";

                $.get(url, {
                    data_type: data.chosen_label,
                    start_date: data.start_date,
                    end_date: data.end_date,
                }, function(response) {
                    $('.time_type').text(time);
                    $('.total_invest').text(response.total_invest.toFixed(2));
                    let upDown = `<small>Previous invest was zero</small>`;
                    if (response.invest_diff != 0) {
                        if (response.up_down == 'up') {
                            var className = 'success'
                        } else {
                            var className = 'danger';
                        }
                        upDown = `<span class="badge badge-${className}-inverse font-16">${response.invest_diff}%<i class="las la-arrow-${response.up_down}"></i></span>`;
                    }
                    if (!response.pre_time) {
                        $('.up_down').html('');
                    } else {
                        $('.up_down').html(upDown);
                    }

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

            $('#investTotalPicker').daterangepicker(dateRangeOptions, (start, end) => changeDatePickerText('#investTotalPicker span', start, end));
            $('#investTotalPicker').on('apply.daterangepicker', (event, picker) => investTotal(picker.startDate, picker.endDate, picker.chosenLabel));

            changeDatePickerText('#investTotalPicker span', start, end);
            investTotal(start, end, 'Last 30 Days')


            //investments
            let curSymbol = '{{ gs('cur_sym') }}';
            const investmentReport = (startDate, endDate) => {
                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD')
                }
                var url = "{{ route('admin.invest.report.invest') }}";

                $.get(url, {
                    start_date: data.start_date,
                    end_date: data.end_date,
                }, function(response) {
                    let totalInvest = response.total_invest;
                    let depositWalletInvest = parseFloat(response.deposit_wallet_invest);
                    let interestWalletInvest = parseFloat(response.interest_wallet_invest);

                    let depositWalletInvestPercentage = (depositWalletInvest / totalInvest) * 100;
                    let interestWalletInvestPercentage = (interestWalletInvest / totalInvest) * 100;

                    $('.totalInvest').html(`<small>${curSymbol}</small>` + totalInvest.toFixed(2));
                    $('.depositWalletInvest').text(curSymbol + depositWalletInvest.toFixed(2));
                    $('.interestWalletInvest').text(curSymbol + interestWalletInvest.toFixed(2));

                    $('.depositWalletInvestPercentage').text(depositWalletInvestPercentage > 0 ? depositWalletInvestPercentage.toFixed(2) + '%' : '0.00%');
                    $('.interestWalletInvestPercentage').text(interestWalletInvestPercentage > 0 ? interestWalletInvestPercentage.toFixed(2) + '%' : '0.00%');
                });
            }
            $('#investmentPicker').daterangepicker(dateRangeOptions, (start, end) => changeDatePickerText('#investmentPicker span', start, end));
            $('#investmentPicker').on('apply.daterangepicker', (event, picker) => investmentReport(picker.startDate, picker.endDate));
            changeDatePickerText('#investmentPicker span', start, end);
            investmentReport(start, end)

            //invest interest
            const investInterest = (startDate, endDate) => {
                let searchByDate = "date=" + $('#investInterestPicker span').text();

                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD')
                }
                var url = "{{ route('admin.invest.report.interest') }}";
                $.get(url, {
                    start_date: data.start_date,
                    end_date: data.end_date,
                }, function(response) {
                    $('.runningInvests').text(`${response.running_invests}`);
                    $('.expiredInvests').text(`${response.expired_invests}`);
                    $('.interests').text(`${response.interests}`);

                    $('.investHistory').each(function() {
                        let currentHref = $(this).attr('href');

                        if (currentHref) {
                            if (currentHref.includes('date=')) {
                                currentHref = currentHref.replace(/date=[^&]+/, searchByDate);
                            } else {
                                currentHref = currentHref + '&' + searchByDate;
                            }
                            $(this).attr('href', currentHref);
                        }
                    });

                });
            }
            $('#investInterestPicker').daterangepicker(dateRangeOptions, (start, end) => changeDatePickerText('#investInterestPicker span', start, end));
            $('#investInterestPicker').on('apply.daterangepicker', (event, picker) => investInterest(picker.startDate, picker.endDate));
            changeDatePickerText('#investInterestPicker span', start, end);
            investInterest(start, end)


            // Interest Statistics by Plan
            const investInterestStatistics = (startDate, endDate) => {
                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD')
                }
                var url = "{{ route('admin.invest.report.interest.statistics') }}";
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

            // Investment Statistics by Plan
            const investPlan = (startDate, endDate) => {
                const data = {
                    start_date: startDate.format('YYYY-MM-DD'),
                    end_date: endDate.format('YYYY-MM-DD')
                }
                let investType = $('[name=plan_statistics_invests]').val();
                var url = "{{ route('admin.invest.report.statistics.plan') }}";

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
                    let planUrl = "{{ route('admin.report.invest.history') }}";
                    let searchByDate = "date=" + $('#investmentPlanPicker span').text();
                    let status = response.status ?? '';

                    $.each(invests, function(key, invest) {
                        let investPercent = (invest.investAmount / response.total_invest) * 100;
                        investAmount.push(parseFloat(invest.investAmount).toFixed(2));
                        planName.push(invest.plan.name);
                        planInfo +=
                            `<li class="chart-info-list-item"><i class="fas fa-plane planPoint me-2"></i>${investPercent.toFixed(2)}% - ${invest.plan.name} <a href="${planUrl}?search=${invest.plan.name}&${searchByDate}&status=${status}"><i class="las la-info-circle"></i></a></li>`
                    });
                    $('.plan-info-data').html(planInfo);

                    /* -- Chartjs - Pie Chart -- */
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


            $('[name=plan_statistics_invests]').on('change', function() {
                $('[name=plan_statistics_time]').trigger('change');
                let picker = $('#investmentPlanPicker').data('daterangepicker');
                $('#investmentPlanPicker').trigger('apply.daterangepicker', [picker, picker.startDate, picker.endDate]);
            });

            $('[name=invest_interest_year]').on('change', function() {
                let year = $('[name=invest_interest_year]').val();
                let month = $('[name=invest_interest_month]').val();
                let url = "{{ route('admin.invest.report.interest.chart') }}";
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


            var planPointInterests = $(document).find('.planPointInterest');
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
        .widget_select {
            height: 34px;
        }

        .card-body.investment-report {
            min-height: 236px;
        }
    </style>
@endpush
