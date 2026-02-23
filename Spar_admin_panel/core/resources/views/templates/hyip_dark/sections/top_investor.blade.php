@php
    $topInvestor = getContent('top_investor.content', true);

    $topInvestors = \App\Models\Invest::with('user')
        ->selectRaw('SUM(amount) as totalAmount, user_id')
        ->orderBy('totalAmount', 'desc')
        ->groupBy('user_id')
        ->limit(10)
        ->get();

    $latestDeposits = \App\Models\Deposit::with('user')->successful()->orderBy('id', 'DESC')->limit(5)->get();
    $latestWithdrawals = \App\Models\Withdrawal::with('user')->approved()->orderBy('id', 'DESC')->limit(5)->get();
@endphp

<!--=============== top investor section start here =============== -->
<div class="top-investor-section my-120">
    <div class="container">
        <div class="section-heading">
            <div class="section-heading__shape"></div>
            <h1 class="section-heading__title"> {{ __(@$topInvestor->data_values->heading) }} </h1>
            <p class="section-heading__desc">{{ __(@$topInvestor->data_values->subheading) }}</p>
        </div>
        <div class="row gy-4 justify-content-center">
            @foreach($topInvestors as $k => $data)
                <div class="col-xl-3 col-lg-4 col-sm-6 col-xsm-6">
                    <div class="investor-item">
                        <div class="investor-item__number">
                            {{ ++$k }}
                        </div>
                        <div class="investor-item__content">
                            <h6 class="investor-item__name"> {{ @$data->user->fullname }} </h6>
                            <h5 class="investor-item__currency"> 
                                {{ showAmount(@$data->totalAmount, currencyFormat:false) }} 
                                <span class="fs-16"> {{ gs('cur_text') }} </span> 
                            </h5>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
</div>
<div class="withdraw-deposit-section my-120">
    <div class="withdraw-deposit-section__shape">
        <img src="{{ asset($activeTemplateTrue.'images/shapes/dw-1.png') }}" alt="">
    </div>
    <div class="container">
        <div class="row gy-4 justify-content-between">
            <div class="col-md-6 pe-xl-5">
                <div class="deposit-withdraw-wrapper">
                    <h3 class="title"> @lang('Latest Deposit Money') </h3>
                    <div class="deposit-withdraw-list">

                        @forelse ($latestDeposits as $latestDeposit)
                            <div class="deposit-withdraw-item">
                                <span class="deposit-withdraw-item__shape"></span>
                                <div class="deposit-withdraw-item__left">
                                    <h6 class="name"> {{ @$latestDeposit->user->fullname }} </h6>
                                    <span class="time"> {{ showDateTime(@$latestDeposit->created_at, 'd F Y, h:ia') }}</span>
                                </div>
                                <div class="deposit-withdraw-item__thumb">
                                    <img src="{{ asset($activeTemplateTrue.'images/thumbs/dp-4.png') }}" alt="">
                                </div>
                                <h6 class="deposit-withdraw-item__currency">
                                    {{ showAmount($latestDeposit->amount) }}
                                </h6>
                            </div>
                        @empty 
                            <div class="deposit-withdraw-item">
                                <span class="deposit-withdraw-item__shape"></span>
                                <div class="deposit-withdraw-item__left">
                                    <h6 class="name"> {{ __($emptyMessage) }} </h6>
                                </div>
                            </div>
                        @endforelse 

                    </div>
                </div>
            </div>
            <div class="col-md-6 ps-xl-5">
                <div class="deposit-withdraw-wrapper">
                    <h3 class="title"> @lang('Latest Withdraw Money') </h3>
                    <div class="deposit-withdraw-list">

                        @forelse ($latestWithdrawals as $latestWithdrawal)  
                            <div class="deposit-withdraw-item">
                                <span class="deposit-withdraw-item__shape"></span>
                                <div class="deposit-withdraw-item__left">
                                    <h6 class="name"> {{ @$latestWithdrawal->user->fullname }} </h6>
                                    <span class="time"> {{ showDateTime(@$latestWithdrawal->created_at, 'd F Y, h:ia') }}</span>
                                </div>
                                <div class="deposit-withdraw-item__thumb">
                                    <img src="{{ asset($activeTemplateTrue.'images/thumbs/dp-4.png') }}" alt="">
                                </div>
                                <h6 class="deposit-withdraw-item__currency">
                                    {{ showAmount($latestWithdrawal->amount) }}
                                </h6>
                            </div>
                        @empty 
                            <div class="deposit-withdraw-item">
                                <span class="deposit-withdraw-item__shape"></span>
                                <div class="deposit-withdraw-item__left">
                                    <h6 class="name"> {{ __($emptyMessage) }} </h6>
                                </div>
                            </div>
                        @endforelse 

                    </div>
                </div>
            </div>
        </div>
    </div>
</div>