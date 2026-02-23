@forelse ($pools as $pool)
    <div class="col-xxl-3 col-sm-6">
        <div class="plan-card h-100">
            <span class="plan-card__badge"> {{ __($pool->name) }} </span>
            <div class="plan-card__top">
                <span class="plan-card__number">
                    {{ __($pool->interest_range) }}
                </span>
            </div>
            <ul class="plan-list">
                <li class="plan-list__item">
                    @lang('Total Amount')
                    {{ gs('cur_sym') }}{{ showAmount($pool->amount, currencyFormat:false) }}
                </li>
                <li class="plan-list__item">
                    @lang('Invest till') {{ showDateTime($pool->start_date, 'Y-m-d') }}
                </li>
                <li class="plan-list__item">
                    @lang('Return Date') {{ showDateTime($pool->end_date, 'Y-m-d') }}
                </li>
            </ul>

            <div class="remaining">
                <h6 class="title">@lang('Invested Amount')</h6>
                <span class="remaining-amount">
                    {{ gs('cur_sym') }}{{ showAmount($pool->invested_amount, currencyFormat:false) }}/{{ gs('cur_sym') }}{{ showAmount($pool->amount, currencyFormat:false) }}
                </span>
                <div class="progress">
                    <div class="progress-bar bg--base customWidth" data-invested="{{ getAmount($pool->invested_amount / $pool->amount * 100) }}" role="progressbar" aria-valuenow="30" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
            </div>

            <div class="plan-card__btn">
                <button data-bs-toggle="modal" data-bs-target="#poolInvestModal" data-pool_id="{{ $pool->id }}" data-pool_name="{{ __($pool->name) }}" class="btn btn--base btn--lg w-100 poolInvestNow">@lang('Invest Now')</a>
            </div>
        </div>
    </div>
@empty
    @include($activeTemplate . 'partials.empty')
@endforelse

<div class="modal fade" id="poolInvestModal">
    <div class="modal-dialog modal-dialog-centered modal-content-bg">
        <div class="modal-content">
            <div class="modal-header">
                @if (auth()->check())
                    <h6 class="modal-title">
                        @lang('Confirm to invest on') <span class="planName"></span>
                    </h6>
                @else
                    <h6 class="modal-title">
                        @lang('At first sign in your account')
                    </h6>
                @endif
                <button type="button" class="close" data-bs-dismiss="modal">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <form action="{{ route('user.pool.invest') }}" method="post">
                @csrf
                <input type="hidden" name="pool_id">
                @if (auth()->check())
                    <div class="modal-body">
                        <div class="form-group">
                            <label class="form--label">@lang('Pay Via')</label>
                            <select class="form--control select2" name="wallet_type" data-minimum-results-for-search="-1" required>
                                <option value="">@lang('Select One')</option>
                                @if (auth()->user()->deposit_wallet > 0)
                                    <option value="deposit_wallet">@lang('Deposit Wallet - ' . showAmount(auth()->user()->deposit_wallet))</option>
                                @endif
                                @if (auth()->user()->interest_wallet > 0)
                                    <option value="interest_wallet">@lang('Interest Wallet -' . showAmount(auth()->user()->interest_wallet))</option>
                                @endif
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form--label">@lang('Invest Amount')</label>
                            <div class="input-group">
                                <input type="number" step="any" min="0" class="form--control form-control form-two" name="amount" required>
                                <div class="input-group-text input-style">{{ gs('cur_text') }}</div>
                            </div>
                        </div>
                    </div>
                @endif
                <div class="modal-footer">
                    @if (auth()->check())
                        <button type="button" class="btn btn--danger" data-bs-dismiss="modal">@lang('No')</button>
                        <button type="submit" class="btn btn--base">@lang('Yes')</button>
                    @else
                        <a href="{{ route('user.login') }}" class="btn--base w-100 text-center">@lang('At first sign in your account')</a>
                    @endif
                </div>
            </form>
        </div>
    </div>
</div>

@push('script')
    <script>
        (function($) {
            "use strict"
            
            $('.customWidth').each(function(index, element) {
                let width = $(this).data('invested');
                $(this).css('width', `${width}%`);
            });

            $('.poolInvestNow').on('click', function() {
                $('[name=pool_id]').val($(this).data('pool_id'));
                $('.planName').text($(this).data('pool_name'));
            });


        })(jQuery);
    </script>
@endpush
