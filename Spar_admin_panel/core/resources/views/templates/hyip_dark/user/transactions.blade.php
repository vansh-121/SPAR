@extends($activeTemplate . 'layouts.master')

@section('content')
    <div class="row justify-content-center">
        <div class="col-md-12">
            <div class="show-filter mb-3 text-end">
                <button type="button" class="btn btn--base w-100 btn--lg showFilterBtn"><i class="las la-filter"></i> @lang('Filter')</button>
            </div>
            <div class="card custom--card responsive-filter-card mb-4">
                <div class="card-body">
                    <form >
                        <div class="d-flex flex-wrap gap-4">
                            <div class="flex-grow-1">
                                <label class="form--label">@lang('Transaction Number')</label>
                                <input type="text" name="search" value="{{ request()->search }}" class="form--control form-two">
                            </div>
                            <div class="flex-grow-1">
                                <label class="form--label">@lang('Wallet Type')</label>
                                <select name="wallet_type" class="form--control form-two form-select select2" data-minimum-results-for-search="-1">
                                    <option value="">@lang('All')</option>
                                    <option value="deposit_wallet" @selected(request()->wallet_type == 'deposit_wallet')>@lang('Deposit Wallet')</option>
                                    <option value="interest_wallet" @selected(request()->wallet_type == 'interest_wallet')>@lang('Interest Wallet')</option>
                                </select>
                            </div>
                            <div class="flex-grow-1">
                                <label class="form--label">@lang('Type')</label>
                                <select name="trx_type" class="form--control form-two form-select select2" data-minimum-results-for-search="-1">
                                    <option value="">@lang('All')</option>
                                    <option value="+" @selected(request()->trx_type == '+')>@lang('Plus')</option>
                                    <option value="-" @selected(request()->trx_type == '-')>@lang('Minus')</option>
                                </select>
                            </div>
                            <div class="flex-grow-1">
                                <label class="form--label">@lang('Remark')</label>
                                <select class="form--control form-two form-select select2" name="remark">
                                    <option value="">@lang('Any')</option>
                                    @foreach ($remarks as $remark)
                                        <option value="{{ $remark->remark }}" @selected(request()->remark == $remark->remark)>{{ __(keyToTitle($remark->remark)) }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <div class="flex-grow-1 align-self-end">
                                <button class="btn btn--base w-100 btn--lg"><i class="las la-filter"></i> @lang('Filter')</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            <div class="card custom--card">
                <div class="card-body">
                    <table class="table table--responsive--xl">
                        <thead>
                            <tr>
                                <th>@lang('Trx')</th>
                                <th>@lang('Transacted')</th>
                                <th>@lang('Amount')</th>
                                <th>@lang('Post Balance')</th>
                                <th>@lang('Wallet Type')</th>
                                <th>@lang('Detail')</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($transactions as $trx)
                                <tr>
                                    <td>
                                        <strong>{{ $trx->trx }}</strong>
                                    </td>

                                    <td>
                                        {{ showDateTime($trx->created_at) }}<br>{{ diffForHumans($trx->created_at) }}
                                    </td>

                                    <td class="budget">
                                        <span class="fw-bold @if ($trx->trx_type == '+') text--success @else text--danger @endif">
                                            {{ $trx->trx_type }} {{ showAmount($trx->amount) }}
                                        </span>
                                    </td>

                                    <td class="budget">
                                        {{ showAmount($trx->post_balance) }}
                                    </td>

                                    <td>
                                        @if ($trx->wallet_type == 'deposit_wallet')
                                            <span class="badge bg--info">@lang('Deposit Wallet')</span>
                                        @else
                                            <span class="badge bg--primary">@lang('Interest Wallet')</span>
                                        @endif
                                    </td>

                                    <td>{{ __($trx->details) }}</td>
                                </tr>
                            @empty
                                <tr>
                                    <td class="text-muted text-center" colspan="100%">{{ __($emptyMessage) }}</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
            @if ($transactions->hasPages())
                <div class="custom--pagination mt-4">
                    {{ paginateLinks($transactions) }}
                </div>
            @endif
        </div>
    </div>
@endsection

@push('script')
    <script>
        (function($) {
            "use strict";
            $('.showFilterBtn').on('click', function() {
                $('.responsive-filter-card').slideToggle();
            });
        })(jQuery);
    </script>
@endpush
