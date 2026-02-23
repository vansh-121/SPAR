@extends('admin.layouts.app')
@section('panel')
    <div class="row">
        <div class="col-lg-12">


            <div class="show-filter mb-3 text-end">
                <button type="button" class="btn btn-outline--primary showFilterBtn btn-sm"><i class="las la-filter"></i> @lang('Filter')</button>
            </div>
            <div class="card responsive-filter-card mb-4">
                <div class="card-body">
                    <form>
                        <div class="d-flex flex-wrap gap-4">
                            <div class="flex-grow-1">
                                <label>@lang('Search')</label>
                                <input type="search" name="search" value="{{ request()->search }}" class="form-control" placeholder="Username">
                            </div>
                            <div class="flex-grow-1">
                                <label>@lang('Status')</label>
                                <select name="status" class="select2" data-minimum-results-for-search="-1">
                                    <option value="">@lang('All Status')</option>
                                    <option value="1" @selected(request('status') == 1)>@lang('Running')</option>
                                    <option value="2" @selected(request('status') == 2)>@lang('Completed')</option>
                                </select>
                            </div>
                            <div class="flex-grow-1">
                                <label>@lang('Plan')</label>
                                <select name="staking_id" class="select2" data-minimum-results-for-search="-1">
                                    <option value="">@lang('All Plan')</option>
                                    @foreach ($investPlans as $investPlan)
                                        <option value="{{ $investPlan->id }}" @selected(request('staking_id') == $investPlan->id)>{{ $investPlan->days }} @lang('Days')</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="flex-grow-1">
                                <label>@lang('Date')</label>
                                <input name="date" type="search" class="datepicker-here form-control bg--white pe-2 date-range" placeholder="@lang('Start Date - End Date')" autocomplete="off" value="{{ request()->date }}">
                            </div>
                            <div class="flex-grow-1 align-self-end">
                                <button class="btn btn--primary w-100 h-45"><i class="fas fa-filter"></i> @lang('Filter')</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>








            <div class="card b-radius--10 ">
                <div class="card-body p-0">
                    <div class="table-responsive--md  table-responsive">
                        <table class="table table--light style--two">
                            <thead>
                                <tr>
                                    <th>@lang('User')</th>
                                    <th>@lang('Amount')</th>
                                    <th>@lang('Interest')</th>
                                    <th>@lang('Total Return')</th>
                                    <th>@lang('Invest Date')</th>
                                    <th>@lang('Return Date')</th>
                                    <th>@lang('Status')</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($stakingInvests as $stakingInvest)
                                    <tr>
                                        <td>
                                            <span class="fw-bold">{{ $stakingInvest->user->fullname }}</span>
                                            <br>
                                            <span class="small">
                                                <a href="{{ route('admin.users.detail', $stakingInvest->user->id) }}"><span>@</span>{{ $stakingInvest->user->username }}</a>
                                            </span>
                                        </td>
                                        <td>{{ showAmount($stakingInvest->invest_amount) }}</td>
                                        <td>{{ showAmount($stakingInvest->interest) }}</td>
                                        <td>{{ showAmount($stakingInvest->invest_amount + $stakingInvest->interest) }}</td>
                                        <td>{{ showDateTime($stakingInvest->created_at) }}</td>
                                        <td>{{ showDateTime($stakingInvest->end_at) }}</td>
                                        <td>
                                            @if ($stakingInvest->status == 1)
                                                <span class="badge badge--success">@lang('Running')</span>
                                            @else
                                                <span class="badge badge--primary">@lang('Completed')</span>
                                            @endif
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td class="text-muted text-center" colspan="100%">{{ __($emptyMessage) }}</td>
                                    </tr>
                                @endforelse

                            </tbody>
                        </table><!-- table end -->
                    </div>
                </div>
                @if ($stakingInvests->hasPages())
                    <div class="card-footer py-4">
                        {{ paginateLinks($stakingInvests) }}
                    </div>
                @endif
            </div>
        </div>
    </div>
@endsection

@push('script-lib')
    <script src="{{ asset('assets/admin/js/moment.min.js') }}"></script>
    <script src="{{ asset('assets/admin/js/daterangepicker.min.js') }}"></script>
@endpush

@push('style-lib')
    <link rel="stylesheet" type="text/css" href="{{ asset('assets/admin/css/daterangepicker.css') }}">
@endpush

@push('script')
    <script>
        (function($) {
            "use strict"

            const datePicker = $('.date-range').daterangepicker({
                autoUpdateInput: false,
                locale: {
                    cancelLabel: 'Clear'
                },
                showDropdowns: true,
                ranges: {
                    'Today': [moment(), moment()],
                    'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
                    'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                    'Last 15 Days': [moment().subtract(14, 'days'), moment()],
                    'Last 30 Days': [moment().subtract(30, 'days'), moment()],
                    'This Month': [moment().startOf('month'), moment().endOf('month')],
                    'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
                    'Last 6 Months': [moment().subtract(6, 'months').startOf('month'), moment().endOf('month')],
                    'This Year': [moment().startOf('year'), moment().endOf('year')],
                },
                maxDate: moment()
            });
            const changeDatePickerText = (event, startDate, endDate) => {
                $(event.target).val(startDate.format('MMMM DD, YYYY') + ' - ' + endDate.format('MMMM DD, YYYY'));
            }


            $('.date-range').on('apply.daterangepicker', (event, picker) => changeDatePickerText(event, picker.startDate, picker.endDate));


            if ($('.date-range').val()) {
                let dateRange = $('.date-range').val().split(' - ');
                $('.date-range').data('daterangepicker').setStartDate(new Date(dateRange[0]));
                $('.date-range').data('daterangepicker').setEndDate(new Date(dateRange[1]));
            }

        })(jQuery)
    </script>
@endpush
