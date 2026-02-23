@extends($activeTemplate . 'layouts.master')

@section('content')
    <div class="row gy-4">
        <div class="col-md-12">
            <div class="card custom--card">
                <div class="card-body">
                    <table class="table table--responsive--xl">
                        <thead>
                            <tr>
                                <th>@lang('Plan')</th>
                                <th>@lang('Return')</th>
                                <th>@lang('Wallet')</th>
                                <th>@lang('Remaining Times')</th>
                                <th>@lang('Next Invest')</th>
                                <th>@lang('Action')</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($scheduleInvests as $scheduleInvest)
                                @php
                                    $plan = $scheduleInvest->plan;
                                    $interest = $plan->interest_type == 1 ? ($scheduleInvest->amount * $plan->interest) / 100 : $plan->interest;
                                @endphp
                                <tr>
                                    <td>{{ __($scheduleInvest->plan->name) }} <br> {{ showAmount($scheduleInvest->amount) }} </td>
                                    <td>
                                        {{ showAmount($interest) }} @lang('every') {{ $plan->timeSetting->name }}
                                        <br>
                                        @lang('for')
                                        @if ($plan->lifetime)
                                            @lang('Lifetime')
                                        @else
                                            {{ $plan->repeat_time }}
                                            {{ $plan->timeSetting->name }}
                                        @endif
                                        @if ($plan->capital_back)
                                            + @lang('Capital')
                                        @endif
                                    </td>
                                    <td>{{ __(keyToTitle($scheduleInvest->wallet)) }}</td>
                                    <td>{{ $scheduleInvest->rem_schedule_times }}</td>
                                    <td>{{ $scheduleInvest->next_invest ? showDateTime($scheduleInvest->next_invest) : '----' }}</td>
                                    <td>
                                        <div class="action--btns">
                                            <button class="icon-btn bg--base text-white detailsBtn" data-schedule_invest="{{ $scheduleInvest }}" data-interest="{{ getAmount($interest) }}" data-next_invest="{{ $scheduleInvest->next_invest ? showDateTime($scheduleInvest->next_invest) : '-----' }}">
                                                <i class="fa fa-desktop"></i>
                                            </button>
                                            @if ($scheduleInvest->rem_schedule_times)
                                                @if ($scheduleInvest->status)
                                                    <button class="icon-btn bg--base text-white confirmationBtn" data-question="@lang('Are you sure to pause this schedule invest?')" data-action="{{ route('user.invest.schedule.status', $scheduleInvest->id) }}">
                                                        <i class="fas fa-pause"></i>
                                                    </button>
                                                @else
                                                    <button class="icon-btn bg--base text-white confirmationBtn" data-question="@lang('Are you sure to continue this schedule invest?')" data-action="{{ route('user.invest.schedule.status', $scheduleInvest->id) }}">
                                                        <i class="fas fa-play"></i>
                                                    </button>
                                                @endif
                                            @endif
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="100%" class="text-center">{{ __($emptyMessage) }}</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            {{ paginateLinks($scheduleInvests) }}
        </div>
    </div>

    <div class="modal fade" id="detailsModal">
        <div class="modal-dialog modal-dialog-centered modal-content-bg">
            <div class="modal-content">
                <div class="modal-header">
                    <h6 class="modal-title">
                        @lang('Schedule Invest Details')
                    </h6>
                    <button type="button" class="close" data-bs-dismiss="modal">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
                <div class="modal-body">
                    <ul class="list--group">
                        <li class="list-group-item d-flex justify-content-between">
                            @lang('Plan Name')
                            <span class="planName"></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between">
                            @lang('Invest Amount')
                            <span class="investAmount"></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between">
                            @lang('Interest')
                            <span class="interestAmount"></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between compoundInterestBlock">
                            @lang('Compound Interest')
                            <span class="compoundInterest"></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between">
                            @lang('Schedule Times')
                            <span class="scheduleTimes"></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between">
                            @lang('Remaining Schedule Times')
                            <span class="remScheduleTimes"></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between">
                            @lang('Interval')
                            <span class="intervalHours"></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between">
                            @lang('Next Invest')
                            <span class="nextInvest"></span>
                        </li>
                    </ul>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn--danger" data-bs-dismiss="modal">@lang('Close')</button>
                </div>
            </div>
        </div>
    </div>

    <x-confirmation-modal closeBtn="btn btn--danger" submitBtn="btn btn--base" />
@endsection

@push('script')
    <script>
        (function($) {
            "use strict";

            let curSym = `{{ gs('cur_sym') }}`;

            $('.detailsBtn').on('click', function() {
                let modal = $('#detailsModal');
                let data = $(this).data();
                let scheduleInvest = data.schedule_invest;


                modal.find('.planName').text(scheduleInvest.plan.name);
                modal.find('.investAmount').text(curSym + parseFloat(scheduleInvest.amount).toFixed(2));
                modal.find('.interestAmount').text(curSym + parseFloat(data.interest).toFixed(2));
                modal.find('.scheduleTimes').text(scheduleInvest.schedule_times);
                modal.find('.remScheduleTimes').text(scheduleInvest.rem_schedule_times);
                modal.find('.intervalHours').text(`${scheduleInvest.interval_hours} @lang('Hours')`);
                modal.find('.nextInvest').text(data.next_invest);

                if (scheduleInvest.compound_times == -1) {
                    modal.find('.compoundInterest').text(`@lang('Auto (plan controlled)')`);
                    $('.compoundInterestBlock').removeClass('d-none');
                } else if (scheduleInvest.compound_times) {
                    modal.find('.compoundInterest').text(`${scheduleInvest.compound_times} @lang('times')`);
                    $('.compoundInterestBlock').removeClass('d-none');
                } else {
                    $('.compoundInterestBlock').addClass('d-none');
                }

                modal.modal('show');
            });
        })(jQuery);
    </script>
@endpush
