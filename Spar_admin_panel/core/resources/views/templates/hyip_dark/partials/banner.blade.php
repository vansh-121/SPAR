@php
    $banner = getContent('banner.content', true);
@endphp

<!--========================== Banner Section Start ==========================-->
<section class="banner-section bg-img" data-background-image="{{ frontendImage('banner', @$banner->data_values->background_image, '1920x950') }}">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="banner-content">
                    <span class="banner-content__subtitle">{{ __(@$banner->data_values->subheading) }}</span>
                    <h1 class="banner-content__title">{{ __(@$banner->data_values->heading) }}</h1>
                    <p class="banner-content__desc">{{ __(@$banner->data_values->description) }}</p>
                    <div class="counterup-item">
                        <div class="counterup-item__content">
                            <div class="d-flex align-items-center counterup-wrapper">
                                <span class="counterup-item__icon">
                                    <img src="{{ frontendImage('banner', @$banner->data_values->counter_one_icon, '65x65') }}" alt="">
                                </span>
                                <div class="content">
                                    <div class="counterup-item__number">
                                        <h4 class="counterup-item__title mb-0">
                                            <span class="odometer" data-odometer-final="{{ @$banner->data_values->counter_one_number_end }}">{{ @$banner->data_values->counter_one_number }}</span>{{ __(@$banner->data_values->counter_one_text_suffix) }}
                                        </h4>
                                    </div>
                                    <span class="counterup-item__text mb-0"> {{ __(@$banner->data_values->counter_one_text) }} </span>
                                </div>
                            </div>
                        </div>
                        <div class="counterup-item__content">
                            <div class="d-flex align-items-center counterup-wrapper">
                                <span class="counterup-item__icon">
                                    <img src="{{ frontendImage('banner', @$banner->data_values->counter_two_icon, '65x65') }}" alt="">
                                </span>
                                <div class="content">
                                    <div class="counterup-item__number">
                                        <h4 class="counterup-item__title mb-0">
                                            <span class="odometer" data-odometer-final="{{ @$banner->data_values->counter_two_number_end }}">{{ @$banner->data_values->counter_two_number }}</span>{{ __(@$banner->data_values->counter_two_text_suffix) }}
                                        </h4>
                                    </div>
                                    <span class="counterup-item__text mb-0"> {{ __(@$banner->data_values->counter_two_text) }} </span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="banner-content__button d-flex justify-content-center align-items-center">
                        <a href="{{ route('home') }}" class="btn btn--base btn--md"> @lang('INVESTMENT PLAN') </a>
                        <a href="{{ route('user.register') }}" class="btn btn--base btn--md"> @lang('REGISTER') </a>
                    </div>
                </div>
            </div> 
        </div>
    </div>
    <div class="coins-wrapper">
        <div class="coins-wrapper__one">
            <img src="{{ asset($activeTemplateTrue . 'images/thumbs/ban-4.png') }}" alt="">
        </div>
        <div class="coins-wrapper__two">
            <img src="{{ asset($activeTemplateTrue . 'images/thumbs/ban-4.png') }}" alt="">
        </div>
        <div class="coins-wrapper__three">
            <img src="{{ asset($activeTemplateTrue . 'images/thumbs/ban-5.png') }}" alt="">
        </div>
        <div class="coins-wrapper__four">
            <img src="{{ asset($activeTemplateTrue . 'images/thumbs/ban-5.png') }}" alt="">
        </div>
    </div>
    <div class="banner-section__thumb-one">
        <img src="{{ frontendImage('banner', @$banner->data_values->left_image, '540x680') }}" alt="">
    </div>
    <div class="banner-section__thumb-two">
        <img src="{{ frontendImage('banner', @$banner->data_values->right_image, '870x520') }}" alt="">
    </div>

</section>
<!--========================== Banner Section End ==========================-->