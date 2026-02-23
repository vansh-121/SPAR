@php
    $referral = getContent('referral.content', true);
@endphp

<!--=========== referral section start here =========== -->
<div class="referral-section my-120">
    <div class="container">
        <div class="row justify-content-center gy-4">
            <div class="col-xl-7 pe-xl-5">
                <div class="referral-item">
                    <div class="shape-one"></div>
                    <div class="shape-two"></div>
                    <div class="referral-item__left">
                        <h3 class="referral-item__title"> 
                            {{ __(@$referral->data_values->heading) }} 
                            <span class="text--base"> {{ __(@$referral->data_values->heading_c) }} 
                            </span> 
                        </h3>
                        <p class="referral-item__text">
                            {{ __(@$referral->data_values->subheading) }} 
                            <span class="number"> {{ __(@$referral->data_values->number) }}  </span>
                        </p>
                    </div>
                    <div class="referral-item__btn">
                        <a href="{{ url(@$referral->data_values->button_url) }}" class="btn btn--base"> {{ __(@$referral->data_values->button_text) }} </a>
                    </div>
                </div>
            </div>
            <div class="col-xl-5 ps-xxl-5">
                <div class="referral-counter">
                    <span class="referral-counter__shape"> </span>
                    <div class="counterup-item">
                        <div class="counterup-item__content">
                            <div class="d-flex align-items-center counterup-wrapper">
                                <span class="counterup-item__icon">
                                    <img src="{{ frontendImage('referral', @$referral->data_values->counter_one_icon, '50x50') }}" alt="">
                                </span>
                                <div class="content">
                                    <span class="counterup-item__text"> {{ __(@$referral->data_values->counter_one_text) }} </span>
                                    <div class="counterup-item__number">
                                        <h2 class="counterup-item__title">
                                            <span class="odometer" data-odometer-final="{{ @$referral->data_values->counter_one_number_end }}">{{ @$referral->data_values->counter_one_number }}</span>{{ __(@$referral->data_values->counter_one_text_suffix) }}
                                        </h2>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="counterup-item__content">
                            <div class="d-flex align-items-center counterup-wrapper">
                                <span class="counterup-item__icon">
                                    <img src="{{ frontendImage('referral', @$referral->data_values->counter_two_icon, '50x50') }}" alt="">
                                </span>
                                <div class="content">
                                    <span class="counterup-item__text"> {{ __(@$referral->data_values->counter_two_text) }} </span>
                                    <div class="counterup-item__number">
                                        <h2 class="counterup-item__title">
                                            <span class="odometer" data-odometer-final="{{ @$referral->data_values->counter_two_number_end }}">{{ @$referral->data_values->counter_two_number }}</span>{{ __(@$referral->data_values->counter_two_text_suffix) }}
                                        </h2>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!--=========== referral section end here =========== -->