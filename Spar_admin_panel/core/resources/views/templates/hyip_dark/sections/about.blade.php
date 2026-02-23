@php
    $about = getContent('about.content', true);
    $abouts = getContent('about.element', false, null, true);
@endphp

<!--============== about section start here ============== -->
<div class="about-section my-120">
    <div class="container">
        <div class="row gy-4 justify-content-center align-items-center">
            <div class="col-lg-4 col-md-6">
                <div class="about-content">
                    <h3 class="about-content__title"> @lang('About') <span class="text--base"> {{ gs('site_name') }} </span></h3>
                    <p class="about-content__text">
                        {{ __(@$about->data_values->heading) }}
                    </p>
                    <p class="about-content__desc">
                        {{ __(@$about->data_values->subheading) }}
                    </p>
                    <div class="about-content__btn">
                        <a href="{{ @$about->data_values->button_url }}" class="btn btn--base btn--md"> {{ __(@$about->data_values->button_text) }} </a>
                    </div>
                </div>
            </div>
            <div class="col-lg-4 d-lg-block d-none">
                <div class="about-thumb">
                    <img src="{{ frontendImage('about', @$about->data_values->image, '360x330') }}" alt="">
                </div>
            </div>
            <div class="col-lg-4 col-md-6">
                <div class="about-right">
                    <h3 class="title">{{ __(@$about->data_values->right_side_heading) }}</h3>
                    <div class="step-wrapper">
                        @foreach($abouts as $item)
                            <div class="step-item">
                                <h5 class="step-item__title"> {{ __(@$item->data_values->heading) }} </h5>
                                <h6 class="step-item__commission"> {{ __(@$item->data_values->subheading) }} </h6>
                                <div class="step-item__shape"></div>
                            </div>
                        @endforeach
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<!--============== about section end here ============== -->