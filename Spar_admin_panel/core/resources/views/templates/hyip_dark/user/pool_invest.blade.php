@extends($activeTemplate . 'layouts.master')

@section('content')
    <div class="row justify-content-center">
        <div class="col-md-12">
            <div class="card custom--card">
                <div class="card-body">
                    <table class="table table--responsive--xl">
                        <thead>
                            <tr>
                                <th>@lang('Pool')</th>
                                <th>@lang('Invest Amount')</th>
                                <th>@lang('Invest Till')</th>
                                <th>@lang('Return Date')</th>
                                <th>@lang('Total Return')</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($poolInvests as $poolInvest)
                                <tr>
                                    <td>{{ __($poolInvest->pool->name) }}</td>
                                    <td>{{ showAmount($poolInvest->invest_amount) }}</td>
                                    <td>{{ showDateTime($poolInvest->pool->start_date, 'M d, Y h:i A') }}</td>
                                    <td>{{ showDateTime($poolInvest->pool->end_date, 'M d, Y h:i A') }}</td>

                                    <td>
                                        @if ($poolInvest->pool->share_interest)
                                            {{ showAmount($poolInvest->invest_amount * (1 + $poolInvest->pool->interest / 100)) }}
                                        @else
                                            @lang('Not return yet!')
                                        @endif
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
            {{ paginateLinks($poolInvests) }}
        </div>
    </div>
@endsection
